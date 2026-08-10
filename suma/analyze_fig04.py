# -*- coding: utf-8 -*-
"""分析第4张图(04_v_core_heading.png)的数据分布"""
import csv
from collections import Counter

# 元组索引: 0=Range 1=Rel_Alt 2=Bearing 3=Rel_Heading 4=Tau 5=水平动作 6=垂直动作
C_R, C_A, C_B, C_H, C_T, C_HC, C_VC = range(7)

rows = []
with open(r'suma\my_lightweight_table_dense.csv', encoding='utf-8') as f:
    for r in csv.DictReader(f):
        h = int(r['Recommended_Action'].split('|')[0].split(':')[1].strip())
        v = int(r['Recommended_Action'].split('|')[1].split(':')[1].strip())
        rows.append((float(r['Range(ft)']), float(r['Rel_Altitude(ft)']),
                     float(r['Bearing(deg)']), float(r['Rel_Heading(deg)']),
                     float(r['Tau(s)']), h, v))

V_NAMES = {0: 'NO ADVISORY(安全)', 1: 'CLEAR(解除)', 2: 'DO NOT CLIMB(禁爬升)',
           3: 'DO NOT DESCEND(禁下降)', 4: 'CLIMB(爬升)', 5: 'DESCEND(下降)',
           6: 'XC CLIMB(交叉爬升)', 7: 'XC DESCEND(交叉下降)'}
HDG_NAME = {-180: '对头 -180°', -90: '左交叉 -90°', 0: '同向 0°', 90: '右交叉 90°', 180: '同向 180°'}

# 图04条件: 核心区 Range<=3000, |Rel_Alt|<=1000, Bearing=0, Tau=5, 按 Rel_Heading 分层
core = [r for r in rows if r[C_R] <= 3000 and abs(r[C_A]) <= 1000
        and r[C_B] == 0.0 and r[C_T] == 5.0]
print('图04筛选总条数(Bearing=0, Tau=5, 核心区):', len(core))

for hdg in [-180.0, -90.0, 0.0, 90.0]:
    sub = [r for r in core if r[C_H] == hdg]
    if not sub:
        print(f'  Heading={hdg:g}: 无数据')
        continue
    cnt = Counter(r[6] for r in sub)
    total = len(sub)
    print(f'  Heading={hdg:g} ({HDG_NAME[int(hdg)]}): {total} 条')
    for v, n in cnt.most_common():
        print(f'      V{v} {V_NAMES[v]}: {n} ({n/total*100:.1f}%)')

# 再看每个子图里 Range×Alt 的有效格占比
print('\n各子图网格覆盖率(Range9档×Alt21档=189格):')
for hdg in [-180.0, -90.0, 0.0, 90.0]:
    sub = [r for r in core if r[C_H] == hdg]
    if not sub:
        continue
    cells = {(round(r[C_R]), round(r[C_A])) for r in sub}
    print(f'  Heading={hdg:g}: 覆盖 {len(cells)}/189 格 ({len(cells)/189*100:.0f}%)')