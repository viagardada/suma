
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


def compute_tau_for_time_group(time_groups):
    """
    对每个时间组计算 tau 值
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

            results.append({
                'time': t,
                'intruder_id': intruder_id,
                'tau_horiz': tau_h,
                'tau_vert': tau_v,
                'tau_min': tau_min,
                'cpa_dist_ft': cpa_dist,
                'range_ft': range_ft,
                'rel_alt_ft': z_rel,
            })

    return results


def save_csv(results, output_path):
    """保存 tau 结果为 CSV 文件"""
    fieldnames = ['time', 'intruder_id', 'tau_horiz', 'tau_vert', 'tau_min',
                  'cpa_dist_ft', 'range_ft', 'rel_alt_ft']
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


def process_single_encounter(filepath, output_dir='tau_output'):
    """处理单个 encounter 文件"""
    os.makedirs(output_dir, exist_ok=True)

    basename = os.path.splitext(os.path.basename(filepath))[0]
    print(f"\n处理: {basename}")
    time_groups = parse_encounter(filepath)
    print(f"  时间步数: {len(time_groups)}")
    results = compute_tau_for_time_group(time_groups)
    print(f"  数据点: {len(results)}")

    if not results:
        print("  警告: 没有有效数据")
        return

    csv_path = os.path.join(output_dir, f"{basename}_tau.csv")
    save_csv(results, csv_path)

    plot_path = os.path.join(output_dir, f"{basename}_tau.png")
    plot_tau(results, f"Tau vs Time - {basename}", plot_path)


def process_all_encounters(encounter_dir, output_dir='tau_output'):
    """处理目录下所有 original encounter 文件"""
    pattern = os.path.join(encounter_dir, 'Encounter*Input.json')
    import glob
    files = sorted(glob.glob(pattern))

    if not files:
        print(f"在 {encounter_dir} 中未找到 Encounter*Input.json 文件")
        return

    print(f"找到 {len(files)} 个 encounter 文件")
    for filepath in files:
        process_single_encounter(filepath, output_dir)


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

    if args.encounter:
        filepath = os.path.join(original_dir, args.encounter)
        if not os.path.exists(filepath):
            filepath = args.encounter
        if not os.path.exists(filepath):
            print(f"错误: 找不到文件 {filepath}")
            sys.exit(1)
        process_single_encounter(filepath, args.output)
    else:
        process_all_encounters(original_dir, args.output)

    print("\n完成!")


if __name__ == '__main__':
    main()