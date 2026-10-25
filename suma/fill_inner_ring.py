"""Fill actual missing polar-map cells inside 1000 ft using native target samples.

The target is five heights x six range bins x 12 bearings x 12 headings x 35
speed ratios. One physical absolute-speed pair is enough to cover a plot cell;
this does not claim exhaustive nine-dimensional policy coverage.
"""
import argparse
from collections import Counter
import csv
import hashlib
import itertools
import json
from pathlib import Path
import random
import shutil
import sqlite3

from expand_native_table import ROOT, DEFAULT_TABLE, FIELDS, dump, discretize
from priority_native_cases import projection

HEIGHTS=(-200,-100,0,100,200)


def seed_counts(args):
    """Keep cumulative native votes while isolating the shorter raw trajectories."""
    target=args.work/'counts.sqlite'
    metadata=args.work/'counts_seed.json'
    if target.exists():
        if not metadata.exists(): raise ValueError('Existing counts have no known source')
        return
    source=ROOT/'output'/'native_expansion_v2'/'counts.sqlite'
    with sqlite3.connect(str(source)) as old, sqlite3.connect(str(target)) as new:
        old.backup(new)
        cases=new.execute('SELECT COUNT(*) FROM completed').fetchone()[0]
        states=new.execute('SELECT COUNT(DISTINCT state) FROM votes').fetchone()[0]
    dump(metadata,dict(source=str(source),completed_cases=cases,native_states=states,
        source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
        note='Prior native votes retained; diagnostic case IDs -1/-2 are already counted and are not counted again'))
    print(f'Seeded {states} native states and {cases} completed case IDs from prior batches')


def target_grid(manifest):
    grid=manifest['grid']
    pairs={}
    for vi,vo in itertools.product(grid[4],grid[5]):
        ratio=round(vo/vi,6)
        pair=(vi,vo)
        if ratio not in pairs or sum(pair)<sum(pairs[ratio]): pairs[ratio]=pair
    return list(itertools.product([r for r in grid[0] if r<=1000],HEIGHTS,
                                 grid[2],grid[3],sorted(pairs))),pairs


def table_cells(table):
    points=set()
    with table.open(encoding='utf-8-sig',newline='') as f:
        for row in csv.DictReader(f):
            s=tuple(float(row[k]) for k in FIELDS[:8])
            if s[0]<=1000 and s[1] in HEIGHTS: points.add(projection(s))
    return points


def audit(args):
    manifest=json.loads((args.work/'manifest.json').read_text(encoding='utf-8'))
    expected,_=target_grid(manifest)
    present=table_cells(args.table)
    expected=set(expected)
    found=expected&present
    per_slice=Counter((p[1],p[3],p[4]) for p in found)
    ratios=sorted({p[4] for p in expected})
    slices=[dict(height=z,heading=h,ratio=q,filled=per_slice[z,h,q],total=72,
                 coverage=per_slice[z,h,q]/72)
            for z,h,q in itertools.product(HEIGHTS,manifest['grid'][3],ratios)]
    report=dict(total_cells=len(expected),filled_cells=len(found),missing_cells=len(expected-found),
                coverage=len(found)/len(expected),
                minimum_slice_coverage=min(s['coverage'] for s in slices),
                complete_slices=sum(s['filled']==72 for s in slices),total_slices=len(slices),
                scope='100/200/300/400/500/1000ft; heights -200/-100/0/100/200ft; all 12 bearings, 12 headings, 35 speed ratios',
                includes_no_advisory=True,slices=slices)
    dump(args.work/'ring_coverage.json',report)
    print(json.dumps({k:v for k,v in report.items() if k!='slices'},indent=2))
    return report


