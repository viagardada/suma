import csv, sys, json, math
import numpy as np
from collections import Counter
try:
    from scipy.spatial import KDTree; _HAS_SCIPY = True
except ModuleNotFoundError:
    _HAS_SCIPY = False
    print("警告: 未安装 scipy，k-NN 功能不可用"); print("如需: D:\\workforce\\anaconda\\python.exe visualize.py --knn")
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
from matplotlib.animation import FuncAnimation, PillowWriter

plt.rcParams['font.sans-serif'] = ['SimHei', 'Microsoft YaHei', 'Arial Unicode MS']
plt.rcParams['axes.unicode_minus'] = False

H_ACTION_MAP = {0:"NO ADVISORY (安全)",1:"CLEAR OF CONFLICT (解除)",2:"TURN RIGHT (向右转)",3:"TURN LEFT (向左转)",4:"STRAIGHT (保持直飞)"}
V_ACTION_MAP = {0:"NO ADVISORY (安全/维持)",1:"CLEAR OF CONFLICT (解除)",2:"DO NOT CLIMB (禁止爬升)",3:"DO NOT DESCEND (禁止下降)",4:"CLIMB (建议爬升)",5:"DESCEND (建议下降)",6:"CROSSING CLIMB (交叉爬升)",7:"CROSSING DESCEND (交叉下降)"}
RANGE_BIN=500.0; ALT_BIN=100.0; BEARING_BIN=30.0; HEADING_BIN=30.0
INT_SPEED_BIN=50.0; OWN_SPEED_BIN=50.0; V_RATE_BIN=10.0; TAU_BIN=5.0
KT_TO_FPS=1.68781; RAD_TO_DEG=180.0/math.pi
WEIGHTS = [0.000020, 0.000300, 0.002222, 0.002222, 0.000400, 0.000400, 0.020000, 0.020000, 0.400000]

class KNNLookup:
    def __init__(self, lookup_table, k=5, weights=None):
        if weights is None: weights = WEIGHTS
        self.k = min(k, max(1, len(lookup_table)))
        self.sqrt_w = np.sqrt(weights)
        self.keys = list(lookup_table.keys())
        self.actions = [lookup_table[k] for k in self.keys]
        self.h_codes = []; self.v_codes = []
        for act in self.actions:
            h, v = parse_action_str(act)
            self.h_codes.append(h); self.v_codes.append(v)
        self.tree = KDTree(np.array(self.keys, dtype=np.float64) * self.sqrt_w)
        print(f"  KNNLookup: k={self.k}, {len(self.keys)} 个参考点")

    def query(self, state): return self.query_with_conf(state)[0]
    def query_with_conf(self, state):
        qv = np.array(state, dtype=np.float64) * self.sqrt_w
        dists, idx = self.tree.query(qv, k=self.k)
        if self.k == 1: return self.actions[idx[0]], 1.0, 1.0
        eps=1e-10; w=1.0/(dists+eps); tw=np.sum(w)
        hw={}; [exec(f'hw[self.h_codes[i]]=hw.get(self.h_codes[i],0)+w[j]') for j,i in enumerate(idx)]
        vw={}; [exec(f'vw[self.v_codes[i]]=vw.get(self.v_codes[i],0)+w[j]') for j,i in enumerate(idx)]
        bh=max(hw,key=hw.get); bv=max(vw,key=vw.get)
        return f"H:{bh} | V:{bv}", hw[bh]/tw, vw[bv]/tw

def discretize_state(r,z,b,p,is_,os_,odz,idz,t):
    rb=max(100,round(r/100)*100) if r<=500 else (round(r/500)*500 if r<=2000 else round(r/1000)*1000)
    ab=round(z/ALT_BIN)*ALT_BIN; bb=round(b/BEARING_BIN)*BEARING_BIN
    if bb>180: bb-=360
    pb=round(p/HEADING_BIN)*HEADING_BIN
    if pb>180: pb-=360
    tb=-1 if t<0 else (100 if t>=100 else max(TAU_BIN,round(t/TAU_BIN)*TAU_BIN))
    return (rb,ab,bb,pb,round(is_/INT_SPEED_BIN)*INT_SPEED_BIN,round(os_/OWN_SPEED_BIN)*OWN_SPEED_BIN,round(odz/V_RATE_BIN)*V_RATE_BIN,round(idz/V_RATE_BIN)*V_RATE_BIN,tb)

