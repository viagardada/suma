"""Generate an eight-dimensional grid, sample native Julia STM/TRM, merge labels.

Examples (from the repository root):
  python suma/expand_native_table.py prepare --count 256
  python suma/expand_native_table.py run --julia D:/workforce/Julia/bin/julia.exe
  python suma/expand_native_table.py merge

Outputs stay separate until --install is explicitly passed to merge. Native labels
replace legacy labels only at matching keys; legacy origin is unknown. JSONL raw
samples and SQLite joint-action counts are retained for auditing and resumption.
"""
import argparse
import csv
import hashlib
import json
import math
from pathlib import Path
import shutil
import sqlite3
import subprocess
from collections import Counter

ROOT = Path(__file__).resolve().parent
DEFAULT_TABLE = ROOT / 'my_lightweight_table_dense.csv'
FIELDS = ['Range(ft)', 'Rel_Altitude(ft)', 'Bearing(deg)', 'Rel_Heading(deg)',
          'Intruder_Speed(fps)', 'Own_Speed(fps)', 'Own_Vert_Rate(fps)',
          'Int_Vert_Rate(fps)', 'Tau(s)', 'Recommended_Action']


def dump(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding='utf-8')


def canonical(x):
    return (x + 180) % 360 - 180


def discretize(s):
    r,z,b,h,vi,vo,ov,iv,tau = s
    r = max(100, round(r/100)*100) if r <= 500 else round(r/(500 if r <= 2000 else 1000))*(500 if r <= 2000 else 1000)
    return tuple(float(x) for x in (r, round(z/100)*100,
        canonical(round(b/30)*30), canonical(round(h/30)*30),
        round(vi/50)*50, round(vo/50)*50, round(ov/10)*10,
        round(iv/10)*10, -1 if tau < 0 else min(100,max(5,round(tau/5)*5))))


def prepare(args):
    with args.table.open(encoding='utf-8-sig', newline='') as f:
        rows = list(csv.DictReader(f))
    grid = [sorted({float(r[k]) for r in rows}) for k in FIELDS[:8]]
    grid[2] = grid[3] = list(range(-180,180,30))
    manifest_path = args.work/'manifest.json'
    if manifest_path.exists():
        # Installing an expanded table must not silently alter the traversal grid.
        grid = json.loads(manifest_path.read_text(encoding='utf-8'))['grid']
    total = math.prod(map(len,grid))
    # Permutation of the full Cartesian grid: bounded memory and no replacement.
    # Contiguous chunks cover widely separated grid states, not just one speed.
    stride = int(total * 0.6180339887498949) | 1
    while math.gcd(stride,total) != 1:
        stride += 2
    end = min(total,args.start+args.count)
    if args.start < 0 or args.count < 1 or args.start >= total:
        raise ValueError('Invalid start/count')
    spec = dict(fields=FIELDS[:8], grid=grid, total_combinations=total,
                stride=stride, seed=args.seed, duration=args.duration, warmup=args.warmup,
                own_altitude_ft=10000, own_heading_deg=0,
                model='constant velocity, no pilot response, uncoordinated V2V intruder')
    fingerprint = hashlib.sha256(json.dumps(spec,sort_keys=True).encode()).hexdigest()
    if manifest_path.exists() and json.loads(manifest_path.read_text(encoding='utf-8'))['fingerprint'] != fingerprint:
        raise ValueError('Work directory belongs to a different grid/configuration')
    dump(manifest_path,dict(spec,fingerprint=fingerprint))
    # Append new disjoint case ranges, while preserving old cases for resume.
    cases_path = args.work/'cases.jsonl'
    existing = set()
    if cases_path.exists():
        existing = {json.loads(line)['id'] for line in cases_path.read_text().splitlines()}
    added = 0
    with cases_path.open('a',encoding='utf-8') as f:
        for ordinal in range(args.start,end):
            if ordinal in existing:
                continue
            index = (ordinal*stride+args.seed) % total
            values = []
            for levels in reversed(grid):
                index, digit = divmod(index,len(levels))
                values.append(levels[digit])
            f.write(json.dumps(dict(id=ordinal,initial=values[::-1]))+'\n')
            added += 1
        if args.focus:
            import itertools
            # Additional targeted coverage for the five comparison maps; every
            # full-grid case still traverses all eight independent dimensions.
            focus = itertools.product([r for r in grid[0] if r<=3000],
                                      [-200,-100,0,100,200],grid[2])
            for i,(r,z,b) in enumerate(focus):
                case_id = total+i
                if case_id not in existing:
                    f.write(json.dumps(dict(id=case_id,initial=[r,z,b,-180,200,200,0,0]))+'\n')
                    added += 1
    print(json.dumps(dict(total_grid=total, axis_levels=list(map(len,grid)),
                         added_cases=added, prepared_cases=len(existing)+added),indent=2))


