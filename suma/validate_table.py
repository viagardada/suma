# -*- coding: utf-8 -*-
"""
验证密集化查询表的合理性。
对比 my_lightweight_table.csv (原表) 和 my_lightweight_table_dense.csv (新表)。
输出详细的统计报告。
"""

import csv
import os
import sys
from collections import Counter, defaultdict

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OLD_CSV = os.path.join(SCRIPT_DIR, "my_lightweight_table.csv")
NEW_CSV = os.path.join(SCRIPT_DIR, "my_lightweight_table_dense.csv")

# 离散化参数（需与 visualize.py 和 density_lookup_table.py 一致）
ALT_BIN = 100.0
BEARING_BIN = 30.0
HEADING_BIN = 30.0
INT_SPEED_BIN = 50.0
OWN_SPEED_BIN = 50.0
V_RATE_BIN = 10.0
TAU_BIN = 5.0


def discretize_state(r, z, b, psi, int_spd, own_spd, own_dz, int_dz, tau):
    if r <= 500.0:
        r_bin = round(r / 100.0) * 100.0
        r_bin = max(100.0, r_bin)
    elif r <= 2000.0:
        r_bin = round(r / 500.0) * 500.0
    else:
        r_bin = round(r / 1000.0) * 1000.0
    a_bin = round(z / ALT_BIN) * ALT_BIN
    b_bin = round(b / BEARING_BIN) * BEARING_BIN
    if b_bin > 180.0: b_bin -= 360.0
    psi_bin = round(psi / HEADING_BIN) * HEADING_BIN
    if psi_bin > 180.0: psi_bin -= 360.0
    int_spd_bin = round(int_spd / INT_SPEED_BIN) * INT_SPEED_BIN
    own_spd_bin = round(own_spd / OWN_SPEED_BIN) * OWN_SPEED_BIN
    own_dz_bin = round(own_dz / V_RATE_BIN) * V_RATE_BIN
    int_dz_bin = round(int_dz / V_RATE_BIN) * V_RATE_BIN
    tau_bin = -1.0 if tau < 0 else (100.0 if tau >= 100.0 else max(TAU_BIN, round(tau / TAU_BIN) * TAU_BIN))
    return (r_bin, a_bin, b_bin, psi_bin, int_spd_bin, own_spd_bin, own_dz_bin, int_dz_bin, tau_bin)


