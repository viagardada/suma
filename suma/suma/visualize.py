import csv
import sys
import json
import math
import numpy as np
from collections import Counter
try:
    from scipy.spatial import KDTree
    _HAS_SCIPY = True
except ModuleNotFoundError:
    _HAS_SCIPY = False
    print("警告: 未安装 scipy，k-NN 功能不可用，使用 1-NN 搜索")
    print("如需 k-NN 功能: D:\\workforce\\anaconda\\python.exe visualize.py --knn")
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
from matplotlib.animation import FuncAnimation, PillowWriter

# ----------------- 解决中文显示问题 -----------------
plt.rcParams['font.sans-serif'] = ['SimHei', 'Microsoft YaHei', 'Arial Unicode MS']
plt.rcParams['axes.unicode_minus'] = False
# ----------------------------------------------------

# --- 动作字典映射 ---
H_ACTION_MAP = {
    0: "NO ADVISORY (安全)",
    1: "CLEAR OF CONFLICT (解除)",
    2: "TURN RIGHT (向右转)",
    3: "TURN LEFT (向左转)",
    4: "STRAIGHT (保持直飞)"
}

V_ACTION_MAP = {
    0: "NO ADVISORY (安全/维持)",
    1: "CLEAR OF CONFLICT (解除)",
    2: "DO NOT CLIMB (禁止爬升)",
    3: "DO NOT DESCEND (禁止下降)",
    4: "CLIMB (建议爬升)",
    5: "DESCEND (建议下降)",
    6: "CROSSING CLIMB (交叉爬升)",
    7: "CROSSING DESCEND (交叉下降)"
}

# --- 离散化网格设置 ---
RANGE_BIN     = 500.0
ALT_BIN       = 100.0
BEARING_BIN   = 30.0
HEADING_BIN   = 30.0
INT_SPEED_BIN = 50.0
OWN_SPEED_BIN = 50.0
V_RATE_BIN    = 10.0
TAU_BIN       = 5.0

KT_TO_FPS = 1.68781
RAD_TO_DEG = 180.0 / math.pi


# ---------- 各维度权重（用于加权距离计算） ----------
#
# 权重设计原则：使每个维度变化一个 bin 步长时，对距离的贡献大致均衡。
# 当前权重的问题是 Range(500ft步长) 完全淹没了 Bearing(30°步长) 和 Tau(5s步长)，
# 因为 1×500² >> 0.5×30²，Range 的影响是 Bearing 的 555 倍。
#
# 修正方案：权重 = 重要度 / (bin步长)²
#   重要度：Range=5, Alt=3, Bearing=2, Heading=2, Speed=1, VertRate=2, Tau=10
#   这样每个维度变化一个 bin 步长时，距离贡献 ≈ 重要度
#
# 经测试，变一个 bin 步长的贡献为:
#   Range(500ft):    5    (基准)
#   Bearing(30°):    2    (适中)
#   Tau(5s):        10    (最高)
#   各项大致在同一个数量级
#
# 权重计算: w_i = importance_i / (bin_step_i)²
WEIGHTS = [     #         bin_step  importance  w = imp/bin²
    0.000020,  # Range:    500 ft     x5     = 5/250000
    0.000300,  # Alt:      100 ft     x3     = 3/10000
    0.002222,  # Bearing:   30 deg    x2     = 2/900
    0.002222,  # Heading:   30 deg    x2     = 2/900
    0.000400,  # Int_Speed: 50 fps    x1     = 1/2500
    0.000400,  # Own_Speed: 50 fps    x1     = 1/2500
    0.020000,  # Own_Vert:  10 fps    x2     = 2/100
    0.020000,  # Int_Vert:  10 fps    x2     = 2/100
    0.400000,  # Tau:        5 s      x10    = 10/25
]
#
# 对比：变化一个 bin 步长的距离贡献
#   旧权重  Range=250000 vs Bearing=450 (555x差距)
#   新权重  Range=5      vs Bearing=2   (2.5x差距)
#


