# -*- coding: utf-8 -*-
import csv, os, time, sys, numpy as np
from scipy.spatial import KDTree

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
INPUT_CSV = os.path.join(SCRIPT_DIR, "my_lightweight_table.csv")
OUTPUT_CSV = os.path.join(SCRIPT_DIR, "my_lightweight_table_dense.csv")
NUM_ITERATIONS = 3
MAX_RANGE = 3000.0
MAX_ALT = 1000.0
MAX_CAND = 40000

ALT_BIN=100.0; BEARING_BIN=30.0; HEADING_BIN=30.0
INT_SPEED_BIN=50.0; OWN_SPEED_BIN=50.0; V_RATE_BIN=10.0; TAU_BIN=5.0
WEIGHTS = np.array([1.0,1.0,0.5,0.5,0.1,0.1,0.2,0.2,2.0])

def get_range_bin(r):
    if r<=500: rb=round(r/100)*100; rb=max(100,rb)
    elif r<=2000: rb=round(r/500)*500
    else: rb=round(r/1000)*1000
    return rb

def disc(r,z,b,p,isp,osp,odz,idz,tau):
    rb = get_range_bin(r)
    ab=round(z/ALT_BIN)*ALT_BIN
    bb=round(b/BEARING_BIN)*BEARING_BIN
    if bb>180: bb-=360
    pb=round(p/HEADING_BIN)*HEADING_BIN
    if pb>180: pb-=360
    ispb=round(isp/INT_SPEED_BIN)*INT_SPEED_BIN
    ospb=round(osp/OWN_SPEED_BIN)*OWN_SPEED_BIN
    odzb=round(odz/V_RATE_BIN)*V_RATE_BIN
    idzb=round(idz/V_RATE_BIN)*V_RATE_BIN
    tb=-1.0 if tau<0 else (100.0 if tau>=100 else max(TAU_BIN,round(tau/TAU_BIN)*TAU_BIN))
    return (rb,ab,bb,pb,ispb,ospb,odzb,idzb,tb)

def gen_nbr(s):
    r,a,b,p,isp,osp,odz,idz,tau=s
    nbrs=[]
    rs=100.0 if r<=500 else (500.0 if r<=2000 else 1000.0)
    for dr in (-rs,rs):
        nr=r+dr
        if 100<=nr<=6000:
            nrb=get_range_bin(nr)
            if nrb!=r: nbrs.append((nrb,a,b,p,isp,osp,odz,idz,tau))
    for dz in (-ALT_BIN,ALT_BIN):
        na=a+dz
        if abs(na)<=2000: nbrs.append((r,na,b,p,isp,osp,odz,idz,tau))
    for db in (-BEARING_BIN,BEARING_BIN):
        nb=b+db
        if nb>180: nb-=360
        elif nb<-180: nb+=360
        nbrs.append((r,a,nb,p,isp,osp,odz,idz,tau))
    for dp in (-HEADING_BIN,HEADING_BIN):
        np_=p+dp
        if np_>180: np_-=360
        elif np_<-180: np_+=360
        nbrs.append((r,a,b,np_,isp,osp,odz,idz,tau))
    for ds in (-INT_SPEED_BIN,INT_SPEED_BIN):
        ns=isp+ds
        if 100<=ns<=400: nbrs.append((r,a,b,p,ns,osp,odz,idz,tau))
    for ds in (-OWN_SPEED_BIN,OWN_SPEED_BIN):
        ns=osp+ds
        if 100<=ns<=400: nbrs.append((r,a,b,p,isp,ns,odz,idz,tau))
    for dd in (-V_RATE_BIN,V_RATE_BIN):
        nd=odz+dd
        if -20<=nd<=60: nbrs.append((r,a,b,p,isp,osp,nd,idz,tau))
    for dd in (-V_RATE_BIN,V_RATE_BIN):
        nd=idz+dd
        if -20<=nd<=60: nbrs.append((r,a,b,p,isp,osp,odz,nd,tau))
    for dt in (-TAU_BIN,TAU_BIN):
        if tau==-1: nt=TAU_BIN
        else:
            nt=tau+dt
            if nt<=0: nt=-1
            elif nt>=100: nt=100
        nbrs.append((r,a,b,p,isp,osp,odz,idz,nt))
    return nbrs

def main():
    print(f"Input: {INPUT_CSV}", flush=True)
    print(f"Output: {OUTPUT_CSV}", flush=True)
    t0 = time.time()

    lookup = {}
    with open(INPUT_CSV, 'r', encoding='utf-8') as f:
        for row in csv.DictReader(f):
            k = disc(float(row['Range(ft)']),float(row['Rel_Altitude(ft)']),float(row['Bearing(deg)']),
                     float(row['Rel_Heading(deg)']),float(row['Intruder_Speed(fps)']),
                     float(row['Own_Speed(fps)']),float(row['Own_Vert_Rate(fps)']),
                     float(row['Int_Vert_Rate(fps)']),float(row['Tau(s)']))
            if k not in lookup: lookup[k] = row['Recommended_Action']

    print(f"Loaded {len(lookup)} states", flush=True)
    keys = list(lookup.keys())
    acts = [lookup[k] for k in keys]
    ref = np.array(keys) * np.sqrt(WEIGHTS)
    tree = KDTree(ref)
    all_d = dict(lookup)
    exist = set(keys)
    cur = set(keys)

    for it in range(1, NUM_ITERATIONS+1):
        print(f"=== Iter {it} ===", flush=True)
        ti = time.time()
        cand = set()
        core_count = sum(1 for s in cur if s[0]<=MAX_RANGE and abs(s[1])<=MAX_ALT)
        print(f"  Processing {core_count} core states...", flush=True)
        for s in cur:
            if s[0] > MAX_RANGE or abs(s[1]) > MAX_ALT: continue
            for n in gen_nbr(s):
                if n not in exist and n not in all_d and n not in cand:
                    if n[0] <= MAX_RANGE and abs(n[1]) <= MAX_ALT:
                        cand.add(n)
                        if len(cand) >= MAX_CAND: break
            if len(cand) >= MAX_CAND: break

        print(f"  {len(cand)} candidates", flush=True)
        if not cand: break
        cl = list(cand)
        cs = np.array(cl) * np.sqrt(WEIGHTS)
        _, idx = tree.query(cs, k=1)
        for j,i in enumerate(idx): all_d[cl[j]] = acts[i]
        cur = cand; exist |= cand
        print(f"  Total: {len(all_d)}, time: {time.time()-ti:.1f}s", flush=True)

    print(f"Writing {len(all_d)} states...", flush=True)
    with open(OUTPUT_CSV, 'w', encoding='utf-8', newline='') as f:
        w = csv.writer(f)
        w.writerow(['Range(ft)','Rel_Altitude(ft)','Bearing(deg)','Rel_Heading(deg)',
                    'Intruder_Speed(fps)','Own_Speed(fps)','Own_Vert_Rate(fps)',
                    'Int_Vert_Rate(fps)','Tau(s)','Recommended_Action'])
        for s,a in all_d.items():
            w.writerow([f'{v:.1f}' for v in s] + [a])

    print(f"Done! {time.time()-t0:.1f}s total", flush=True)
    print(f"Original: {len(lookup)}, New: {len(all_d)-len(lookup)}", flush=True)

if __name__ == '__main__':
    main()