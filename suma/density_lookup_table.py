"""
轻量化查询表密集化脚本 - 网格孔洞填充 (Smart Hole-Filling)

对现有轻量化查询表进行核心区域（Range ≤ 3000ft, |Rel_Alt| ≤ 1000ft）的密集化，
通过生成现有网格点的单步邻居并用最近邻匹配填充动作标签。

输入: my_lightweight_table.csv
输出: my_lightweight_table_dense.csv
"""

import csv
import math
import sys
import os

# ================== 配置 ==================
INPUT_CSV = os.path.join(os.path.dirname(__file__), "my_lightweight_table.csv")
OUTPUT_CSV = os.path.join(os.path.dirname(__file__), "my_lightweight_table_dense.csv")
NUM_ITERATIONS = 3  # 迭代轮数
MAX_RANGE = 3000.0   # 核心区域最大距离 (ft)
MAX_ALT = 1000.0     # 核心区域最大相对高度 (ft)

# 离散化步长（与 visualize.py 一致）
RANGE_BIN_SMALL = 100.0    # Range <= 500
RANGE_BIN_MED = 500.0      # 500 < Range <= 2000
RANGE_BIN_LARGE = 1000.0   # Range > 2000
ALT_BIN = 100.0
BEARING_BIN = 30.0
HEADING_BIN = 30.0
INT_SPEED_BIN = 50.0
OWN_SPEED_BIN = 50.0
V_RATE_BIN = 10.0
TAU_BIN = 5.0

# 各维度的物理范围
RANGE_RANGES = {
    'small': (100.0, 500.0, RANGE_BIN_SMALL),
    'medium': (500.0, 2000.0, RANGE_BIN_MED),
    'large': (2000.0, 6000.0, RANGE_BIN_LARGE),
}


def get_range_bin(r):
    """获取 Range 的离散化步长和 bin 值（与 visualize.py 的 discretize_state 一致）"""
    if r <= 500.0:
        r_bin = round(r / 100.0) * 100.0
        r_bin = max(100.0, r_bin)
    elif r <= 2000.0:
        r_bin = round(r / 500.0) * 500.0
    else:
        r_bin = round(r / 1000.0) * 1000.0
    return r_bin


def get_range_step(r):
    """根据 range 值返回对应的离散化步长"""
    if r <= 500.0:
        return RANGE_BIN_SMALL
    elif r <= 2000.0:
        return RANGE_BIN_MED
    else:
        return RANGE_BIN_LARGE


def discretize_state(r, z, b, psi, int_spd, own_spd, own_dz, int_dz, tau):
    """将连续物理状态转换为完整的 9 维离散状态元组（与 visualize.py 一致）"""
    if r <= 500.0:
        r_bin = round(r / 100.0) * 100.0
        r_bin = max(100.0, r_bin)
    elif r <= 2000.0:
        r_bin = round(r / 500.0) * 500.0
    else:
        r_bin = round(r / 1000.0) * 1000.0

    a_bin = round(z / ALT_BIN) * ALT_BIN

    b_bin = round(b / BEARING_BIN) * BEARING_BIN
    if b_bin > 180.0:
        b_bin -= 360.0

    psi_bin = round(psi / HEADING_BIN) * HEADING_BIN
    if psi_bin > 180.0:
        psi_bin -= 360.0

    int_spd_bin = round(int_spd / INT_SPEED_BIN) * INT_SPEED_BIN
    own_spd_bin = round(own_spd / OWN_SPEED_BIN) * OWN_SPEED_BIN

    own_dz_bin = round(own_dz / V_RATE_BIN) * V_RATE_BIN
    int_dz_bin = round(int_dz / V_RATE_BIN) * V_RATE_BIN

    if tau < 0:
        tau_bin = -1.0
    else:
        tau_bin = 100.0 if tau >= 100.0 else round(tau / TAU_BIN) * TAU_BIN
        tau_bin = max(TAU_BIN, tau_bin)

    return (r_bin, a_bin, b_bin, psi_bin, int_spd_bin, own_spd_bin, own_dz_bin, int_dz_bin, tau_bin)