class KNNLookup:
    """
    基于 KDTree 的 k-NN 加权投票查询器。
    对水平动作 (H) 和垂直动作 (V) 分别使用距离倒数加权投票。
    """
    def __init__(self, lookup_table, k=5, weights=None):
        """
        参数:
            lookup_table: dict, {9元组状态: "H:x | V:y"}
            k: int, 最近邻个数
            weights: list of 9 floats, 各维度权重（None 则使用默认值）
        """
        if weights is None:
            weights = WEIGHTS
        self.k = min(k, max(1, len(lookup_table)))
        self.sqrt_w = np.sqrt(weights)
        
        # 解析出所有状态和动作
        self.keys = list(lookup_table.keys())
        self.actions = [lookup_table[k] for k in self.keys]
        
        # 预解析 H/V 代码
        self.h_codes = []
        self.v_codes = []
        for act in self.actions:
            h, v = parse_action_str(act)
            self.h_codes.append(h)
            self.v_codes.append(v)
        
        # 构建加权 KDTree
        arr = np.array(self.keys, dtype=np.float64) * self.sqrt_w
        self.tree = KDTree(arr)
        print(f"  KNNLookup: k={self.k}, {len(self.keys)} 个参考点")
    
    def query(self, state_9tuple):
        """返回 k-NN 加权投票后的动作字符串"""
        action, _, _ = self.query_with_conf(state_9tuple)
        return action
    
    def query_with_conf(self, state_9tuple):
        """
        返回 k-NN 加权投票后的动作和置信度。
        
        返回:
            (action_str, h_conf, v_conf)
            action_str: "H:3 | V:5"
            h_conf: float, 0~1, H 动作的置信度（最高票占比）
            v_conf: float, 0~1, V 动作的置信度
        """
        # 加权查询
        query_vec = np.array(state_9tuple, dtype=np.float64) * self.sqrt_w
        distances, indices = self.tree.query(query_vec, k=self.k)
        
        if self.k == 1:
            return self.actions[indices[0]], 1.0, 1.0
        
        # 距离倒数加权（加小量避免除零）
        eps = 1e-10
        if isinstance(distances, np.ndarray):
            weights = 1.0 / (distances + eps)
        else:
            weights = np.array([1.0 / (distances + eps)])
        
        total_weight = np.sum(weights)
        
        # --- H 投票 ---
        h_weight = {}
        for i, idx in enumerate(indices):
            h = self.h_codes[idx]
            h_weight[h] = h_weight.get(h, 0.0) + weights[i]
        best_h = max(h_weight, key=h_weight.get)
        h_conf = h_weight[best_h] / total_weight if total_weight > 0 else 0.0
        
        # --- V 投票 ---
        v_weight = {}
        for i, idx in enumerate(indices):
            v = self.v_codes[idx]
            v_weight[v] = v_weight.get(v, 0.0) + weights[i]
        best_v = max(v_weight, key=v_weight.get)
        v_conf = v_weight[best_v] / total_weight if total_weight > 0 else 0.0
        
        return f"H:{best_h} | V:{best_v}", h_conf, v_conf


def discretize_state(r, z, b, psi, int_spd, own_spd, own_dz, int_dz, tau):
    """将连续物理状态转换为完整的 9 维离散状态元组"""
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
    
    if tau < 0:
        tau_bin = -1.0
    else:
        tau_bin = 100.0 if tau >= 100.0 else round(tau / TAU_BIN) * TAU_BIN
        tau_bin = max(TAU_BIN, tau_bin)
    
    return (r_bin, a_bin, b_bin, psi_bin, int_spd_bin, own_spd_bin, own_dz_bin, int_dz_bin, tau_bin)


def load_lookup_table(csv_path):
    """从 CSV 加载轻量化查询表为内存字典，并预先索引用于最近邻搜索"""
    lookup_table = {}
    try:
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
                lookup_table[key] = row['Recommended_Action']
    except FileNotFoundError:
        print(f"找不到文件: {csv_path}")
        sys.exit(1)
        
    print(f"成功加载查询表，共包含 {len(lookup_table)} 条决策规则。")
    return lookup_table


def find_nearest_action(state_9tuple, lookup_table):
    """
    在查找表中找到与给定状态最接近的条目的动作。
    使用加权欧几里得距离，对各维度赋予不同权重。
    """
    keys = list(lookup_table.keys())
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
    
    return lookup_table.get(best_key, "H:0 | V:0")


def parse_action_str(action_str):
    """'H:2 | V:4' -> (h_code, v_code)"""
    try:
        parts = action_str.split("|")
        h_code = int(parts[0].split(":")[1].strip())
        v_code = int(parts[1].split(":")[1].strip())
        return h_code, v_code
    except:
        return 0, 0


