"""Plan near-conflict native simulations from uncovered eight-dimensional states.

This is only kinematic screening; action labels always come from native STM/TRM.
"""
import argparse
from collections import Counter, defaultdict, deque
import csv
import hashlib
import json
import math
from pathlib import Path
import random
import sqlite3

from expand_native_table import ROOT, FIELDS, DEFAULT_TABLE, canonical, discretize, dump


def encounter_geometry(state):
    """Unmaneuvered horizontal CPA and vertical separation at that same time."""
    r,z,b,h,vi,vo,ov,iv = state
    x,y = r*math.sin(math.radians(b)), r*math.cos(math.radians(b))
    vx,vy = vi*math.sin(math.radians(h)), vi*math.cos(math.radians(h))-vo
    dot = x*vx+y*vy
    speed2 = vx*vx+vy*vy
    if speed2 < 1e-9 or dot >= 0:
        return None
    t = -dot/speed2
    horizontal = math.hypot(x+vx*t,y+vy*t)
    vertical = abs(z+(iv-ov)*t)
    return dict(cpa_time=t,horizontal_cpa_ft=horizontal,vertical_at_cpa_ft=vertical,
                tau=-r*r/dot)


def projection(state):
    """Polar-map cell: position, heading and speed ratio, independent of tau/Vz."""
    r,z,b,h,vi,vo = state[:6]
    return (r,z,canonical(b),canonical(h),round(vo/vi,6))


def coverage(table, five_heights=False):
    points = set()
    with table.open(encoding='utf-8-sig',newline='') as f:
        for row in csv.DictReader(f):
            state = tuple(float(row[k]) for k in FIELDS[:8])
            altitude_ok = state[1] in (-200,-100,0,100,200) if five_heights else abs(state[1])<=1000
            if state[0]<=3000 and altitude_ok:
                points.add(projection(state))
    return points


