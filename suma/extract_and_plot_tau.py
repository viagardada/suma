
"""
extract_and_plot_tau.py

对于 original/ 目录下的 encounter 数据，提取每个时间戳的 tau (到达最接近点的时间)
并绘制 tau 随时间变化的曲线。

方法: 从 encounter JSON 中解析 ownship 和 intruder 的经纬度/速度/高度，
使用几何方法计算水平 tau 和垂直 tau。

用法:
    python extract_and_plot_tau.py                          # 处理所有 original 文件
    python extract_and_plot_tau.py --encounter Encounter1000003Aircraft1Input.json  # 处理单个文件
"""

import os
import sys
import json
import math
import csv
import argparse

import numpy as np

try:
    import matplotlib
    matplotlib.use('Agg')  # 无头模式
    import matplotlib.pyplot as plt
    HAS_MPL = True
except ImportError:
    HAS_MPL = False
    print("Warning: matplotlib not found. Will output CSV only.")


# ============ 常量 ============
KTS_TO_FPS = 1.68781
FT_TO_NM = 1.0 / 6076.115
DEG_TO_RAD = math.pi / 180.0
RAD_TO_DEG = 180.0 / math.pi

# ============ 查询表相关常量 (与 visualize.py 保持一致) ============
RANGE_BIN = 500.0
ALT_BIN = 100.0
BEARING_BIN = 30.0
HEADING_BIN = 30.0
INT_SPEED_BIN = 50.0
OWN_SPEED_BIN = 50.0
V_RATE_BIN = 10.0
TAU_BIN = 5.0
WEIGHTS = [0.000020, 0.000300, 0.002222, 0.002222,
           0.000400, 0.000400, 0.020000, 0.020000, 0.400000]
LOOKUP_TABLE_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                 'my_lightweight_table_dense.csv')



def enu_from_lat_lon(origin_lat_deg, origin_lon_deg, target_lat_deg, target_lon_deg):
    """
    将经纬度差转换为东北天 (ENU) 坐标 (英尺)
    返回 (east_ft, north_ft)
    """
    lat1 = origin_lat_deg * DEG_TO_RAD
    lon1 = origin_lon_deg * DEG_TO_RAD
    lat2 = target_lat_deg * DEG_TO_RAD
    lon2 = target_lon_deg * DEG_TO_RAD

    dlat = lat2 - lat1
    dlon = lon2 - lon1

    # 地球半径 (英尺)
    R_ft = 3440.0 * 6076.115

    north = dlat * R_ft
    east = dlon * R_ft * math.cos(lat1)
    return (east, north)


def compute_tau_horiz(x_rel_ft, y_rel_ft, dx_rel_fps, dy_rel_fps):
    """
    计算水平 tau (到达最接近点的时间，秒)
    当飞机在远离时返回 Infinity
    """
    r = math.sqrt(x_rel_ft**2 + y_rel_ft**2)
    if r < 1.0:
        return float('inf')
    # 径向速度 = (x*dx + y*dy) / r
    radial_vel = (x_rel_ft * dx_rel_fps + y_rel_ft * dy_rel_fps) / r
    if radial_vel >= 0:
        return float('inf')
    return r / (-radial_vel)


def compute_tau_vert(z_rel_ft, dz_rel_fps):
    """
    计算垂直 tau (到达同高度的时间，秒)

    规则:
    - 垂直速率接近 0 → inf (高度差基本不变)
    - 两机已在同一高度 (|z_rel| < 1 ft) → inf (无需再"到达")
    - 相对高度与垂直速率同号 → inf (正在远离)
    - 否则 → |z_rel / dz_rel| (正在接近，到达同高度所需时间)
    """
    if abs(dz_rel_fps) < 1e-6:
        return float('inf')
    if abs(z_rel_ft) < 1.0:
        return float('inf')
    if z_rel_ft * dz_rel_fps > 0:
        return float('inf')
    return abs(z_rel_ft / dz_rel_fps)


def compute_cpa_distance(x_rel_ft, y_rel_ft, dx_rel_fps, dy_rel_fps):
    """
    计算最接近点 (CPA) 的距离 (英尺)
    """
    rv2 = dx_rel_fps**2 + dy_rel_fps**2
    if rv2 < 1e-10:
        return math.sqrt(x_rel_ft**2 + y_rel_ft**2)
    t_cpa = -(x_rel_ft * dx_rel_fps + y_rel_ft * dy_rel_fps) / rv2
    if t_cpa < 0:
        t_cpa = 0
    x_cpa = x_rel_ft + dx_rel_fps * t_cpa
    y_cpa = y_rel_ft + dy_rel_fps * t_cpa
    return math.sqrt(x_cpa**2 + y_cpa**2)