def parse_example_file(filepath):
    """
    解析 example JSON 文件，提取每个时间戳下的完整状态。
    
    返回:
        timestamps: list of float
        states: list of 9-tuple (r, z_rel, bearing, psi, int_spd, own_spd, own_dz, int_dz, tau)
    """
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    reports = data.get('acasx_reports', [])
    if not reports:
        print(f"错误：文件中没有 acasx_reports 数据")
        sys.exit(1)
    
    # 按 report_time 分组
    time_groups = {}
    for report in reports:
        t = report.get('report_time', 0.0)
        t_rounded = round(t * 10) / 10.0
        if t_rounded not in time_groups:
            time_groups[t_rounded] = []
        time_groups[t_rounded].append(report)
    
    sorted_times = sorted(time_groups.keys())
    
    # 缓存上一个已知值
    last_own_alt = 0.0
    last_own_vel_ns_kts = 0.0
    last_own_vel_ew_kts = 0.0
    last_own_alt_rate_fps = 0.0
    last_heading_rad = 0.0
    last_int_vel_ns_kts = 0.0
    last_int_vel_ew_kts = 0.0
    last_int_alt_rate_fps = 0.0
    
    states = []
    timestamps = []
    stopped_at_cpa = False  # 是否已过最近点
    had_positive_tau = False  # 是否有过正的tau值
    
    for t in sorted_times:
        # 如果已经过了最近点（开始远离）且是最佳演示部分，不再添加
        if stopped_at_cpa:
            continue
        group = time_groups[t]
        
        heading_rad = last_heading_rad
        own_vel_ns_kts = last_own_vel_ns_kts
        own_vel_ew_kts = last_own_vel_ew_kts
        own_alt_rate_fps = last_own_alt_rate_fps
        int_vel_ns_kts = last_int_vel_ns_kts
        int_vel_ew_kts = last_int_vel_ew_kts
        int_alt_rate_fps = last_int_alt_rate_fps
        
        range_ft = None
        rel_z_ft = None
        azimuth_rad = None
        dgr_fps = None
        
        # 用于经纬度计算
        own_lat_deg = None
        own_lon_deg = None
        own_alt_ft = None
        int_lat_deg = None
        int_lon_deg = None
        int_alt_ft = None
        int_vel_ns_from_v2v = None
        int_vel_ew_from_v2v = None
        
        for report in group:
            rtype = report.get('report_type', '')
            # 兼容两种报告格式：Acas_sXu_DO396 和 Acas_sXu_V3R0
            if rtype not in ('Acas_sXu_DO396', 'Acas_sXu_V3R0'):
                continue
            payload = report.get('acas_sxu_do396') or report.get('acas_sxu_v3r0') or {}
            dtype = payload.get('data_type', '')
            
            if dtype == 'HEADING_OBS':
                psi_val = payload.get('heading_obs', {}).get('psi_rad', last_heading_rad)
                heading_rad = psi_val if psi_val != '_NaN_' else heading_rad
                last_heading_rad = heading_rad
                
            elif dtype == 'WGS84_OBS':
                wgs = payload.get('wgs84_obs', {})
                own_lat_deg = wgs.get('lat_deg', None)
                own_lon_deg = wgs.get('lon_deg', None)
                own_alt_ft = wgs.get('alt_hae_ft', None)
                own_vel_ns_kts = wgs.get('vel_ns_kts', last_own_vel_ns_kts)
                own_vel_ew_kts = wgs.get('vel_ew_kts', last_own_vel_ew_kts)
                alt_rate = wgs.get('alt_rate_hae_fps', last_own_alt_rate_fps)
                own_alt_rate_fps = alt_rate if alt_rate != '_NaN_' else own_alt_rate_fps
                last_own_vel_ns_kts = own_vel_ns_kts
                last_own_vel_ew_kts = own_vel_ew_kts
                last_own_alt_rate_fps = own_alt_rate_fps
                
            elif dtype == 'PRES_ALT_OBS':
                pa = payload.get('pres_alt_obs', {})
                alt_val = pa.get('alt_pres_ft', None)
                if alt_val is not None and alt_val != '_NaN_':
                    own_alt_ft = alt_val
                    
            elif dtype == 'VEHICLE_TO_VEHICLE_REPORT':
                v2v = payload.get('vehicle_to_vehicle_report', {})
                int_lat_deg = v2v.get('lat_deg', int_lat_deg)
                int_lon_deg = v2v.get('lon_deg', int_lon_deg)
                alt_pres = v2v.get('alt_pres_ft', None)
                if alt_pres is not None and alt_pres != '_NaN_':
                    int_alt_ft = alt_pres
                # 从V2V中提取入侵机速度
                vn = v2v.get('vel_ns_kts', None)
                ve = v2v.get('vel_ew_kts', None)
                if vn is not None and vn != '_NaN_':
                    int_vel_ns_from_v2v = vn
                if ve is not None and ve != '_NaN_':
                    int_vel_ew_from_v2v = ve
                    
            elif dtype == 'OWN_REL_NON_COOP_TRACK':
                track = payload.get('own_rel_non_coop_track', {})
                rng = track.get('range_ft', None)
                az = track.get('azimuth_rad', None)
                dgr = track.get('dgr_fps', None)
                rel_z = track.get('rel_z_ft', None)
                if rng is not None and rng != '_NaN_':
                    range_ft = rng
                if az is not None and az != '_NaN_':
                    azimuth_rad = az
                if dgr is not None and dgr != '_NaN_':
                    dgr_fps = dgr
                if rel_z is not None and rel_z != '_NaN_':
                    rel_z_ft = rel_z
                rel_dz = track.get('rel_dz_fps', None)
                if rel_dz is not None and rel_dz != '_NaN_':
                    int_alt_rate_fps = own_alt_rate_fps + rel_dz
                    last_int_alt_rate_fps = int_alt_rate_fps
                    
            elif dtype == 'ABSOLUTE_GEODETIC_TRACK':
                agt = payload.get('absolute_geodetic_track', {})
                vel_ns = agt.get('vel_ns_kts', last_int_vel_ns_kts)
                vel_ew = agt.get('vel_ew_kts', last_int_vel_ew_kts)
                if vel_ns != '_NaN_' and vel_ew != '_NaN_':
                    int_vel_ns_kts = vel_ns
                    int_vel_ew_kts = vel_ew
                    last_int_vel_ns_kts = int_vel_ns_kts
                    last_int_vel_ew_kts = int_vel_ew_kts
                alt_rate_pres = agt.get('alt_rate_pres_fps', None)
                if alt_rate_pres is not None and alt_rate_pres != '_NaN_':
                    int_alt_rate_fps = alt_rate_pres
                    last_int_alt_rate_fps = int_alt_rate_fps
        
        # 如果没有直接 track 数据，尝试从经纬度计算
        if range_ft is None or azimuth_rad is None:
            if own_lat_deg is not None and own_lon_deg is not None and int_lat_deg is not None and int_lon_deg is not None:
                # 使用近似公式计算距离和方位
                lat1 = math.radians(own_lat_deg)
                lon1 = math.radians(own_lon_deg)
                lat2 = math.radians(int_lat_deg)
                lon2 = math.radians(int_lon_deg)
                
                dlat = lat2 - lat1
                dlon = lon2 - lon1
                
                # Haversine 距离（单位：米）
                a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
                c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
                R_earth_m = 6371000.0
                dist_m = R_earth_m * c
                range_ft = dist_m * 3.28084  # 米转英尺
                
                # 方位角（正北为0，顺时针）
                az_rad = math.atan2(math.sin(dlon) * math.cos(lat2),
                                    math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dlon))
                azimuth_rad = az_rad
                
                # 相对高度
                if own_alt_ft is not None and int_alt_ft is not None:
                    rel_z_ft = int_alt_ft - own_alt_ft
                else:
                    rel_z_ft = 0.0
                
                # 如果从 V2V 获取了入侵机速度，更新
                if int_vel_ns_from_v2v is not None:
                    int_vel_ns_kts = int_vel_ns_from_v2v
                    last_int_vel_ns_kts = int_vel_ns_kts
                if int_vel_ew_from_v2v is not None:
                    int_vel_ew_kts = int_vel_ew_from_v2v
                    last_int_vel_ew_kts = int_vel_ew_kts
        
        if range_ft is None or azimuth_rad is None:
            continue
        
        bearing_deg = azimuth_rad * RAD_TO_DEG
        psi_deg = heading_rad * RAD_TO_DEG
        
        own_spd = math.hypot(own_vel_ns_kts, own_vel_ew_kts) * KT_TO_FPS
        if own_spd < 1.0:
            own_spd = 100.0
        
        int_spd = math.hypot(int_vel_ns_kts, int_vel_ew_kts) * KT_TO_FPS
        if int_spd < 1.0:
            int_spd = 100.0
        
        z_rel = rel_z_ft if rel_z_ft is not None else 0.0
        own_dz = own_alt_rate_fps
        int_dz = int_alt_rate_fps
        
        # 计算入侵者相对于本机的运动方向（相对速度方向）
        # 极坐标角度：0°=正北，顺时针
        rel_vel_ns = int_vel_ns_kts - own_vel_ns_kts
        rel_vel_ew = int_vel_ew_kts - own_vel_ew_kts
        int_rel_heading_deg = math.atan2(rel_vel_ew, rel_vel_ns) * RAD_TO_DEG
        
        # 如果有直接的 dgr_fps（来自 track 数据），直接计算 tau
        if dgr_fps is not None and dgr_fps < 0 and range_ft > 0:
            tau = range_ft / (-dgr_fps)
        else:
            # 尝试用相邻帧的距离差估算接近率（适用于无 track 数据的 V3R0 文件）
            tau = -1.0
            if len(states) > 0 and len(timestamps) > 0:
                prev_range = states[-1][0]
                prev_t = timestamps[-1]
                dt = t - prev_t
                if dt > 0:
                    # 计算接近率（正值表示距离在缩小）
                    dgr_est = (prev_range - range_ft) / dt
                    if dgr_est > 0 and range_ft > 0:
                        tau = range_ft / dgr_est
        
        state = (range_ft, z_rel, bearing_deg, psi_deg,
                 int_spd, own_spd, own_dz, int_dz, tau, int_rel_heading_deg)
        states.append(state)
        timestamps.append(t)
        
        # 检测最近点（CPA）：用实际 range 变化判断
        # 当 range 开始增大（从接近变为远离）时停止截断
        if range_ft is not None and len(states) >= 2:
            prev_range = states[-2][0]
            if range_ft > prev_range and len(states) > 1:
                stopped_at_cpa = True
    
    print(f"成功解析 example 文件，共提取 {len(states)} 个时间步。")
    if timestamps:
        print(f"时间范围: {timestamps[0]:.1f}s ~ {timestamps[-1]:.1f}s")
    else:
        print("警告：未提取到任何有效状态数据（可能文件中没有 OWN_REL_NON_COOP_TRACK 数据）")
    
    return timestamps, states