def load_lookup_table(p):
    l={}
    for r in csv.DictReader(open(p,encoding='utf-8')):
        k=(float(r['Range(ft)']),float(r['Rel_Altitude(ft)']),float(r['Bearing(deg)']),float(r['Rel_Heading(deg)']),float(r['Intruder_Speed(fps)']),float(r['Own_Speed(fps)']),float(r['Own_Vert_Rate(fps)']),float(r['Int_Vert_Rate(fps)']),float(r['Tau(s)']))
        if k not in l: l[k]=r['Recommended_Action']
    print(f"成功加载查询表，共 {len(l)} 条规则。"); return l

def find_nearest_action(s,t):
    bk=None; bd=float('inf')
    for k in t.keys():
        d=sum(WEIGHTS[i]*(s[i]-k[i])**2 for i in range(9))
        if d<bd: bd=d; bk=k
    return t.get(bk,"H:0 | V:0")

def parse_action_str(s):
    try: return int(s.split("|")[0].split(":")[1]), int(s.split("|")[1].split(":")[1])
    except: return 0,0

def parse_example_file(fn, target_id=None):
    data = json.load(open(fn,encoding='utf-8'))
    reports = data.get('acasx_reports',[])
    if not reports: print("错误：无数据"); sys.exit(1)
    tg={}
    for r in reports: t=round(r.get('report_time',0)*10)/10; tg.setdefault(t,[]).append(r)
    st=sorted(tg.keys())
    own={'hdg':0,'vns':0,'vew':0,'vrt':0,'lat':None,'lon':None,'alt':None}
    tracks={}

    for t in st:
        g=tg[t]
        # 更新本机
        for r in g:
            if r.get('report_type') not in ('Acas_sXu_DO396','Acas_sXu_V3R0'): continue
            p=r.get('acas_sxu_do396') or r.get('acas_sxu_v3r0') or {}; dt=p.get('data_type','')
            if dt=='HEADING_OBS':
                psi=p.get('heading_obs',{}).get('psi_rad',own['hdg'])
                own['hdg']=psi if psi!='_NaN_' else own['hdg']
            elif dt=='WGS84_OBS':
                w=p.get('wgs84_obs',{}); own['lat']=w.get('lat_deg',own['lat']); own['lon']=w.get('lon_deg',own['lon'])
                own['alt']=w.get('alt_hae_ft',own['alt']); own['vns']=w.get('vel_ns_kts',own['vns']); own['vew']=w.get('vel_ew_kts',own['vew'])
                ar=w.get('alt_rate_hae_fps',own['vrt']); own['vrt']=ar if ar!='_NaN_' else own['vrt']
            elif dt=='PRES_ALT_OBS':
                av=p.get('pres_alt_obs',{}).get('alt_pres_ft')
                if av and av!='_NaN_': own['alt']=av

        # 按 remote_id 分组
        ig={}
        for r in g:
            if r.get('report_type') not in ('Acas_sXu_DO396','Acas_sXu_V3R0'): continue
            p=r.get('acas_sxu_do396') or r.get('acas_sxu_v3r0') or {}; dt=p.get('data_type',''); rid=0
            if dt=='VEHICLE_TO_VEHICLE_REPORT': rid=p.get('vehicle_to_vehicle_report',{}).get('remote_id',0)
            elif dt=='ABSOLUTE_GEODETIC_TRACK': rid=p.get('absolute_geodetic_track',{}).get('remote_id',0)
            elif dt=='OWN_REL_NON_COOP_TRACK': rid=p.get('own_rel_non_coop_track',{}).get('remote_id',0)
            ig.setdefault(rid,[]).append(r)

        # 计算每个入侵机状态
        for rid,igr in ig.items():
            rf=None; az=None; rz=None; dg=None; ilat=None; ilon=None; ialt=None; ivns=0; ivew=0; ivrt=0
            for r in igr:
                p=r.get('acas_sxu_do396') or r.get('acas_sxu_v3r0') or {}; dt=p.get('data_type','')
                if dt=='VEHICLE_TO_VEHICLE_REPORT':
                    v=p.get('vehicle_to_vehicle_report',{}); rf=v.get('range_ft',rf)
                    ilat=v.get('lat_deg',ilat); ilon=v.get('lon_deg',ilon)
                    ialt=v.get('alt_pres_ft',ialt); ivns=v.get('vel_ns_kts',ivns); ivew=v.get('vel_ew_kts',ivew)
                elif dt=='OWN_REL_NON_COOP_TRACK':
                    tk=p.get('own_rel_non_coop_track',{}); rn=tk.get('range_ft'); azm=tk.get('azimuth_rad'); dgr=tk.get('dgr_fps'); rz_=tk.get('rel_z_ft')
                    if rn and rn!='_NaN_': rf=rn
                    if azm and azm!='_NaN_': az=azm
                    if dgr and dgr!='_NaN_': dg=dgr
                    if rz_ and rz_!='_NaN_': rz=rz_
                elif dt=='ABSOLUTE_GEODETIC_TRACK':
                    a=p.get('absolute_geodetic_track',{}); ivns=a.get('vel_ns_kts',ivns); ivew=a.get('vel_ew_kts',ivew); ivrt=a.get('alt_rate_pres_fps',ivrt)

            # 从经纬度计算距离（如果没有直接范围数据）
            if rf is None and own['lat'] and ilat:
                lat1=math.radians(own['lat']); lon1=math.radians(own['lon'])
                lat2=math.radians(ilat); lon2=math.radians(ilon)
                dlat=lat2-lat1; dlon=lon2-lon1
                a=math.sin(dlat/2)**2+math.cos(lat1)*math.cos(lat2)*math.sin(dlon/2)**2
                rf=6371000*2*math.atan2(math.sqrt(a),math.sqrt(1-a))*3.28084
                az=math.atan2(math.sin(dlon)*math.cos(lat2),math.cos(lat1)*math.sin(lat2)-math.sin(lat1)*math.cos(lat2)*math.cos(dlon))
                if own['alt'] and ialt: rz=ialt-own['alt']
            if rf is None or az is None: continue

            bearing=az*RAD_TO_DEG; psi=own['hdg']*RAD_TO_DEG
            spd=max(math.hypot(own['vns'],own['vew'])*KT_TO_FPS,100)
            ispd=max(math.hypot(ivns,ivew)*KT_TO_FPS,100)
            tau=-1
            # tau 方法1：直接 dgr
            if dg is not None and dg<0 and rf>0: tau=rf/(-dg)
            # tau 方法2：帧间 delta
            if tau<0 and tracks.get(rid):
                pr=tracks[rid][-1][1][0]; pt=tracks[rid][-1][0]; dt=t-pt
                if dt>0:
                    dgr_est=(pr-rf)/dt
                    if dgr_est>0 and rf>0: tau=rf/dgr_est
            state=(rf,rz or 0,bearing,psi,ispd,spd,own['vrt'],ivrt,tau,0)
            tracks.setdefault(rid,[]).append((t,state))

    if not tracks: print("错误：未能提取到任何入侵机数据"); sys.exit(1)
    all_ids=sorted(tracks.keys()); print(f"文件中包含 {len(all_ids)} 个入侵机: {all_ids}")
    if target_id is not None:
        if target_id not in tracks: print(f"错误：未找到 remote_id={target_id}"); print(f"可用ID: {all_ids}"); sys.exit(1)
        sel=target_id
    else:
        best=None; bt=float('inf')
        for rid,tr in tracks.items():
            mt=min(s[1][8] for s in tr)
            if mt>=0 and mt<bt: bt=mt; best=rid
        if best is None: best=max(tracks,key=lambda r:len(tracks[r]))
        sel=best
    tr=tracks[sel]; ts=[s[0] for s in tr]; ss=[s[1] for s in tr]
    print(f"选择入侵机 #{sel} ({len(all_ids)} 个总)"); print(f"解析 {len(ss)} 帧, 时间 {ts[0]:.1f}s~{ts[-1]:.1f}s")
    return ts,ss,sel,all_ids