def plan(args):
    manifest = json.loads((args.work/'manifest.json').read_text(encoding='utf-8'))
    planned = [json.loads(s) for s in (args.work/'cases.jsonl').read_text().splitlines()]
    used = {tuple(c['initial']) for c in planned}
    before = coverage(args.table)
    native = set()
    with sqlite3.connect(args.work/'counts.sqlite') as db:
        for key, in db.execute('SELECT DISTINCT state FROM votes'):
            native.add(tuple(json.loads(key)[:8]))
    grid = manifest['grid']
    grid = [list(x) for x in grid]
    grid[0] = [r for r in grid[0] if r<=3000]
    grid[1] = [z for z in grid[1] if abs(z)<=1000]
    rng = random.Random(args.seed)
    buckets = {'conflict':defaultdict(list), 'boundary':defaultdict(list)}
    seen = set(used)
    accepted = Counter()
    for _ in range(args.pool):
        state = tuple(rng.choice(levels) for levels in grid)
        if state in seen: continue
        seen.add(state)
        g = encounter_geometry(state)
        if g is None or g['cpa_time']>manifest['duration']: continue
        d,z = g['horizontal_cpa_ft'],g['vertical_at_cpa_ft']
        if d<=500 and z<=200:
            kind='conflict'
        elif d<=1200 and z<=600:
            kind='boundary'
        else:
            continue
        missing = projection(state) not in before
        new_native = state not in native
        # Missing cells first; then unobserved native states. CPA thresholds are
        # planning heuristics, not ACAS alert thresholds or collision guarantees.
        rank = (not missing,not new_native, d/500+z/200, rng.random())
        group = (state[2],state[3])
        buckets[kind][group].append((rank,state,g))
        accepted[kind]+=1
    selected=[]
    selected_projections=set()
    for kind, budget in [('conflict',args.count-args.count//10),('boundary',args.count//10)]:
        groups = []
        for group,items in sorted(buckets[kind].items()):
            items.sort(key=lambda item:item[0])
            groups.append(deque(items))
        rng.shuffle(groups)
        chosen=0
        deferred=[]
        while groups and chosen<budget:
            remaining=[]
            for items in groups:
                if chosen>=budget: break
                while items:
                    rank,state,g = items.popleft()
                    if projection(state) not in selected_projections:
                        break
                    deferred.append((rank,state,g))
                else:
                    continue
                selected.append(dict(initial=list(state),screening=g,kind=kind,
                    missing_projection=projection(state) not in before,
                    native_state_unseen=state not in native))
                selected_projections.add(projection(state))
                chosen+=1
                if items: remaining.append(items)
            groups=remaining
        # Once distinct cells are exhausted, deepen coverage with other physical
        # speeds/vertical rates in the same cell rather than silently dropping them.
        for rank,state,g in sorted(deferred,key=lambda item:item[0]):
            if chosen>=budget: break
            selected.append(dict(initial=list(state),screening=g,kind=kind,
                missing_projection=projection(state) not in before,
                native_state_unseen=state not in native))
            selected_projections.add(projection(state))
            chosen+=1
    if len(selected)!=args.count:
        raise ValueError(f'Only {len(selected)} eligible candidates; increase --pool')
    next_id = max([manifest['total_combinations']+99999]+[c['id'] for c in planned])+1
    for i,c in enumerate(selected): c['id']=next_id+i
    name=f'priority_{next_id}_{next_id+len(selected)-1}'
    # Save the exact previous table: reproducible before/after metrics and rollback.
    import shutil
    baseline=args.work/f'{name}_baseline.csv'
    shutil.copy2(args.table,baseline)
    with (args.work/'cases.jsonl').open('a',encoding='utf-8') as f:
        for c in selected: f.write(json.dumps(c)+'\n')
    report=dict(batch=name,case_ids=[c['id'] for c in selected],count=len(selected),
        candidate_draws=args.pool,seed=args.seed,candidate_kinds=dict(accepted),
        selected_kinds=dict(Counter(c['kind'] for c in selected)),
        missing_projection_cases=sum(c['missing_projection'] for c in selected),
        unseen_native_cases=sum(c['native_state_unseen'] for c in selected),
        distinct_initial_projections=len(selected_projections),
        initial_axis_levels=[len({c['initial'][i] for c in selected}) for i in range(8)],
        before_projected_cells=len(before),baseline=str(baseline),
        baseline_sha256=hashlib.sha256(baseline.read_bytes()).hexdigest(),
        screening='linear unmaneuvered CPA <=20s, conflict 500ft/200ft; boundary 1200ft/600ft',
        note='Screening selects cases only; all labels must be produced by native sUMA')
    dump(args.work/f'{name}_plan.json',report)
    print(json.dumps({k:v for k,v in report.items() if k!='case_ids'},indent=2))


def assess(args):
    reports=sorted(args.work.glob('priority_*_plan.json'),key=lambda p:p.stat().st_mtime)
    report=json.loads(reports[-1].read_text(encoding='utf-8'))
    ids=set(report['case_ids'])
    baseline=Path(report['baseline'])
    before=coverage(baseline)
    after=coverage(args.table)
    before_five=coverage(baseline,True)
    after_five=coverage(args.table,True)
    native_before=set()
    native_after=set()
    cases=0
    samples=0
    nonzero=0
    actions=Counter()
    for line in (args.work/'native_samples.jsonl').read_text().splitlines():
        c=json.loads(line)
        target=native_after if c['id'] in ids else native_before
        for s in c['samples']:
            target.add(discretize(s['state']))
            if c['id'] in ids:
                samples+=1
                actions[tuple(s['action'])]+=1
                nonzero+=any(s['action'])
        cases+=c['id'] in ids
    if cases!=len(ids): raise ValueError('Priority batch incomplete')
    result=dict(batch=report['batch'],cases=cases,samples=samples,
        nonzero_action_samples=nonzero,new_native_states=len(native_after-native_before),
        before_projected_cells=len(before),after_projected_cells=len(after),
        added_projected_cells=len(after-before),lost_projected_cells=len(before-after),
        projection_scope='Range <=3000ft, abs(relative altitude)<=1000ft, all headings and speed ratios',
        five_height_cells_before=len(before_five),five_height_cells_after=len(after_five),
        most_improved_five_height_slices=[dict(heading=h,own_to_intruder_ratio=ratio,added_cells=n)
            for (h,ratio),n in Counter((p[3],p[4]) for p in after_five-before_five).most_common(10)],
        joint_actions={f'H:{h} | V:{v}':n for (h,v),n in sorted(actions.items())})
    dump(args.work/f"{report['batch']}_result.json",result)
    print(json.dumps(result,indent=2))


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('command',choices=['plan','assess'])
    p.add_argument('--work',type=Path,default=ROOT/'output'/'native_expansion_v2')
    p.add_argument('--table',type=Path,default=DEFAULT_TABLE)
    p.add_argument('--count',type=int,default=1536)
    p.add_argument('--pool',type=int,default=100000)
    p.add_argument('--seed',type=int,default=20261017)
    args=p.parse_args()
    args.work=args.work.resolve();args.table=args.table.resolve()
    if args.count<1 or args.pool<args.count: p.error('Invalid count/pool')
    globals()[args.command](args)