def plot_polar_state(ax1, ax2, state, action_str="H:0 | V:0", max_range_plot=5000,
                     info_text_extra=""):
    """联合展示：左侧为极坐标水平空间，右侧为二维垂直剖面"""
    (r, z_rel, bearing_deg, psi_deg, 
     int_spd, own_spd, own_dz, int_dz, tau, int_rel_heading_deg) = state

    discrete_key = discretize_state(*state[:9])
    r_bin, a_bin, b_bin = discrete_key[0], discrete_key[1], discrete_key[2]

    h_code, v_code = parse_action_str(action_str)
    h_text = H_ACTION_MAP.get(h_code, f"UNKNOWN({h_code})")
    v_text = V_ACTION_MAP.get(v_code, f"UNKNOWN({v_code})")
    
    ax1.clear()
    ax2.clear()
    
    # ---- 子图1：极坐标水平方向 ----
    ax1.set_theta_zero_location("N")
    ax1.set_theta_direction(-1)
    
    if max_range_plot <= 1000:
        step = 100.0
        label_step = 200.0
    elif max_range_plot <= 3000:
        step = 500.0
        label_step = 500.0
    else:
        step = 500.0
        label_step = 1000.0
        
    r_ticks = np.arange(0, max_range_plot + step, step)
    ax1.set_yticks(r_ticks)
    ax1.set_yticklabels([str(int(i)) if i % label_step == 0 else "" for i in r_ticks], color='gray', size=8)
    
    theta_ticks = np.arange(0, 360, BEARING_BIN)
    ax1.set_xticks(np.radians(theta_ticks))
    
    target_theta = np.radians(bearing_deg if bearing_deg >= 0 else bearing_deg + 360)
    
    # 动态适应非均匀 Range 网格
    if r_bin <= 500.0:
        range_span = 100.0
        if r_bin == 100.0:
            r_inner, r_outer = 0.0, 150.0
        else:
            r_inner, r_outer = r_bin - range_span / 2, r_bin + range_span / 2
    elif r_bin <= 2000.0:
        range_span = 500.0
        if r_bin == 500.0:
            r_inner, r_outer = 450.0, 750.0
        else:
            r_inner, r_outer = r_bin - range_span / 2, r_bin + range_span / 2
    else:
        range_span = 1000.0
        if r_bin == 2000.0:
            r_inner, r_outer = 1750.0, 2500.0
        else:
            r_inner, r_outer = r_bin - range_span / 2, r_bin + range_span / 2
            
    r_inner = max(0, r_inner)
    
    theta_center_deg = float(b_bin) % 360.0
    theta_start = np.radians(theta_center_deg - (BEARING_BIN / 2))
    theta_end = np.radians(theta_center_deg + (BEARING_BIN / 2))
    
    h_highlight_color = 'red' if h_code in [2, 3] else 'lightgreen'
    
    if (theta_center_deg - BEARING_BIN / 2) < 0:
        ax1.fill_between(np.linspace(theta_start + 2*np.pi, 2*np.pi, 25), r_inner, r_outer, color=h_highlight_color, alpha=0.4)
        ax1.fill_between(np.linspace(0, theta_end, 25), r_inner, r_outer, color=h_highlight_color, alpha=0.4, label='H-State Bin')
    elif (theta_center_deg + BEARING_BIN / 2) > 360:
        ax1.fill_between(np.linspace(theta_start, 2*np.pi, 25), r_inner, r_outer, color=h_highlight_color, alpha=0.4)
        ax1.fill_between(np.linspace(0, theta_end - 2*np.pi, 25), r_inner, r_outer, color=h_highlight_color, alpha=0.4, label='H-State Bin')
    else:
        ax1.fill_between(np.linspace(theta_start, theta_end, 50), r_inner, r_outer, color=h_highlight_color, alpha=0.4, label='H-State Bin')
    
    ax1.scatter(0, 0, c='blue', s=200, zorder=5, label='Ownship')
    ax1.scatter(target_theta, r, c='red', s=100, marker='x', zorder=5, label='Intruder')

    arrow_length = max_range_plot * 0.2
    # int_rel_heading_deg 是相对速度方向（极坐标角度：0°=正北，顺时针）
    arrow_theta_rad = np.radians(int_rel_heading_deg if int_rel_heading_deg >= 0 else int_rel_heading_deg + 360)
    target_end_x_cart = r * np.sin(target_theta) + arrow_length * np.sin(arrow_theta_rad)
    target_end_y_cart = r * np.cos(target_theta) + arrow_length * np.cos(arrow_theta_rad)
    
    ax1.annotate('',
                xy=(np.arctan2(target_end_x_cart, target_end_y_cart), np.hypot(target_end_x_cart, target_end_y_cart)),
                xytext=(target_theta, r),
                arrowprops=dict(facecolor='red', edgecolor='red', shrink=0.0, width=1.5, headwidth=6), zorder=4)

    ax1.set_ylim(0, max_range_plot)
    ax1.set_title(f"Horizontal Control (Polar)\nH: {h_text}", fontsize=12, fontweight='bold', pad=15)
    
    # ---- 子图2：垂直剖面 ----
    ax2.grid(True, linestyle='--', alpha=0.6)
    
    alt_bottom = a_bin - ALT_BIN / 2
    alt_top = a_bin + ALT_BIN / 2
    
    v_highlight_color = 'red' if v_code >= 2 else 'lightgreen'
    
    rect = Rectangle((r_inner, alt_bottom), (r_outer - r_inner), (alt_top - alt_bottom),
                     color=v_highlight_color, alpha=0.4, label='V-State Bin')
    ax2.add_patch(rect)
    
    ax2.scatter(0, 0, c='blue', s=200, zorder=5, label='Ownship')
    ax2.scatter(r, z_rel, c='red', s=100, marker='x', zorder=5, label='Intruder')
    
    time_scale = 5.0
    ax2.annotate('', xy=(r, z_rel + int_dz * time_scale), xytext=(r, z_rel),
                 arrowprops=dict(facecolor='red', edgecolor='red', width=1.5, headwidth=6), zorder=4)
    ax2.annotate('', xy=(0, own_dz * time_scale), xytext=(0, 0),
                 arrowprops=dict(facecolor='blue', edgecolor='blue', width=1.5, headwidth=6), zorder=4)

    max_alt_plot = max(abs(z_rel) + 300, 1000)
    ax2.set_xlim(-100, max_range_plot)
    ax2.set_ylim(-max_alt_plot, max_alt_plot)
    
    ax2.set_xlabel("Horizontal Range (ft)", fontsize=11)
    ax2.set_ylabel("Relative Altitude (ft)", fontsize=11)
    ax2.axhline(0, color='black', linewidth=1, zorder=1)
    ax2.set_title(f"Vertical Profile (Range vs Rel-Alt)\nV: {v_text}", fontsize=12, fontweight='bold', pad=15)
    
    ax1.legend(loc='lower right', bbox_to_anchor=(1.35, 0.0), fontsize=8)
    ax2.legend(loc='upper right', fontsize=8)
    
    tau_display = "999.0" if tau < 0 else f"{tau:.1f}"
    tau_label = " (SAFE)" if tau < 0 else "s"
    info_lines = [
        f"Real State:",
        f"  Range: {r:.1f} ft ({r*0.3048:.1f} m)",
        f"  Rel Alt: {z_rel:.1f} ft",
        f"  Bearing: {bearing_deg:.1f}°",
        f"  Psi: {psi_deg:.1f}°",
        f"  Tau: {tau_display}{tau_label}",
        f"",
        f"Discretized Into:",
        f"  Range Bin: {r_bin} ft",
        f"  Bearing Bin: {b_bin}°",
        f"  Alt Bin: {a_bin} ft",
    ]
    if info_text_extra:
        info_lines.append("")
        info_lines.append(info_text_extra)
    return "\n".join(info_lines)