def load(path):
    """返回 (rows_list, {离散键: 动作}, Counter(动作))"""
    rows = []
    key_map = {}
    action_counter = Counter()
    with open(path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(row)
            k = discretize_state(
                float(row['Range(ft)']), float(row['Rel_Altitude(ft)']),
                float(row['Bearing(deg)']), float(row['Rel_Heading(deg)']),
                float(row['Intruder_Speed(fps)']), float(row['Own_Speed(fps)']),
                float(row['Own_Vert_Rate(fps)']), float(row['Int_Vert_Rate(fps)']),
                float(row['Tau(s)'])
            )
            if k not in key_map:
                key_map[k] = row['Recommended_Action']
            action_counter[row['Recommended_Action']] += 1
    return rows, key_map, action_counter


def analyze_column(name, values):
    """数值列的分析"""
    vals = [float(v) for v in values]
    n = len(vals)
    uniq = len(set(vals))
    mn, mx = min(vals), max(vals)
    avg = sum(vals) / n
    return {
        'name': name, 'count': n, 'unique': uniq,
        'min': mn, 'max': mx, 'avg': avg
    }


def main():
    print("=" * 70)
    print("   验证报告: 密集化查询表合理性检查")
    print("=" * 70)

    # ── 1. 加载数据 ──
    print("\n[1] 加载数据...")
    old_rows, old_keys, old_actions = load(OLD_CSV)
    new_rows, new_keys, new_actions = load(NEW_CSV)
    print(f"  原表: {len(old_rows)} 行, {len(old_keys)} 个离散状态")
    print(f"  新表: {len(new_rows)} 行, {len(new_keys)} 个离散状态")
    print(f"  扩充倍数: {len(new_keys) / len(old_keys):.1f}x")

    # ── 2. 字段完整性 ──
    print("\n[2] 字段完整性检查...")
    expected_fields = ['Range(ft)', 'Rel_Altitude(ft)', 'Bearing(deg)', 'Rel_Heading(deg)',
                       'Intruder_Speed(fps)', 'Own_Speed(fps)', 'Own_Vert_Rate(fps)',
                       'Int_Vert_Rate(fps)', 'Tau(s)', 'Recommended_Action']
    for table_name, rows in [('原表', old_rows), ('新表', new_rows)]:
        fields_ok = all(f in rows[0] for f in expected_fields)
        empty_cells = 0
        for row in rows:
            for f in expected_fields:
                if row.get(f, '') == '':
                    empty_cells += 1
        print(f"  {table_name}: 字段完整={fields_ok}, 空单元格数={empty_cells}")

    # ── 3. 数值范围分析 ──
    print("\n[3] 关键维度范围分析...")
    numeric_cols = ['Range(ft)', 'Rel_Altitude(ft)', 'Bearing(deg)', 'Rel_Heading(deg)',
                    'Intruder_Speed(fps)', 'Own_Speed(fps)', 'Tau(s)']
    for col in numeric_cols:
        new_vals = [r[col] for r in new_rows]
        s = analyze_column(col, new_vals)
        print(f"  {s['name']:20s}: min={s['min']:8.1f}, max={s['max']:8.1f}, "
              f"avg={s['avg']:8.1f}, unique={s['unique']}")

    # ── 4. 动作分布对比 ──
    print("\n[4] 动作分布对比...")
    all_actions = sorted(set(list(old_actions.keys()) + list(new_actions.keys())))
    print(f"  {'Action':20s} {'原表':>8s} {'新表':>8s} {'变化率':>8s}")
    print(f"  {'-'*20} {'-'*8} {'-'*8} {'-'*8}")
    for a in all_actions:
        old_c = old_actions.get(a, 0)
        new_c = new_actions.get(a, 0)
        if old_c > 0:
            ratio = new_c / old_c if old_c > 0 else 0
            print(f"  {a:20s} {old_c:>8d} {new_c:>8d} {ratio:>7.1f}x")
        else:
            print(f"  {a:20s} {old_c:>8d} {new_c:>8d} {'NEW':>8s}")

    # ── 5. 一致性检查 ──
    print("\n[5] 一致性检查...")
    # 5a. 原表中每个离散状态在新表中是否存在，且动作一致
    consistent = 0
    inconsistent = 0
    missing = 0
    for k, old_action in old_keys.items():
        new_action = new_keys.get(k)
        if new_action is None:
            missing += 1
        elif new_action == old_action:
            consistent += 1
        else:
            inconsistent += 1

    print(f"  原表状态中:")
    print(f"    动作一致: {consistent} ({100*consistent/len(old_keys):.1f}%)")
    print(f"    动作矛盾: {inconsistent} ({100*inconsistent/len(old_keys):.1f}%)")
    print(f"    新表中缺失: {missing} ({100*missing/len(old_keys):.1f}%)")
    if inconsistent > 0:
        print(f"  ⚠️  存在不一致！下面列出前 5 个:")
        count = 0
        for k, old_action in old_keys.items():
            new_action = new_keys.get(k)
            if new_action is not None and new_action != old_action:
                count += 1
                print(f"    状态 {k} → 原表: '{old_action}' 新表: '{new_action}'")
                if count >= 5:
                    break

    # 5b. 新表内部: 检查是否有重复键
    duplicate_keys = 0
    key_count = Counter()
    for row in new_rows:
        k = discretize_state(
            float(row['Range(ft)']), float(row['Rel_Altitude(ft)']),
            float(row['Bearing(deg)']), float(row['Rel_Heading(deg)']),
            float(row['Intruder_Speed(fps)']), float(row['Own_Speed(fps)']),
            float(row['Own_Vert_Rate(fps)']), float(row['Int_Vert_Rate(fps)']),
            float(row['Tau(s)'])
        )
        key_count[k] += 1
    duplicates = {k: c for k, c in key_count.items() if c > 1}
    if duplicates:
        print(f"\n  新表内部重复键: {len(duplicates)} 个")
        for k, c in list(duplicates.items())[:5]:
            print(f"    键 {k} 出现了 {c} 次")
    else:
        print(f"\n  新表内部无重复键 ✓")

    # ── 6. 核心区域覆盖 ──
    print("\n[6] 核心区域覆盖分析...")
    core_new = sum(1 for r in new_rows if float(r['Range(ft)']) <= 3000
                   and abs(float(r['Rel_Altitude(ft)'])) <= 1000)
    core_old = sum(1 for r in old_rows if float(r['Range(ft)']) <= 3000
                   and abs(float(r['Rel_Altitude(ft)'])) <= 1000)
    print(f"  核心区域 (Range≤3000ft, |Alt|≤1000ft):")
    print(f"    原表: {core_old}/{len(old_rows)} ({100*core_old/len(old_rows):.1f}%)")
    print(f"    新表: {core_new}/{len(new_rows)} ({100*core_new/len(new_rows):.1f}%)")

    # Range 分段覆盖
    print(f"\n[7] Range 分段覆盖 (新表):")
    ranges = [
        (0, 500), (500, 1000), (1000, 1500), (1500, 2000),
        (2000, 2500), (2500, 3000), (3000, 4000), (4000, 5000), (5000, 6000)
    ]
    for lo, hi in ranges:
        c = sum(1 for r in new_rows if lo < float(r['Range(ft)']) <= hi)
        print(f"  {lo:5.0f}-{hi:5.0f} ft: {c:>6d} 状态")

    # ── 总结 ──
    print("\n" + "=" * 70)
    if inconsistent == 0 and not duplicates:
        print("  ✅  验证通过！新表一致性好，无矛盾数据。")
    elif inconsistent == 0 and duplicates:
        print("  ⚠️  验证警告：新表无动作矛盾，但存在重复行。")
    else:
        print(f"  ❌  发现 {inconsistent} 个矛盾。如矛盾数很少可能是边界情况，可以接受。")

    print(f"\n  原表: {len(old_rows)} 行 → 新表: {len(new_rows)} 行")
    print(f"  建议: 把 visualize.py 中的 CSV 路径改为新表路径，用动画直观验证。")
    print("=" * 70)


if __name__ == '__main__':
    main()