def plot_polar_state(ax1,ax2,state,action_str="H:0|V:0",mrp=5000,extra=""):
    r,z,b,p,is_,os_,odz,idz,t,rh=state
    dk=discretize_state(*state[:9]); rb,ab,bb=dk[0],dk[1],dk[2]; hc,vc=parse_action_str(action_str)
    ht=H_ACTION_MAP.get(hc,f"UNK({hc})"); vt=V_ACTION_MAP.get(vc,f"UNK({vc})")
    ax1.clear(); ax2.clear(); ax1.set_theta_zero_location("N"); ax1.set_theta_direction(-1)
    st=100 if mrp<=1000 else 500; ls=200 if mrp<=1000 else 500
    if mrp>3000: st=500; ls=1000
    rt=np.arange(0,mrp+st,st); ax1.set_yticks(rt)
    ax1.set_yticklabels([str(int(i)) if i%ls==0 else "" for i in rt],color='gray',size=8)
    ax1.set_xticks(np.radians(np.arange(0,360,BEARING_BIN)))
    tg=np.radians(b if b>=0 else b+360)
    if rb<=500: sp=100; ri=0 if rb==100 else rb-50; ro=rb+50
    elif rb<=2000: sp=500; ri=450 if rb==500 else rb-250; ro=750 if rb==500 else rb+250
    else: sp=1000; ri=1750 if rb==2000 else rb-500; ro=2500 if rb==2000 else rb+500
    ri=max(0,ri); tc=float(bb)%360; ts=np.radians(tc-BEARING_BIN/2); te=np.radians(tc+BEARING_BIN/2)
    hl='red' if hc in[2,3] else 'lightgreen'
    if tc-BEARING_BIN/2<0:
        ax1.fill_between(np.linspace(ts+2*np.pi,2*np.pi,25),ri,ro,color=hl,alpha=.4)
        ax1.fill_between(np.linspace(0,te,25),ri,ro,color=hl,alpha=.4,label='H-State Bin')
    elif tc+BEARING_BIN/2>360:
        ax1.fill_between(np.linspace(ts,2*np.pi,25),ri,ro,color=hl,alpha=.4)
        ax1.fill_between(np.linspace(0,te-2*np.pi,25),ri,ro,color=hl,alpha=.4,label='H-State Bin')
    else: ax1.fill_between(np.linspace(ts,te,50),ri,ro,color=hl,alpha=.4,label='H-State Bin')
    ax1.scatter(0,0,c='blue',s=200,zorder=5,label='Ownship')
    ax1.scatter(tg,r,c='red',s=100,marker='x',zorder=5,label='Intruder')
    al=mrp*.2; at=np.radians(rh if rh>=0 else rh+360)
    tex=r*np.sin(tg)+al*np.sin(at); tey=r*np.cos(tg)+al*np.cos(at)
    ax1.annotate('',xy=(np.arctan2(tex,tey),np.hypot(tex,tey)),xytext=(tg,r),arrowprops=dict(facecolor='red',edgecolor='red',shrink=0,width=1.5,headwidth=6),zorder=4)
    ax1.set_ylim(0,mrp); ax1.set_title(f"Horizontal Control (Polar)\nH: {ht}",fontsize=12,fontweight='bold',pad=15)
    ax2.grid(True,linestyle='--',alpha=.6); ab=ab-ALT_BIN/2; at2=ab+ALT_BIN
    vl='red' if vc>=2 else 'lightgreen'; ax2.add_patch(Rectangle((ri,ab),(ro-ri),ALT_BIN,color=vl,alpha=.4,label='V-State Bin'))
    ax2.scatter(0,0,c='blue',s=200,zorder=5,label='Ownship'); ax2.scatter(r,z,c='red',s=100,marker='x',zorder=5,label='Intruder')
    ax2.annotate('',xy=(r,z+idz*5),xytext=(r,z),arrowprops=dict(facecolor='red',edgecolor='red',width=1.5,headwidth=6),zorder=4)
    ax2.annotate('',xy=(0,odz*5),xytext=(0,0),arrowprops=dict(facecolor='blue',edgecolor='blue',width=1.5,headwidth=6),zorder=4)
    mx=max(abs(z)+300,1000); ax2.set_xlim(-100,mrp); ax2.set_ylim(-mx,mx)
    ax2.set_xlabel("Horizontal Range (ft)",fontsize=11); ax2.set_ylabel("Relative Altitude (ft)",fontsize=11)
    ax2.axhline(0,color='black',linewidth=1,zorder=1)
    ax2.set_title(f"Vertical Profile (Range vs Rel-Alt)\nV: {vt}",fontsize=12,fontweight='bold',pad=15)
    ax1.legend(loc='lower right',bbox_to_anchor=(1.35,0),fontsize=8); ax2.legend(loc='upper right',fontsize=8)
    td="999.0" if t<0 else f"{t:.1f}"; tl=" (SAFE)" if t<0 else "s"
    lines=[f"Real State:",f"  Range: {r:.1f} ft ({r*0.3048:.1f} m)",f"  Rel Alt: {z:.1f} ft",f"  Bearing: {b:.1f}°",f"  Psi: {p:.1f}°",f"  Tau: {td}{tl}","",f"Discretized Into:",f"  Range Bin: {rb} ft",f"  Bearing Bin: {bb}°",f"  Alt Bin: {ab} ft"]
    if extra: lines.append(""); lines.append(extra)
    return "\n".join(lines)