def is_in_core_region(state_9tuple):
    """判断是否在核心区域内"""
    r_bin = state_9tuple[0]
    z_bin = abs(state_9tuple[1])
    return r_bin <= MAX_RANGE and z_bin <= MAX_ALT


def generate_neighbors(state_9tuple, action_str):
    """
    为给定的离散状态生成所有单步邻居。

    每个邻居只改变 9 个维度中的一个，变化量为 ±1 个离散步长。
    返回 (neighbor_9tuple, original_action) 列表。
    """
    (r_bin, a_bin, b_bin, psi_bin, int_spd_bin, own_spd_bin,
     own_dz_bin, int_dz_bin, tau_bin) = state_9tuple

    neighbors = []

    # 1. Range 维度：需要根据当前 range 值选择不同步长
    r_step = get_range_step(r_bin)
    # 注意 range 的最小值是 100（离散化后）
    for delta_r in [-r_step, r_step]:
        new_r = r_bin + delta_r
        # range 边界限制
        if new_r < 100.0:
            continue
        if new_r > 6000.0:
            continue
        # 确保新 range 能正确离散化
        new_r_bin = get_range_bin(new_r)
        if new_r_bin == r_bin:
            continue  # 如果离散化后相同，跳过
        new_state = (new_r_bin, a_bin, b_bin, psi_bin, int_spd_bin,
                     own_spd_bin, own_dz_bin, int_dz_bin, tau_bin)
        neighbors.append(new_state)

    # 2. Rel_Altitude 维度
    for delta_z in [-ALT_BIN, ALT_BIN]:
        new_z = a_bin + delta_z
        if abs(new_z) > 2000.0:
            continue
        new_state = (r_bin, new_z, b_bin, psi_bin, int_spd_bin,
                     own_spd_bin, own_dz_bin, int_dz_bin, tau_bin)
        neighbors.append(new_state)

    # 3. Bearing 维度
    for delta_b in [-BEARING_BIN, BEARING_BIN]:
        new_b = b_bin + delta_b
        if new_b > 180.0:
            new_b -= 360.0
        elif new_b < -180.0:
            new_b += 360.0
        new_state = (r_bin, a_bin, new_b, psi_bin, int_spd_bin,
                     own_spd_bin, own_dz_bin, int_dz_bin, tau_bin)
        neighbors.append(new_state)

    # 4. Rel_Heading 维度
    for delta_psi in [-HEADING_BIN, HEADING_BIN]:
        new_psi = psi_bin + delta_psi
        if new_psi > 180.0:
            new_psi -= 360.0
        elif new_psi < -180.0:
            new_psi += 360.0
        new_state = (r_bin, a_bin, b_bin, new_psi, int_spd_bin,
                     own_spd_bin, own_dz_bin, int_dz_bin, tau_bin)
        neighbors.append(new_state)

    # 5. Intruder_Speed 维度
    for delta_s in [-INT_SPEED_BIN, INT_SPEED_BIN]:
        new_spd = int_spd_bin + delta_s
        if new_spd < 100.0 or new_spd > 400.0:
            continue
        new_state = (r_bin, a_bin, b_bin, psi_bin, new_spd,
                     own_spd_bin, own_dz_bin, int_dz_bin, tau_bin)
        neighbors.append(new_state)

    # 6. Own_Speed 维度
    for delta_s in [-OWN_SPEED_BIN, OWN_SPEED_BIN]:
        new_spd = own_spd_bin + delta_s
        if new_spd < 100.0 or new_spd > 400.0:
            continue
        new_state = (r_bin, a_bin, b_bin, psi_bin, int_spd_bin,
                     new_spd, own_dz_bin, int_dz_bin, tau_bin)
        neighbors.append(new_state)

    # 7. Own_Vert_Rate 维度
    for delta_dz in [-V_RATE_BIN, V_RATE_BIN]:
        new_dz = own_dz_bin + delta_dz
        if new_dz < -20.0 or new_dz > 60.0:
            continue
        new_state = (r_bin, a_bin, b_bin, psi_bin, int_spd_bin,
                     own_spd_bin, new_dz, int_dz_bin, tau_bin)
        neighbors.append(new_state)

    # 8. Int_Vert_Rate 维度
    for delta_dz in [-V_RATE_BIN, V_RATE_BIN]:
        new_dz = int_dz_bin + delta_dz
        if new_dz < -20.0 or new_dz > 60.0:
            continue
        new_state = (r_bin, a_bin, b_bin, psi_bin, int_spd_bin,
                     own_spd_bin, own_dz_bin, new_dz, tau_bin)
        neighbors.append(new_state)

    # 9. Tau 维度
    for delta_tau in [-TAU_BIN, TAU_BIN]:
        if tau_bin == -1.0:
            # tau = -1，只能生成 tau = 5 作为正方向邻居
            new_tau = TAU_BIN
        else:
            new_tau = tau_bin + delta_tau
            if new_tau <= 0:
                new_tau = -1.0
            elif new_tau >= 100.0:
                new_tau = 100.0
        new_state = (r_bin, a_bin, b_bin, psi_bin, int_spd_bin,
                     own_spd_bin, own_dz_bin, int_dz_bin, new_tau)
        neighbors.append(new_state)

    return neighbors


