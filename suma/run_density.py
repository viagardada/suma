# -*- coding: utf-8 -*-
"""Self-contained runner for density lookup table generation.
Writes all output to log file for debugging."""
import sys, os, time, csv, traceback

LOG_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "density_run.log")
OUTPUT_LOG = open(LOG_FILE, 'w', encoding='utf-8')

def log(msg):
    OUTPUT_LOG.write(str(msg) + '\n')
    OUTPUT_LOG.flush()

try:
    log("=== Starting Density Lookup Table Generation ===")
    log(f"Python: {sys.version}")
    log(f"Time: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    
    import numpy as np
    from scipy.spatial import KDTree
    log("Imports OK")
    
    SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
    INPUT_CSV = os.path.join(SCRIPT_DIR, "my_lightweight_table.csv")
    OUTPUT_CSV = os.path.join(SCRIPT_DIR, "my_lightweight_table_dense.csv")
    
    ALT_BIN=100.0; BEARING_BIN=30.0; HEADING_BIN=30.0
    INT_SPEED_BIN=50.0; OWN_SPEED_BIN=50.0; V_RATE_BIN=10.0; TAU_BIN=5.0
    WEIGHTS = np.array([1.0,1.0,0.5,0.5,0.1,0.1,0.2,0.2,2.0])
    MAX_R=3000.0; MAX_A=1000.0; MAX_CAND=40000
    
    def get_range_bin(r):
        if r<=500: rb=round(r/100)*100; rb=max(100,rb)
        elif r<=2000: rb=round(r/500)*500
        else: rb=round(r/1000)*1000
        return rb
    
    def disc(r,z,b,p,isp,osp,odz,idz,tau):
        rb=get_range_bin(r)
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
    
    log("Loading lookup table...")
    lookup={}
    with open(INPUT_CSV,'r',encoding='utf-8') as f:
        for row in csv.DictReader(f):
            k=disc(float(row['Range(ft)']),float(row['Rel_Altitude(ft)']),float(row['Bearing(deg)']),
                   float(row['Rel_Heading(deg)']),float(row['Intruder_Speed(fps)']),
                   float(row['Own_Speed(fps)']),float(row['Own_Vert_Rate(fps)']),
                   float(row['Int_Vert_Rate(fps)']),float(row['Tau(s)']))
            if k not in lookup: lookup[k]=row['Recommended_Action']
    log(f"Loaded {len(lookup)} states")
    
    keys=list(lookup.keys()); acts=[lookup[k] for k in keys]
    ref=np.array(keys)*np.sqrt(WEIGHTS)
    tree=KDTree(ref)
    all_d=dict(lookup)
    exist=set(keys)
    cur=set(keys)
    
    for it in range(1,4):
        log(f"=== Iteration {it} ===")
        ti=time.time()
        cand=set()
        for s in cur:
            if s[0]>MAX_R or abs(s[1])>MAX_A: continue
            for n in gen_nbr(s):
                if n not in exist and n not in all_d and n not in cand:
                    if n[0]<=MAX_R and abs(n[1])<=MAX_A:
                        cand.add(n)
                        if len(cand)>=MAX_CAND: break
            if len(cand)>=MAX_CAND: break
        log(f"  {len(cand)} candidates")
        if not cand: break
        cl=list(cand)
        cs=np.array(cl)*np.sqrt(WEIGHTS)
        _,idx=tree.query(cs,k=1)
        for j,i in enumerate(idx): all_d[cl[j]]=acts[i]
        cur=cand; exist|=cand
        log(f"  Total: {len(all_d)}, time: {time.time()-ti:.1f}s")
    
    log(f"Writing CSV ({len(all_d)} states)...")
    with open(OUTPUT_CSV,'w',encoding='utf-8',newline='') as f:
        w=csv.writer(f)
        w.writerow(['Range(ft)','Rel_Altitude(ft)','Bearing(deg)','Rel_Heading(deg)',
                    'Intruder_Speed(fps)','Own_Speed(fps)','Own_Vert_Rate(fps)',
                    'Int_Vert_Rate(fps)','Tau(s)','Recommended_Action'])
        for s,a in all_d.items():
            w.writerow([f'{v:.1f}' for v in s]+[a])
    
    log(f"Done! Total: {len(all_d)} (new: {len(all_d)-len(lookup)})")
    log(f"Output: {OUTPUT_CSV}")
    
except Exception as e:
    log(f"ERROR: {e}")
    log(traceback.format_exc())
finally:
    OUTPUT_LOG.close()
    print(f"Done. Check log: {LOG_FILE}", flush=True)