class LookupDict(dict):
    """支持附加 KDTree 属性的 dict 子类（普通 dict 不能设置属性）"""
    pass


def load_lookup_table(csv_path):
    """
    从 CSV 加载查询表。
    返回一个带 KDTree 加速索引的 LookupDict 对象:
    - 支持 dict 风格 `key in lookup` / `lookup[key]`
    - 支持 `lookup._has_kd` 标记是否可用 KDTree
    """
    lookup_dict = LookupDict()
    if not os.path.exists(csv_path):
        print(f"警告: 查询表文件不存在: {csv_path}")
        lookup_dict._has_kd = False
        return lookup_dict
    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            key = (
                float(row['Range(ft)']),
                float(row['Rel_Altitude(ft)']),
                float(row['Bearing(deg)']),
                float(row['Rel_Heading(deg)']),
                float(row['Intruder_Speed(fps)']),
                float(row['Own_Speed(fps)']),
                float(row['Own_Vert_Rate(fps)']),
                float(row['Int_Vert_Rate(fps)']),
                float(row['Tau(s)'])
            )
            if key not in lookup_dict:
                lookup_dict[key] = row['Recommended_Action']
    print(f"成功加载查询表: {csv_path}，共 {len(lookup_dict)} 条规则")

    # 构建 KDTree 加速最近邻查询
    try:
        from scipy.spatial import KDTree
        _keys = np.array(list(lookup_dict.keys()), dtype=np.float64)
        _sqrt_w = np.sqrt(np.array(WEIGHTS, dtype=np.float64))
        lookup_dict._kd_tree = KDTree(_keys * _sqrt_w)
        lookup_dict._kd_keys = list(lookup_dict.keys())
        lookup_dict._kd_sqrt_w = _sqrt_w
        lookup_dict._has_kd = True
        print(f"  已构建 KDTree 加速索引")
    except ImportError:
        lookup_dict._has_kd = False
        print(f"  scipy 不可用，使用线性扫描最近邻")

    return lookup_dict


def find_nearest_action(state_9tuple, lookup_dict):
    """
    在查找表中找到与给定状态最接近的条目的动作。
    优先精确匹配；若不在表中则使用加权最近邻（KDTree 加速），
    兜底返回 H:0 | V:0。
    """
    # 先尝试精确匹配
    if state_9tuple in lookup_dict:
        return lookup_dict[state_9tuple]

    # KDTree 加速最近邻
    if getattr(lookup_dict, '_has_kd', False):
        q = np.array(state_9tuple, dtype=np.float64) * lookup_dict._kd_sqrt_w
        dist, idx = lookup_dict._kd_tree.query(q)
        return lookup_dict[lookup_dict._kd_keys[idx]]

    # 线性扫描兜底（scipy 不可用时）
    keys = list(lookup_dict.keys())
    if not keys:
        return "H:0 | V:0"

    best_key = None
    best_dist = float('inf')
    for key in keys:
        dist = 0.0
        for i in range(9):
            diff = state_9tuple[i] - key[i]
            dist += WEIGHTS[i] * diff * diff
        if dist < best_dist:
            best_dist = dist
            best_key = key

    return lookup_dict.get(best_key, "H:0 | V:0")


def discretize_state(r, z, b, psi, int_spd, own_spd, own_dz, int_dz, tau):
    """
    将连续物理状态转换为 9 维离散状态元组。
    与 visualize.py 中的 discretize_state 逻辑一致。
    """
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

    # tau < 0 表示远离中，离散化为 -1；否则正常取 5 的倍数
    if tau < 0:
        tau_bin = -1.0
    else:
        tau_bin = 100.0 if tau >= 100.0 else round(tau / TAU_BIN) * TAU_BIN
        tau_bin = max(TAU_BIN, tau_bin)

    return (r_bin, a_bin, b_bin, psi_bin, int_spd_bin,
            own_spd_bin, own_dz_bin, int_dz_bin, tau_bin)