def draw_risk_gauge(ax, tau, range_ft, z_rel):
    """在指定坐标轴上绘制数字式风险仪表盘"""
    ax.clear()
    
    # 计算三个风险因子 (0~1, 1=最危险)
    if tau < 0:
        tau_risk = 0.1
    elif tau < 15:
        tau_risk = 1.0
    elif tau < 35:
        tau_risk = 1.0 - (tau - 15) / 20.0 * 0.6
    else:
        tau_risk = 0.4 - min(tau - 35, 40) / 40.0 * 0.3
        tau_risk = max(0.1, tau_risk)
    
    abs_range = abs(range_ft)
    if abs_range < 1000:
        range_risk = 1.0
    elif abs_range < 3000:
        range_risk = 1.0 - (abs_range - 1000) / 2000.0 * 0.6
    else:
        range_risk = 0.4 - min(abs_range - 3000, 2000) / 2000.0 * 0.3
        range_risk = max(0.05, range_risk)
    
    abs_z = abs(z_rel)
    if abs_z < 100:
        alt_risk = 0.8
    elif abs_z < 500:
        alt_risk = 0.8 - (abs_z - 100) / 400.0 * 0.5
    else:
        alt_risk = 0.3 - min(abs_z - 500, 500) / 500.0 * 0.2
        alt_risk = max(0.05, alt_risk)
    
    risk = tau_risk * 0.5 + range_risk * 0.3 + alt_risk * 0.2
    risk = min(1.0, max(0.0, risk))
    risk_pct = risk * 100
    
    # 判断风险等级
    if risk_pct >= 70:
        level_text = "危险"
        level_color = '#FF1744'
        bg_color = '#FFEBEE'
    elif risk_pct >= 40:
        level_text = "注意"
        level_color = '#FF9100'
        bg_color = '#FFF3E0'
    else:
        level_text = "安全"
        level_color = '#00C853'
        bg_color = '#E8F5E9'
    
    # 绘制数字式仪表盘背景
    rect = plt.Rectangle((-0.9, -0.6), 1.8, 1.4, facecolor=bg_color, 
                          edgecolor=level_color, linewidth=3)
    ax.add_patch(rect)
    
    # 风险百分比大字
    ax.text(0, 0.50, f'{risk_pct:.0f}%', ha='center', va='center',
            fontsize=42, fontweight='bold', color=level_color)
    
    # 风险等级标签
    ax.text(0, 0.15, f'[ {level_text} ]', ha='center', va='center',
            fontsize=16, fontweight='bold', color=level_color,
            bbox=dict(facecolor='white', edgecolor=level_color, pad=5))
    
    # 关键指标
    tau_str = f'{tau:.1f}s' if tau > 0 else '远离中'
    ax.text(0, -0.12, f'τ: {tau_str}', ha='center', va='center',
            fontsize=13, fontweight='bold', color='#333')
    ax.text(0, -0.30, f'距离: {range_ft:.0f} ft', ha='center', va='center',
            fontsize=12, color='#555')
    ax.text(0, -0.47, f'相对高度: {z_rel:.0f} ft', ha='center', va='center',
            fontsize=12, color='#555')
    
    ax.set_xlim(-1, 1)
    ax.set_ylim(-0.65, 1.05)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title("Collision Risk Gauge", fontsize=12, fontweight='bold', pad=10)
    
    return risk