def run(args):
    manifest = json.loads((args.work/'manifest.json').read_text(encoding='utf-8'))
    subprocess.run([args.julia,'--startup-file=no',str(ROOT/'native_grid_sampler.jl'),
        str(args.work/'cases.jsonl'), str(args.work/'native_samples.jsonl'),str(args.params),
        str(manifest['duration']),str(manifest['warmup'])],check=True)


def validate(args):
    """Independent kinematic checks on raw samples before installing labels."""
    manifest = json.loads((args.work/'manifest.json').read_text(encoding='utf-8'))
    cases = {c['id']:c for c in map(json.loads,(args.work/'cases.jsonl').read_text().splitlines())}
    results = {}
    actions = Counter()
    max_tau_error = 0.0
    with (args.work/'native_samples.jsonl').open(encoding='utf-8') as f:
        for line in f:
            c = json.loads(line)
            if c['id'] in results: raise ValueError('Duplicate completed case ID')
            if c['initial'] != cases[c['id']]['initial']: raise ValueError('Initial state mismatch')
            if len(c['samples']) != manifest['duration']+1: raise ValueError('Missing observations')
            for t,sample in enumerate(c['samples']):
                s = sample['state']; h,v = sample['action']
                if sample['time'] != t or len(s)!=9 or not all(map(math.isfinite,s)):
                    raise ValueError('Invalid time/state')
                if h not in range(5) or v not in range(8): raise ValueError('Unknown action code')
                r,z,b,psi,vi,vo,ov,iv,tau = s
                radial = vi*math.cos(math.radians(psi-b))-vo*math.cos(math.radians(b))
                expected = -r/radial if radial < -.1 else -1
                error = abs(tau-expected)
                max_tau_error = max(max_tau_error,error)
                if not math.isclose(tau,expected,rel_tol=1e-7,abs_tol=1e-6):
                    raise ValueError('Tau disagrees with independently reconstructed relative velocity')
                actions[(h,v)] += 1
            results[c['id']] = c
    missing = set(cases)-set(results)
    if missing: raise ValueError(f'{len(missing)} planned cases are incomplete')
    repeat = None
    if -1 in results and -2 in results:
        repeat = results[-1]['samples']==results[-2]['samples']
        if not repeat: raise ValueError('Fresh scenario states are not repeatable')
    report = dict(validated_cases=len(results),samples=sum(actions.values()),
        nonzero_action_samples=sum(n for (h,v),n in actions.items() if h or v),
        joint_actions={f'H:{h} | V:{v}':n for (h,v),n in sorted(actions.items())},
        max_tau_reconstruction_error=max_tau_error,repeatability_passed=repeat,
        initial_axis_coverage=[len({tuple(c['initial'])[i] for c in results.values()}) for i in range(8)])
    dump(args.work/'validation_report.json',report)
    print(json.dumps(report,indent=2))