def find_nearest_action(state_9tuple, lookup_dict):
    """
    在查找表中找到与给定状态最接近的条目的动作。
    与 visualize.py 中的 find_nearest_action 逻辑一致。
    """
    keys = list(lookup_dict.keys())
    if not keys:
        return "H:0 | V:0"

    # 各维度的权重（与 visualize.py 一致）
    weights = [1.0, 1.0, 0.5, 0.5, 0.1, 0.1, 0.2, 0.2, 2.0]

    best_key = None
    best_dist = float('inf')

    # 为了加速，如果 key 数量很大，可以只查少量，但这里保持准确
    for key in keys:
        dist = 0.0
        for i in range(9):
            diff = state_9tuple[i] - key[i]
            dist += weights[i] * diff * diff
        if dist < best_dist:
            best_dist = dist
            best_key = key

    return lookup_dict.get(best_key, "H:0 | V:0")


def load_lookup_table(csv_path):
    """从 CSV 加载查询表，返回 {离散9元组: 动作} 字典"""
    lookup_dict = {}
    raw_rows = []
    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            r = float(row['Range(ft)'])
            z = float(row['Rel_Altitude(ft)'])
            b = float(row['Bearing(deg)'])
            psi = float(row['Rel_Heading(deg)'])
            int_spd = float(row['Intruder_Speed(fps)'])
            own_spd = float(row['Own_Speed(fps)'])
            own_dz = float(row['Own_Vert_Rate(fps)'])
            int_dz = float(row['Int_Vert_Rate(fps)'])
            tau = float(row['Tau(s)'])
            action = row['Recommended_Action']

            discrete_key = discretize_state(r, z, b, psi, int_spd, own_spd, own_dz, int_dz, tau)
            if discrete_key not in lookup_dict:
                lookup_dict[discrete_key] = action
            raw_rows.append((discrete_key, r, z, b, psi, int_spd, own_spd, own_dz, int_dz, tau, action))

    return lookup_dict, raw_rows