def animate_example(timestamps, states, actions, interval=500, output_gif=None,
                    h_confs=None, v_confs=None):
    """使用 matplotlib 动画播放示例文件的所有时间步状态图
    如果 output_gif 指定了路径，则保存为 GIF 而非显示窗口
    """
    show_conf = h_confs is not None and v_confs is not None
    max_range = max(s[0] for s in states) * 1.2
    if max_range <= 800:
        plot_range = 800
    elif max_range <= 2500:
        plot_range = 2500
    else:
        plot_range = 5000
    
    # 预提取所有 tau 值（-1 替换为 999 以便在折线图上显示为"安全"）
    all_taus = [999.0 if s[8] < 0 else s[8] for s in states]  # tau 是 state 的第9个元素
    
    fig = plt.figure(figsize=(16, 10))
    # 2x2 网格: 极坐标, 垂直剖面, tau折线图, 风险仪表盘
    ax1 = fig.add_subplot(2, 2, 1, projection='polar')
    ax2 = fig.add_subplot(2, 2, 2)
    ax3 = fig.add_subplot(2, 2, 3)
    ax4 = fig.add_subplot(2, 2, 4)
    
    info_text_obj = plt.figtext(0.02, 0.88, "", fontsize=10, va='top',
                                bbox=dict(facecolor='white', alpha=0.9, edgecolor='gray'))
    suptitle_obj = fig.suptitle("", fontsize=14, fontweight='bold')
    
    def update(frame_idx):
        state = states[frame_idx]
        action = actions[frame_idx]
        t = timestamps[frame_idx]
        
        info_extra = f"Frame: {frame_idx + 1}/{len(states)} | t = {t:.1f}s"
        
        # 如果有置信度数据，追加到信息中
        if show_conf:
            hc = h_confs[frame_idx] * 100
            vc = v_confs[frame_idx] * 100
            hc_label = "HIGH" if hc >= 80 else ("MED" if hc >= 50 else "LOW")
            vc_label = "HIGH" if vc >= 80 else ("MED" if vc >= 50 else "LOW")
            info_extra += f"\n  H Conf: {hc:.1f}% ({hc_label})"
            info_extra += f"\n  V Conf: {vc:.1f}% ({vc_label})"
        
        info_text = plot_polar_state(ax1, ax2, state, action,
                                     max_range_plot=plot_range,
                                     info_text_extra=info_extra)
        
        # 更新 tau 折线图
        ax3.clear()
        times_sofar = timestamps[:frame_idx + 1]
        taus_sofar = all_taus[:frame_idx + 1]
        
        ax3.plot(times_sofar, taus_sofar, 'b-o', markersize=4, linewidth=1.5, label='τ (s)')
        ax3.axhline(y=0, color='gray', linestyle='--', linewidth=0.8)
        ax3.plot(t, all_taus[frame_idx], 'ro', markersize=8, zorder=5)
        
        ax3.set_xlim(timestamps[0], timestamps[-1])
        # 分离安全 tau(999) 和真实 tau 值，避免 999 把 y 轴拉到很大
        safe_taus = [v for v in all_taus if v >= 100]
        real_taus = [v for v in all_taus if 0 < v < 100]
        if real_taus:
            y_min = min(-2, min(real_taus) - 2)
            y_max = max(10, max(real_taus) + 5)
        else:
            y_min = -2
            y_max = 10
        ax3.set_ylim(y_min, y_max)
        
        ax3.set_xlabel("Time (s)", fontsize=11)
        ax3.set_ylabel("τ (seconds)", fontsize=11)
        ax3.set_title("Tau Over Time", fontsize=12, fontweight='bold')
        ax3.grid(True, linestyle='--', alpha=0.6)
        ax3.legend(loc='upper right', fontsize=9)
        
        # 更新风险仪表盘
        r, z_rel, _, _, _, _, _, _, tau_val, _ = state
        draw_risk_gauge(ax4, tau_val, r, z_rel)
        
        info_text_obj.set_text(info_text)
        suptitle_obj.set_text(f"Encounter Playback — Time: {t:.1f}s\nRecommended Action: {action}")
        
        return ax1, ax2, ax3, ax4, info_text_obj, suptitle_obj
    
    ani = FuncAnimation(fig, update, frames=len(states),
                        interval=interval, repeat=True, blit=False)
    
    plt.tight_layout()
    plt.subplots_adjust(top=0.85, bottom=0.05)
    
    if output_gif:
        fps = 1000 / interval
        print(f"正在保存 GIF 到 {output_gif} ({len(states)} 帧, {fps:.1f} fps)...")
        ani.save(output_gif, writer=PillowWriter(fps=fps))
        print("GIF 保存完成！")
        plt.close(fig)
    else:
        print(f"开始播放动画 ({len(states)} 帧, {interval}ms 间隔)...")
        print("关闭窗口退出")
        plt.show()
    return ani