def compute_state_vector(own, intr, east_ft, north_ft, range_ft, tau_min):
    """
    根据 ownship / intruder 数据及几何量，构建 9 维状态向量:
    (Range, Rel_Alt, Bearing, Rel_Heading, Intruder_Speed,
     Own_Speed, Own_Vert_Rate, Int_Vert_Rate, Tau)
    """
    own_vel_e_fps = own.get('vel_ew_kts', 0) * KTS_TO_FPS
    own_vel_n_fps = own.get('vel_ns_kts', 0) * KTS_TO_FPS
    int_vel_e_fps = intr.get('vel_ew_kts', 0) * KTS_TO_FPS
    int_vel_n_fps = intr.get('vel_ns_kts', 0) * KTS_TO_FPS

    own_spd_fps = math.hypot(own_vel_e_fps, own_vel_n_fps)
    int_spd_fps = math.hypot(int_vel_e_fps, int_vel_n_fps)

    own_dz = own.get('alt_rate_hae_fps', 0)
    # 尝试从 intruder 数据中提取垂直速率
    int_dz = intr.get('alt_rate_hae_fps',
               intr.get('alt_rate_pres_fps', 0))

    # 相对方位角: atan2(east, north) => 北为 0，顺时针为正（度）
    bearing_deg = math.atan2(east_ft, north_ft) * RAD_TO_DEG

    # 本机航向角: atan2(vel_e, vel_n) => 北为 0，顺时针为正（度）
    if own_spd_fps > 1.0:
        heading_deg = math.atan2(own_vel_e_fps, own_vel_n_fps) * RAD_TO_DEG
    else:
        heading_deg = 0.0

    rel_alt_ft = intr.get('alt_hae_ft', intr.get('alt_pres_ft', 0)) - own.get('alt_hae_ft', 0)

    return (range_ft, rel_alt_ft, bearing_deg, heading_deg,
            int_spd_fps, own_spd_fps, own_dz, int_dz, tau_min)


def parse_encounter(filepath):
    """
    解析 encounter JSON 文件，提取每个时间步的 ownship 和 intruder 状态。
    """
    with open(filepath, 'r') as f:
        data = json.load(f)

    reports = data.get('acasx_reports', [])
    time_groups = {}

    for report in reports:
        rt = report.get('report_time', 0)
        t_floor = int(math.floor(rt))
        if t_floor < 0:
            t_floor = 0

        report_data = None
        if 'report_type' in report:
            rt_type = report['report_type']
            if rt_type == 'Acas_sXu_V3R0':
                acas_data = report.get('acas_sxu_v3r0', {})
                data_type = acas_data.get('data_type', '')
                if data_type == 'WGS84_OBS':
                    report_data = ('ownship', acas_data.get('wgs84_obs', {}))
                elif data_type == 'VEHICLE_TO_VEHICLE_REPORT':
                    report_data = ('intruder', acas_data.get('vehicle_to_vehicle_report', {}))
            elif rt_type == 'Acas_sXu_DO396':
                acas_data = report.get('acas_sxu_do396', {})
                data_type = acas_data.get('data_type', '')
                if data_type == 'WGS84_OBS':
                    report_data = ('ownship', acas_data.get('wgs84_obs', {}))
                elif data_type == 'VEHICLE_TO_VEHICLE_REPORT':
                    report_data = ('intruder', acas_data.get('vehicle_to_vehicle_report', {}))

        if report_data is None:
            continue

        kind, values = report_data
        if t_floor not in time_groups:
            time_groups[t_floor] = {'ownship': None, 'intruders': {}}

        if kind == 'ownship':
            time_groups[t_floor]['ownship'] = values
        elif kind == 'intruder':
            intruder_id = values.get('remote_id', values.get('v2v_uid', 0))
            time_groups[t_floor]['intruders'][str(intruder_id)] = values

    return time_groups