def merge(args):
    db = sqlite3.connect(args.work/'counts.sqlite')
    db.execute('CREATE TABLE IF NOT EXISTS completed (id INTEGER PRIMARY KEY)')
    db.execute('CREATE TABLE IF NOT EXISTS votes (state TEXT, h INTEGER, v INTEGER, n INTEGER, PRIMARY KEY(state,h,v))')
    processed = 0
    with db, (args.work/'native_samples.jsonl').open(encoding='utf-8') as raw:
        for line in raw:
            c = json.loads(line)
            if db.execute('SELECT 1 FROM completed WHERE id=?',(c['id'],)).fetchone():
                continue
            votes = Counter((json.dumps(discretize(s['state'])), *s['action']) for s in c['samples'])
            db.executemany('INSERT INTO votes VALUES (?,?,?,?) ON CONFLICT(state,h,v) DO UPDATE SET n=n+excluded.n',
                [(k,h,v,n) for (k,h,v),n in votes.items()])
            db.execute('INSERT INTO completed VALUES (?)',(c['id'],))
            processed += 1
            if processed % 100 == 0:
                db.commit()
    legacy_votes = {}
    raw_legacy_rows = 0
    with args.table.open(encoding='utf-8-sig',newline='') as f:
        for r in csv.DictReader(f):
            raw_legacy_rows += 1
            key = tuple(float(r[k]) for k in FIELDS[:9])
            key = key[:2]+(canonical(key[2]),canonical(key[3]))+key[4:]
            legacy_votes.setdefault(key,Counter())[r[FIELDS[-1]]] += 1
    # +/-180 are one physical direction. Resolve alias duplicates jointly,
    # rather than letting file order silently choose an action.
    legacy = {key: sorted(votes, key=lambda a:(-votes[a],a))[0]
              for key,votes in legacy_votes.items()}
    old_count = len(legacy)
    native = {}
    conflicts = ties = 0
    details_path = args.work/'native_joint_actions.csv'
    with details_path.open('w',encoding='utf-8',newline='') as f:
        writer = csv.writer(f)
        writer.writerow(FIELDS+['Samples','Total_Samples','Agreement','Tied_Mode','Source'])
        for key_text, in db.execute('SELECT DISTINCT state FROM votes ORDER BY state'):
            key = tuple(json.loads(key_text))
            actions = list(db.execute('SELECT h,v,n FROM votes WHERE state=? ORDER BY n DESC,h,v',(key_text,)))
            h,v,n = actions[0]
            total = sum(x[2] for x in actions)
            tie = len(actions)>1 and actions[1][2]==n
            conflicts += len(actions)>1
            ties += tie
            native[key] = f'H:{h} | V:{v}'
            for ah,av,an in actions:
                writer.writerow([*key,f'H:{ah} | V:{av}',an,total,an/total,tie,'native_stm_trm'])
    replaced = sum(k in legacy for k in native)
    changed = sum(k in legacy and legacy[k]!=v for k,v in native.items())
    original_keys = set(legacy)
    legacy.update(native)
    output = args.work/'expanded_table.csv'
    with output.open('w',encoding='utf-8',newline='') as f:
        writer = csv.writer(f); writer.writerow(FIELDS)
        for key, action in sorted(legacy.items()):
            writer.writerow([*key,action])
    # Coverage metric for the current polar-map default slice (includes safe states).
    def cells(keys):
        return {(k[0],k[1],k[2]) for k in keys if k[0]<=3000 and k[1] in (-200,-100,0,100,200)
                and k[3]==-180 and k[4]>0 and abs(k[5]/k[4]-1)<.001}
    report = dict(completed_cases=db.execute('SELECT COUNT(*) FROM completed').fetchone()[0],
        native_states=len(native), added_states=len(native)-replaced,
        refreshed_legacy_states=replaced, changed_legacy_actions=changed,
        legacy_raw_rows=raw_legacy_rows, legacy_states=old_count,
        legacy_angular_alias_rows_collapsed=raw_legacy_rows-old_count,
        legacy_alias_action_conflicts=sum(len(v)>1 for v in legacy_votes.values()),
        expanded_states=len(legacy),
        conflicting_native_states=conflicts, tied_modes=ties,
        joint_action_tie_policy='count descending, then H and V ascending; ties explicitly flagged',
        default_slice_legacy_cells=len(cells(original_keys)),
        default_slice_native_cells=len(cells(native)), default_slice_merged_cells=len(cells(legacy)),
        source_note='Legacy origin unknown; native observations override exact matching keys only',
        sampler_sha256=hashlib.sha256((ROOT/'native_grid_sampler.jl').read_bytes()).hexdigest(),
        params_sha256=hashlib.sha256(args.params.read_bytes()).hexdigest() if hasattr(args,'params') else None,
        output=str(output))
    dump(args.work/'coverage_report.json', report)
    if args.install:
        digest = hashlib.sha256(args.table.read_bytes()).hexdigest()[:12]
        backup = args.work/f'original_table_{digest}.csv'
        if not backup.exists(): shutil.copy2(args.table,backup)
        staging = args.table.with_suffix('.csv.tmp')
        shutil.copy2(output,staging)
        staging.replace(args.table)
    db.close()
    print(json.dumps(report,indent=2))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('command', choices=['prepare','run','validate','merge'])
    p.add_argument('--work', type=Path,default=ROOT/'output'/'native_expansion_v2')
    p.add_argument('--table', type=Path,default=DEFAULT_TABLE)
    p.add_argument('--params', type=Path,default=ROOT/'suma'/'LookupTables'/'DO-396_paramsfile_acassxu_origami_20220908.txt')
    p.add_argument('--julia',default='julia')
    p.add_argument('--count',type=int,default=256)
    p.add_argument('--start',type=int,default=0)
    p.add_argument('--seed',type=int,default=20261016)
    p.add_argument('--duration',type=int,default=20)
    p.add_argument('--warmup',type=int,default=10)
    p.add_argument('--install',action='store_true')
    p.add_argument('--focus',action='store_true',help='Also cover all near-range cells of the five default maps')
    args = p.parse_args()
    args.work = args.work.resolve(); args.table = args.table.resolve()
    args.work.mkdir(parents=True,exist_ok=True)
    if args.duration < 0 or args.warmup < 1: p.error('Invalid duration/warmup')
    globals()[args.command](args)


if __name__ == '__main__':
    main()