def draw_risk_gauge(ax,tau,rf,z):
    ax.clear()
    tr=.1 if tau<0 else (1 if tau<15 else (1-(tau-15)/20*.6 if tau<35 else max(.4-min(tau-35,40)/40*.3,.1)))
    ar=abs(rf); rr=1 if ar<1000 else (1-(ar-1000)/2000*.6 if ar<3000 else max(.4-min(ar-3000,2000)/2000*.3,.05))
    az=abs(z); ar2=.8 if az<100 else (.8-(az-100)/400*.5 if az<500 else max(.3-min(az-500,500)/500*.2,.05))
    rk=min(1,max(0,tr*.5+rr*.3+ar2*.2)); rp=rk*100
    lt="危险"; lc='#FF1744'; bg='#FFEBEE'
    if rp<70: lt="注意"; lc='#FF9100'; bg='#FFF3E0'
    if rp<40: lt="安全"; lc='#00C853'; bg='#E8F5E9'
    ax.add_patch(plt.Rectangle((-.9,-.6),1.8,1.4,facecolor=bg,edgecolor=lc,linewidth=3))
    ax.text(0,.50,f'{rp:.0f}%',ha='center',va='center',fontsize=42,fontweight='bold',color=lc)
    ax.text(0,.15,f'[ {lt} ]',ha='center',va='center',fontsize=16,fontweight='bold',color=lc,bbox=dict(facecolor='white',edgecolor=lc,pad=5))
    ts=f'{tau:.1f}s' if tau>0 else '远离中'
    ax.text(0,-.12,f'\u03c4: {ts}',ha='center',va='center',fontsize=13,fontweight='bold',color='#333')
    ax.text(0,-.30,f'距离: {rf:.0f} ft',ha='center',va='center',fontsize=12,color='#555')
    ax.text(0,-.47,f'相对高度: {z:.0f} ft',ha='center',va='center',fontsize=12,color='#555')
    ax.set_xlim(-1,1); ax.set_ylim(-.65,1.05); ax.set_aspect('equal'); ax.axis('off'); ax.set_title("Collision Risk Gauge",fontsize=12,fontweight='bold',pad=10)
    return rk