def main():
    print(f"输入文件: {INPUT_CSV}")
    print(f"输出文件: {OUTPUT_CSV}")
    print(f"迭代轮数: {NUM_ITERATIONS}")
    print(f"核心区域: Range ≤ {MAX_RANGE}ft, |Rel_Alt| ≤ {MAX_ALT}ft")
    print()

    # 1. 加载现有表
    print("正在加载现有查询表...")
    lookup_dict, raw_rows = load_lookup_table(INPUT_CSV)
    print(f"现有离散化网格点: {len(lookup_dict)} 个")
    print(f"原始数据行数: {len(raw_rows)} 条")
    print()

    # 获取现有网格点的集合（用于去重）
    existing_states = set(lookup_dict.keys())

    # 迭代生成新状态
    all_dense_states = {}  # {离散9元组: 动作}
    all_dense_states.update(lookup_dict)  # 先加入原始状态

    current_states = set(lookup_dict.keys())  # 当前轮的起始状态集

    for iteration in range(1, NUM_ITERATIONS + 1):
        print(f"====== 第 {iteration} 轮迭代 ======")
        new_candidates = {}  # {离散9元组: 父状态动作} 用于去重

        count_checked = 0
        count_in_core = 0
        count_new = 0

        for state_9tuple in current_states:
            # 只对核心区域内的状态生成邻居
            if not is_in_core_region(state_9tuple):
                continue

            count_in_core += 1
            action = all_dense_states[state_9tuple]
            neighbors = generate_neighbors(state_9tuple, action)

            for neighbor in neighbors:
                count_checked += 1

                # 跳过已有状态
                if neighbor in existing_states:
                    continue
                if neighbor in all_dense_states:
                    continue
                if neighbor in new_candidates:
                    continue

                # 只保留核心区域内的邻居
                if not is_in_core_region(neighbor):
                    continue

                new_candidates[neighbor] = action
                count_new += 1

        print(f"  核心区网格点数: {count_in_core}")
        print(f"  候选邻居总数: {count_checked}")
        print(f"  新增不重复网格点: {count_new}")

        if count_new == 0:
            print("  没有新的候选点，提前结束迭代。")
            break

        # 对候选点进行最近邻匹配，分配动作标签
        print(f"  正在进行最近邻匹配为 {count_new} 个候选点分配动作...")
        for i, (neighbor, _) in enumerate(new_candidates.items()):
            # 使用当前已确认的状态集（包括之前轮次新增的）作为查找表
            if (i + 1) % 5000 == 0:
                print(f"    已处理 {i + 1}/{count_new}...")
            action = find_nearest_action(neighbor, all_dense_states)
            all_dense_states[neighbor] = action

        # 更新当前状态集（下一轮从此集合生成邻居）
        current_states = set(new_candidates.keys())
        existing_states.update(current_states)

        print(f"  本轮完成后总网格点数: {len(all_dense_states)}")
        print()

    # 2. 构建 CSV 输出
    print(f"正在写出 CSV 文件...")
    fieldnames = [
        'Range(ft)', 'Rel_Altitude(ft)', 'Bearing(deg)', 'Rel_Heading(deg)',
        'Intruder_Speed(fps)', 'Own_Speed(fps)', 'Own_Vert_Rate(fps)',
        'Int_Vert_Rate(fps)', 'Tau(s)', 'Recommended_Action'
    ]

    with open(OUTPUT_CSV, 'w', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(fieldnames)

        for state_9tuple, action in all_dense_states.items():
            writer.writerow([
                f"{state_9tuple[0]:.1f}",   # Range
                f"{state_9tuple[1]:.1f}",   # Rel_Altitude
                f"{state_9tuple[2]:.1f}",   # Bearing
                f"{state_9tuple[3]:.1f}",   # Rel_Heading
                f"{state_9tuple[4]:.1f}",   # Intruder_Speed
                f"{state_9tuple[5]:.1f}",   # Own_Speed
                f"{state_9tuple[6]:.1f}",   # Own_Vert_Rate
                f"{state_9tuple[7]:.1f}",   # Int_Vert_Rate
                f"{state_9tuple[8]:.1f}",   # Tau
                action
            ])

    print(f"完成！输出文件: {OUTPUT_CSV}")
    print(f"总网格点数: {len(all_dense_states)}")
    print(f"原始网格点数: {len(lookup_dict)}")
    print(f"新增网格点数: {len(all_dense_states) - len(lookup_dict)}")


if __name__ == "__main__":
    main()