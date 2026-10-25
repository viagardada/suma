"""Run independent native cases in isolated Julia processes and collect once.

Each worker owns its sample/log files. Only the coordinator appends to the main
sample file, and scenario IDs prevent duplicates after a restart.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import time

from expand_native_table import ROOT, dump


def ids_in(path):
    ids=set()
    if path.exists():
        with path.open(encoding='utf-8') as f:
            for line in f:
                case_id=json.loads(line)['id']
                if case_id in ids: raise ValueError(f'Duplicate case {case_id} in {path}')
                ids.add(case_id)
    return ids


def run(args):
    work=args.work.resolve()
    manifest=json.loads((work/'manifest.json').read_text(encoding='utf-8'))
    sampler=ROOT/'native_grid_sampler.jl'
    context=dict(manifest=manifest['fingerprint'],sampler=hashlib.sha256(sampler.read_bytes()).hexdigest(),
                 params=hashlib.sha256(args.params.read_bytes()).hexdigest())
    directory=work/f'workers_{args.workers}'
    directory.mkdir(exist_ok=True)
    context_path=directory/'context.json'
    if context_path.exists() and json.loads(context_path.read_text())!=context:
        raise ValueError('Worker files belong to a different engine/configuration')
    dump(context_path,context)
    target=work/'native_samples.jsonl'
    completed=ids_in(target)
    pending={}
    for line in (work/'cases.jsonl').read_text().splitlines():
        case=json.loads(line)
        if case['id'] not in completed: pending[case['id']]=line
    if not pending:
        print('All planned cases already complete.'); return
    processes=[]
    started=time.monotonic()
    env=os.environ.copy()
    env['JULIA_NUM_THREADS']='1'
    env['OPENBLAS_NUM_THREADS']='1'
    for worker in range(args.workers):
        cases=directory/f'worker_{worker}_cases.jsonl'
        samples=directory/f'worker_{worker}_samples.jsonl'
        log=directory/f'worker_{worker}.log'
        assigned={i for i in pending if i%args.workers==worker}
        cases.write_text(''.join(pending[i]+'\n' for i in sorted(assigned)),encoding='utf-8')
        already=len(ids_in(samples)&assigned)
        log_file=log.open('w',encoding='utf-8')
        command=[args.julia,'--startup-file=no',str(sampler),str(cases),str(samples),
                 str(args.params.resolve()),str(manifest['duration']),str(manifest['warmup'])]
        p=subprocess.Popen(command,stdout=log_file,stderr=subprocess.STDOUT,env=env,
                           creationflags=getattr(subprocess,'CREATE_NO_WINDOW',0))
        processes.append((p,log_file,log,samples,already))
    print(f'Running {len(pending)} pending cases in {args.workers} isolated Julia workers.',flush=True)
    try:
        while any(p.poll() is None for p, *_ in processes):
            done=0
            for p,handle,log,samples,already in processes:
                with log.open(encoding='utf-8',errors='replace') as f:
                    done+=already+sum(line.startswith('case ') for line in f)
            print(f'Progress {done}/{len(pending)}; elapsed {time.monotonic()-started:.0f}s',flush=True)
            time.sleep(15)
        for p,handle,log,samples,already in processes:
            handle.close()
            if p.returncode:
                raise RuntimeError(f'Worker failed ({p.returncode}); see {log}')
        # Validate full expected ID coverage before mutating the cumulative file.
        collected=set()
        for p,handle,log,samples,already in processes:
            collected.update(ids_in(samples)&set(pending))
        if collected!=set(pending): raise ValueError('Missing completed worker cases')
        with target.open('a',encoding='utf-8') as out:
            for p,handle,log,samples,already in processes:
                with samples.open(encoding='utf-8') as f:
                    for line in f:
                        case_id=json.loads(line)['id']
                        if case_id in pending and case_id not in completed:
                            out.write(line);out.flush();completed.add(case_id)
        print(f'Collected {len(pending)} new cases without duplicate IDs.',flush=True)
    finally:
        for p,handle,*_ in processes:
            if p.poll() is None:
                p.terminate();p.wait()
            if not handle.closed: handle.close()


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--work',type=Path,default=ROOT/'output'/'native_expansion_v2')
    p.add_argument('--workers',type=int,default=3)
    p.add_argument('--julia',default='julia')
    p.add_argument('--params',type=Path,default=ROOT/'suma'/'LookupTables'/'DO-396_paramsfile_acassxu_origami_20220908.txt')
    args=p.parse_args()
    if not 1<=args.workers<=5: p.error('Use 1 to 5 workers, subject to available memory')
    run(args)