def animate_example(ts_,ss,actions,interval=500,output_gif=None,h_confs=None,v_confs=None):
    sc=h_confs is not None and v_confs is not None
    mr=max(s[0] for s in ss)*1.2; pr=800 if mr<=800 else (2500 if mr<=2500 else 5000)
    all_t=[999 if s[8]<0 else s[8] for s in ss]
    fig=plt.figure(figsize=(16,10))
    ax1=fig.add_subplot(2,2,1,projection='polar'); ax2=fig.add_subplot(2,2,2); ax3=fig.add_subplot(2,2,3); ax4=fig.add_subplot(2,2,4)
    ito=plt.figtext(.02,.88,"",fontsize=10,va='top',bbox=dict(facecolor='white',alpha=.9,edgecolor='gray'))
    sto=fig.suptitle("",fontsize=14,fontweight='bold')
    def upd(fi):
        s=ss[fi]; a=actions[fi]; t=ts_[fi]
        ie=f"Frame: {fi+1}/{len(ss)} | t={t:.1f}s"
        if sc:
            hc=h_confs[fi]*100; vc=v_confs[fi]*100
            ie+=f"\n  H Conf: {hc:.1f}% ({'HIGH' if hc>=80 else ('MED' if hc>=50 else 'LOW')})\n  V Conf: {vc:.1f}% ({'HIGH' if vc>=80 else ('MED' if vc>=50 else 'LOW')})"
        it=plot_polar_state(ax1,ax2,s,a,mrp=pr,extra=ie)
        ax3.clear(); xs=ts_[:fi+1]; ys=all_t[:fi+1]
        ax3.plot(xs,ys,'b-o',markersize=4,linewidth=1.5,label='\u03c4 (s)')
        ax3.axhline(0,color='gray',linestyle='--',linewidth=.8); ax3.plot(t,all_t[fi],'ro',markersize=8,zorder=5)
        ax3.set_xlim(ts_[0],ts_[-1])
        rt=[v for v in all_t if 0<v<100]
        ym=-2; yM=10
        if rt: ym=min(-2,min(rt)-2); yM=max(10,max(rt)+5)
        ax3.set_ylim(ym,yM); ax3.set_xlabel("Time (s)",fontsize=11); ax3.set_ylabel("\u03c4 (seconds)",fontsize=11)
        ax3.set_title("Tau Over Time",fontsize=12,fontweight='bold'); ax3.grid(True,linestyle='--',alpha=.6); ax3.legend(loc='upper right',fontsize=9)
        r,z_rel,*_=s; draw_risk_gauge(ax4, z_rel, r, z_rel)
        ito.set_text(it); sto.set_text(f"Encounter Playback \u2014 Time: {t:.1f}s\nRecommended Action: {a}")
        return ax1,ax2,ax3,ax4,ito,sto
    ani=FuncAnimation(fig,upd,frames=len(ss),interval=interval,repeat=True,blit=False)
    plt.tight_layout(); plt.subplots_adjust(top=.85,bottom=.05)
    if output_gif:
        fps=1000/interval; print(f"保存 GIF 到 {output_gif} ({len(ss)} 帧, {fps:.1f} fps)...")
        ani.save(output_gif,writer=PillowWriter(fps=fps)); print("GIF 保存完成！")
        plt.close(fig)
    else: print(f"播放 {len(ss)} 帧, {interval}ms 间隔..."); print("关闭窗口退出"); plt.show()
    return ani