def compute_tau_for_time_group(time_groups, lookup_table=None):
    """
    对每个时间组计算 tau 值，并通过查询表获取避障动作。
    lookup_table: {9维离散元组: 动作字符串} 字典，若为 None 则跳过查表。
    """
    results = []
    sorted_times = sorted(time_groups.keys())

    for t in sorted_times:
        group = time_groups[t]
        own = group.get('ownship')
        if own is None:
            continue

        own_lat = own.get('lat_deg', 0)
        own_lon = own.get('lon_deg', 0)
        own_vel_e = own.get('vel_ew_kts', 0) * KTS_TO_FPS
        own_vel_n = own.get('vel_ns_kts', 0) * KTS_TO_FPS
        own_alt = own.get('alt_hae_ft', 0)
        own_dz = own.get('alt_rate_hae_fps', 0)

        for intruder_id, intr in group['intruders'].items():
            int_lat = intr.get('lat_deg', 0)
            int_lon = intr.get('lon_deg', 0)
            int_vel_e = intr.get('vel_ew_kts', 0) * KTS_TO_FPS
            int_vel_n = intr.get('vel_ns_kts', 0) * KTS_TO_FPS
            int_alt = intr.get('alt_hae_ft', intr.get('alt_pres_ft', 0))
            int_dz = 0  # intruder 没有垂直速率数据

            east, north = enu_from_lat_lon(own_lat, own_lon, int_lat, int_lon)
            dx_rel = int_vel_e - own_vel_e
            dy_rel = int_vel_n - own_vel_n
            z_rel = int_alt - own_alt
            dz_rel = int_dz - own_dz

            tau_h = compute_tau_horiz(east, north, dx_rel, dy_rel)
            tau_v = compute_tau_vert(z_rel, dz_rel)
            tau_min = min(tau_h, tau_v)
            cpa_dist = compute_cpa_distance(east, north, dx_rel, dy_rel)
            range_ft = math.sqrt(east**2 + north**2)

            result = {
                'time': t,
                'intruder_id': intruder_id,
                'tau_horiz': tau_h,
                'tau_vert': tau_v,
                'tau_min': tau_min,
                'cpa_dist_ft': cpa_dist,
                'range_ft': range_ft,
                'rel_alt_ft': z_rel,
                'recommended_action': 'H:0 | V:0',
            }

            # 若提供了查询表，则计算 9 维状态并查表获取避障动作
            if lookup_table:
                state_vec = compute_state_vector(own, intr, east, north, range_ft, tau_min)
                discrete_key = discretize_state(*state_vec)
                result['recommended_action'] = find_nearest_action(discrete_key, lookup_table)

            results.append(result)

    return results