def plan(args):
    args.work.mkdir(parents=True,exist_ok=True)
    manifest_path=args.work/'manifest.json'
    if not manifest_path.exists():
        source=json.loads((ROOT/'output'/'native_expansion_v2'/'manifest.json').read_text(encoding='utf-8'))
        source.update(duration=0,warmup=10,mode='target state after full native 10-second history',
                      baseline_table=str(args.work/'baseline_table.csv'))
        source.pop('fingerprint',None)
        source['fingerprint']=hashlib.sha256(json.dumps(source,sort_keys=True).encode()).hexdigest()
        dump(manifest_path,source)
        shutil.copy2(args.table,args.work/'baseline_table.csv')
    manifest=json.loads(manifest_path.read_text(encoding='utf-8'))
    seed_counts(args)
    expected,pairs=target_grid(manifest)
    present=table_cells(args.table)
    missing=[p for p in expected if p not in present]
    random.Random(20261019).shuffle(missing)
    cases_path=args.work/'cases.jsonl'
    planned=[]
    if cases_path.exists(): planned=[json.loads(s) for s in cases_path.read_text().splitlines()]
    scheduled={tuple(c['target_cell']) for c in planned if 'target_cell' in c}
    next_id=max([1999999999]+[c['id'] for c in planned])+1
    selected=[p for p in missing if p not in scheduled][:args.count]
    with cases_path.open('a',encoding='utf-8') as f:
        for i,cell in enumerate(selected):
            r,z,b,h,ratio=cell
            vi,vo=pairs[ratio]
            c=dict(id=next_id+i,initial=[r,z,b,h,vi,vo,0,0],target_cell=cell)
            f.write(json.dumps(c)+'\n')
        if not planned:
            for case_id in (-1,-2):
                f.write(json.dumps(dict(id=case_id,initial=[1000,0,0,-180,200,200,0,0]))+'\n')
    print(json.dumps(dict(missing_cells=len(missing),new_target_cases=len(selected),
        already_scheduled=len(scheduled),total_planned=len(planned)+len(selected)+(2 if not planned else 0),
        duration=0,warmup=10),indent=2))
    audit(args)


def verify_targets(args):
    cases={c['id']:c for c in map(json.loads,(args.work/'cases.jsonl').read_text().splitlines())}
    target_count=0;misses=[]
    with (args.work/'native_samples.jsonl').open() as f:
        for line in f:
            c=json.loads(line)
            plan=cases[c['id']]
            if 'target_cell' not in plan: continue
            target_count+=1
            actual=projection(discretize(c['samples'][0]['state']))
            if actual!=tuple(plan['target_cell']):
                misses.append(dict(id=c['id'],target=plan['target_cell'],actual=actual))
    report=dict(verified_targets=target_count,mismatched_targets=len(misses),misses=misses)
    dump(args.work/'target_verification.json',report)
    print(json.dumps({k:v for k,v in report.items() if k!='misses'},indent=2))
    if target_count != sum('target_cell' in c for c in cases.values()):
        raise ValueError('Not all planned targets have completed native samples')
    if misses:
        raise ValueError('Some estimated states missed their target cells; inspect target_verification.json')
    # A short target query must produce exactly the same t=0 label/state as the
    # previously validated longer trajectory, not a cold-start substitute.
    original=ROOT/'output'/'native_expansion_v2'/'native_samples.jsonl'
    reference=None
    with original.open() as f:
        for line in f:
            c=json.loads(line)
            if c['id']==-1:
                reference=c['samples'][0];break
    with (args.work/'native_samples.jsonl').open() as f:
        for line in f:
            c=json.loads(line)
            if c['id']==-1:
                if c['samples'][0]!=reference: raise ValueError('Target query differs from full trajectory prefix')
                print('PASS: target query equals original 31-step native trajectory at t=0')
                break


def live_audit(args):
    """Read-only conservative progress snapshot of completed native records."""
    manifest=json.loads((args.work/'manifest.json').read_text(encoding='utf-8'))
    expected,_=target_grid(manifest)
    expected=set(expected)
    present=table_cells(args.work/'baseline_table.csv')
    done=set();incomplete=0
    paths=[args.work/'native_samples.jsonl']+sorted(args.work.glob('workers_*/worker_*_samples.jsonl'))
    for path in paths:
        if not path.exists():continue
        with path.open() as f:
            for line in f:
                try:c=json.loads(line)
                except json.JSONDecodeError:
                    incomplete+=1;break
                if c['id'] in done:continue
                done.add(c['id'])
                for sample in c['samples']:
                    present.add(projection(discretize(sample['state'])))
    found=present&expected
    report=dict(completed_cases=len(done),total_cells=len(expected),
        filled_cells=len(found),missing_cells=len(expected-found),coverage=len(found)/len(expected),
        incomplete_tail_files=incomplete,installed=False,
        note='Includes completed worker checkpoints; final table installation and validation still pending')
    dump(args.work/'live_progress.json',report)
    print(json.dumps(report,indent=2))


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('command',choices=['plan','audit','verify_targets','live_audit','seed_counts'])
    p.add_argument('--work',type=Path,default=ROOT/'output'/'ring_1000')
    p.add_argument('--table',type=Path,default=DEFAULT_TABLE)
    p.add_argument('--count',type=int,default=200000)
    args=p.parse_args();args.work=args.work.resolve();args.table=args.table.resolve()
    if args.count<1:p.error('count must be positive')
    globals()[args.command](args)