if __name__ == "__main__":
    # ============================================================
    # 【更换轨迹文件】只需修改下面 EXAMPLE_FILE 的路径即可
    # ============================================================
    EXAMPLE_FILE = "D:/workforce/project/suma/suma/suma/example/generated/AutoGen_Encounter_0002.json"
    # ============================================================
    
    # 加载查询表
    csv_file = "d:/workforce/project/suma/suma/my_lightweight_table_dense.csv"

    table = load_lookup_table(csv_file)
    
    # 确定输入文件（命令行参数优先）
    if len(sys.argv) > 1 and not sys.argv[1].startswith("--"):
        example_file = sys.argv[1]
    else:
        example_file = EXAMPLE_FILE
    
    interval = 200
    for arg in sys.argv[1:]:
        if arg.startswith("--interval="):
            try:
                interval = int(arg.split("=")[1])
            except:
                pass
    print(f"解析 example 文件: {example_file}")
    timestamps, states = parse_example_file(example_file)
    
    if len(states) == 0:
        print("错误：未能提取任何有效状态数据")
        sys.exit(1)
    
    # ---- 解析命令行参数 ----
    knn_k = 5  # 默认 k-NN 的 k 值
    use_knn = False
    for arg in sys.argv[1:]:
        if arg.startswith("--knn"):
            use_knn = True
            if "=" in arg:
                try:
                    knn_k = int(arg.split("=")[1])
                except:
                    pass
    
    # ---- 构建查询器 ----
    if use_knn:
        if not _HAS_SCIPY:
            print("错误: 未安装 scipy，无法使用 k-NN 功能")
            print("      请安装: pip install scipy")
            print("      或用 Anaconda Python 运行")
            sys.exit(1)
        print(f"使用 k-NN 加权投票 (k={knn_k})")
        lookup = KNNLookup(table, k=knn_k)
    else:
        print("使用 1-NN 最近邻匹配（加 --knn 可切换为 k-NN 加权投票）")
        lookup = table  # 原字典作为 fallback
    
    # 查表获取每个时间步的推荐动作（及置信度）
    actions = []
    h_confs = []
    v_confs = []
    for state in states:
        discrete_key = discretize_state(*state[:9])
        if use_knn:
            action, hc, vc = lookup.query_with_conf(discrete_key)
            actions.append(action)
            h_confs.append(hc)
            v_confs.append(vc)
        else:
            action = find_nearest_action(discrete_key, lookup)
            actions.append(action)
            h_confs.append(1.0)  # 1-NN 默认置信度 100%
            v_confs.append(1.0)
    
    matched = sum(1 for s, a in zip(states, actions) if table.get(discretize_state(*s[:9]), None) is not None)
    print(f"精确匹配: {matched}/{len(states)} 帧, 其余使用最近邻匹配")
    
    output_gif = None
    show_conf = use_knn  # 只在 k-NN 模式下显示置信度
    for arg in sys.argv[1:]:
        if arg.startswith("--output-gif="):
            output_gif = arg.split("=")[1]
        if arg == "--show-conf":
            show_conf = True
    
    print(f"共 {len(states)} 帧，间隔 {interval}ms")
    if show_conf and use_knn:
        avg_hc = sum(h_confs) / len(h_confs) * 100
        avg_vc = sum(v_confs) / len(v_confs) * 100
        print(f"平均置信度: H={avg_hc:.1f}%, V={avg_vc:.1f}%")
    
    # 播放动画或保存为 GIF
    animate_example(timestamps, states, actions, interval=interval, output_gif=output_gif,
                    h_confs=h_confs if show_conf else None,
                    v_confs=v_confs if show_conf else None)