if __name__=="__main__":
    EF="D:/workforce/project/suma/suma/suma/example/generated/AutoGen_Encounter_0002.json"
    table=load_lookup_table("d:/workforce/project/suma/suma/my_lightweight_table_dense.csv")
    example_file=sys.argv[1] if len(sys.argv)>1 and not sys.argv[1].startswith("--") else EF
    interval=200; knn_k=5; use_knn=False; target_id=None
    for a in sys.argv[1:]:
        if a.startswith("--interval="):
            try: interval=int(a.split("=")[1])
            except: pass
        if a.startswith("--knn"):
            use_knn=True
            if "=" in a:
                try: knn_k=int(a.split("=")[1])
                except: pass
        if a.startswith("--target="):
            try: target_id=int(a.split("=")[1])
            except: pass
    print(f"解析: {example_file}")
    t_,ss,_,_=parse_example_file(example_file,target_id=target_id)
    if not ss: print("错误：无数据"); sys.exit(1)
    if use_knn:
        if not _HAS_SCIPY: print("错误: 未安装 scipy"); sys.exit(1)
        print(f"k-NN (k={knn_k})"); lookup=KNNLookup(table,k=knn_k)
    else: print("1-NN"); lookup=table
    acts=[]; hc_=[]; vc_=[]
    for s in ss:
        dk=discretize_state(*s[:9])
        if use_knn: a,h,v=lookup.query_with_conf(dk); acts.append(a); hc_.append(h); vc_.append(v)
        else: acts.append(find_nearest_action(dk,lookup)); hc_.append(1); vc_.append(1)
    matched=sum(1 for s,a in zip(ss,acts) if lookup if 0)  # skip for 1-NN
    print(f"精确匹配: {matched}/{len(ss)} 帧")
    output_gif=None; sc=use_knn
    for a in sys.argv[1:]:
        if a.startswith("--output-gif="): output_gif=a.split("=")[1]
        if a=="--show-conf": sc=True
    print(f"共 {len(ss)} 帧")
    if sc and use_knn: print(f"平均置信度: H={sum(hc_)/len(hc_)*100:.1f}%, V={sum(vc_)/len(vc_)*100:.1f}%")
    animate_example(t_,ss,acts,interval=interval,output_gif=output_gif,h_confs=hc_ if sc else None,v_confs=vc_ if sc else None)