def save_csv(results, output_path):
    """保存 tau 结果为 CSV 文件"""
    fieldnames = ['time', 'intruder_id', 'tau_horiz', 'tau_vert', 'tau_min',
                  'cpa_dist_ft', 'range_ft', 'rel_alt_ft', 'recommended_action']
    with open(output_path, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(results)
    print(f"CSV 已保存: {output_path}")


def plot_tau(results, title, output_path, max_tau=120):
    """
    绘制 tau 随时间变化的曲线
    """
    if not HAS_MPL:
        print("matplotlib not available, skipping plot")
        return

    intruder_ids = sorted(set(r['intruder_id'] for r in results))
    intruder_data = {iid: {'t': [], 'tau_h': [], 'tau_v': [], 'tau_min': []}
                     for iid in intruder_ids}

    for r in results:
        iid = r['intruder_id']
        intruder_data[iid]['t'].append(r['time'])
        tau_h = r['tau_horiz'] if r['tau_horiz'] < max_tau else max_tau
        tau_v = r['tau_vert'] if r['tau_vert'] < max_tau else max_tau
        tau_m = r['tau_min'] if r['tau_min'] < max_tau else max_tau
        intruder_data[iid]['tau_h'].append(tau_h)
        intruder_data[iid]['tau_v'].append(tau_v)
        intruder_data[iid]['tau_min'].append(tau_m)

    colors = plt.cm.tab10(np.linspace(0, 1, len(intruder_ids)))

    fig, axes = plt.subplots(3, 1, figsize=(14, 10), sharex=True)

    for idx, iid in enumerate(intruder_ids):
        d = intruder_data[iid]
        color = colors[idx % len(colors)]
        label = f'Intruder {iid}'
        axes[0].plot(d['t'], d['tau_h'], '-o', color=color, markersize=3, label=label, alpha=0.7)
        axes[1].plot(d['t'], d['tau_v'], '-o', color=color, markersize=3, label=label, alpha=0.7)
        axes[2].plot(d['t'], d['tau_min'], '-o', color=color, markersize=3, label=label, alpha=0.7)

    axes[0].set_ylabel('Horizontal Tau (s)')
    axes[0].set_title('Horizontal Tau (Time to CPA)')
    axes[0].set_ylim(0, max_tau)
    axes[0].grid(True, alpha=0.3)
    axes[0].legend(fontsize=8)

    axes[1].set_ylabel('Vertical Tau (s)')
    axes[1].set_title('Vertical Tau (Time to Co-Altitude)')
    axes[1].set_ylim(0, max_tau)
    axes[1].grid(True, alpha=0.3)
    axes[1].legend(fontsize=8)

    axes[2].set_xlabel('Time (s)')
    axes[2].set_ylabel('Min Tau (s)')
    axes[2].set_title('Min Tau (Combined)')
    axes[2].set_ylim(0, max_tau)
    axes[2].grid(True, alpha=0.3)
    axes[2].legend(fontsize=8)

    # 标注警戒线
    for ax in axes:
        ax.axhline(y=35, color='orange', linestyle='--', alpha=0.5, label='TAU Threshold (35s)')
        ax.axhline(y=20, color='red', linestyle='--', alpha=0.5, label='RA Threshold (20s)')

    fig.suptitle(title, fontsize=14)
    plt.tight_layout()
    plt.savefig(output_path, dpi=150)
    plt.close()
    print(f"绘图已保存: {output_path}")


def process_single_encounter(filepath, output_dir='tau_output', lookup_table=None):
    """处理单个 encounter 文件"""
    os.makedirs(output_dir, exist_ok=True)

    basename = os.path.splitext(os.path.basename(filepath))[0]
    print(f"\n处理: {basename}")
    time_groups = parse_encounter(filepath)
    print(f"  时间步数: {len(time_groups)}")
    results = compute_tau_for_time_group(time_groups, lookup_table)
    print(f"  数据点: {len(results)}")

    if not results:
        print("  警告: 没有有效数据")
        return

    csv_path = os.path.join(output_dir, f"{basename}_tau.csv")
    save_csv(results, csv_path)

    plot_path = os.path.join(output_dir, f"{basename}_tau.png")
    plot_tau(results, f"Tau vs Time - {basename}", plot_path)


def process_all_encounters(encounter_dir, output_dir='tau_output', lookup_table=None):
    """处理目录下所有 original encounter 文件"""
    pattern = os.path.join(encounter_dir, 'Encounter*Input.json')
    import glob
    files = sorted(glob.glob(pattern))

    if not files:
        print(f"在 {encounter_dir} 中未找到 Encounter*Input.json 文件")
        return

    print(f"找到 {len(files)} 个 encounter 文件")
    for filepath in files:
        process_single_encounter(filepath, output_dir, lookup_table)


def main():
    parser = argparse.ArgumentParser(description='提取 Encounter 数据的 tau 并绘图')
    parser.add_argument('--encounter', type=str, default=None,
                        help='单个 encounter 文件名 (相对于 original 目录)')
    parser.add_argument('--output', type=str, default='tau_output',
                        help='输出目录 (默认: tau_output)')
    args = parser.parse_args()

    script_dir = os.path.dirname(os.path.abspath(__file__))
    # Search for the original directory in multiple possible locations
    candidates = [
        os.path.join(script_dir, 'example', 'original'),
        os.path.join(script_dir, '..', 'example', 'original'),
        os.path.join(script_dir, '..', 'suma', 'example', 'original'),
        os.path.join(script_dir, 'suma', 'example', 'original'),
        os.path.join(script_dir, '..', '..', 'suma', 'example', 'original'),
        os.path.join(script_dir, '..', '..', '..', 'suma', 'example', 'original'),
        # 尝试 script_dir/../.../ 相对路径
        os.path.join(script_dir, '..', '..', '..', 'suma', 'suma', 'example', 'original'),
        os.path.join(script_dir, '..', '..', 'suma', 'suma', 'example', 'original'),
        os.path.join(script_dir, 'suma', 'suma', 'example', 'original'),
        os.path.join(script_dir, '..', 'suma', 'suma', 'example', 'original'),
    ]
    original_dir = None
    for d in candidates:
        d = os.path.normpath(d)
        if os.path.isdir(d):
            original_dir = d
            break
    if original_dir is None:
        original_dir = os.path.normpath(candidates[0])
        print(f"警告: 未能自动定位 original 目录，使用默认路径: {original_dir}")

    # 加载查询表（查找表路径与脚本同目录）
    lookup_table = load_lookup_table(LOOKUP_TABLE_PATH)

    if args.encounter:
        filepath = os.path.join(original_dir, args.encounter)
        if not os.path.exists(filepath):
            filepath = args.encounter
        if not os.path.exists(filepath):
            print(f"错误: 找不到文件 {filepath}")
            sys.exit(1)
        process_single_encounter(filepath, args.output, lookup_table)
    else:
        process_all_encounters(original_dir, args.output, lookup_table)

    print("\n完成!")


if __name__ == '__main__':
    main()