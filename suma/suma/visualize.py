import csv
import sys
import numpy as np
import matplotlib.pyplot as plt

# ----------------- 解决中文显示问题 -----------------
plt.rcParams['font.sans-serif'] = ['SimHei', 'Microsoft YaHei', 'Arial Unicode MS'] # 优先使用黑体或雅黑
plt.rcParams['axes.unicode_minus'] = False # 正常显示负号
# ----------------------------------------------------

# --- 动作字典映射 (方便人类阅读) ---
H_ACTION_MAP = {
    0: "NO ADVISORY (安全)",
    1: "CLEAR OF CONFLICT (解除)",
    2: "TURN RIGHT (向右转)",
    3: "TURN LEFT (向左转)",
    4: "STRAIGHT (保持直飞)"
}

# [新增处]: 垂直动作字典映射
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

# --- 离散化网格设置 (务必与 probe_table.jl 中保持绝对一致) ---
RANGE_BIN     = 500.0
ALT_BIN       = 100.0
BEARING_BIN   = 30.0
HEADING_BIN   = 30.0
INT_SPEED_BIN = 50.0
OWN_SPEED_BIN = 50.0
V_RATE_BIN    = 10.0
TAU_BIN       = 5.0

def discretize_state(r, z, b, psi, int_spd, own_spd, own_dz, int_dz, tau):
    """将连续物理状态转换为完整的 9 维离散状态元组"""
    # [修改点1]: 动态不均匀 Range 划分, 且设置下边界为 100.0 ft
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
    
    # [修改点2]: Tau 的最高保底和最低兜底 5.0
    tau_bin = 100.0 if tau >= 100.0 else round(tau / TAU_BIN) * TAU_BIN
    tau_bin = max(TAU_BIN, tau_bin)
    
    return (r_bin, a_bin, b_bin, psi_bin, int_spd_bin, own_spd_bin, own_dz_bin, int_dz_bin, tau_bin)

def load_lookup_table(csv_path):
    """从 CSV 加载轻量化查询表为内存字典"""
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

def parse_action_str(action_str):
    """解析 'H:2 | V:4' 返回水平动作和垂直动作编号"""
    try:
        parts = action_str.split("|")
        h_code = int(parts[0].split(":")[1].strip())
        v_code = int(parts[1].split(":")[1].strip())
        return h_code, v_code
    except:
        return 0, 0

def plot_polar_state(state, action_str="H:0 | V:0", max_range_plot=5000):
    """极坐标水平空间渲染"""
    (r, z_rel, bearing_deg, psi_deg, 
     int_spd, own_spd, own_dz, int_dz, tau) = state

    # 先离散化，只用于绘图显示网格边界
    discrete_key = discretize_state(*state)
    r_bin, _, b_bin = discrete_key[0], discrete_key[1], discrete_key[2]

    # [修改处]: 获取 h_code 和 v_code
    h_code, v_code = parse_action_str(action_str)
    h_text = H_ACTION_MAP.get(h_code, f"UNKNOWN({h_code})")
    v_text = V_ACTION_MAP.get(v_code, f"UNKNOWN({v_code})")

    fig, ax = plt.subplots(figsize=(8, 8), subplot_kw={'projection': 'polar'})
    ax.set_theta_zero_location("N")
    ax.set_theta_direction(-1)
    
    # 画网格背景
    # [修改点] 动态适配放大的雷达盘刻度
    if max_range_plot <= 1000:
        step = 100.0
        label_step = 200.0  # 每 200 显示一次字符以防拥挤
    elif max_range_plot <= 3000:
        step = 500.0
        label_step = 500.0
    else:
        step = 500.0
        label_step = 1000.0
        
    r_ticks = np.arange(0, max_range_plot + step, step)
    ax.set_yticks(r_ticks)
    ax.set_yticklabels([str(int(i)) if i % label_step == 0 else "" for i in r_ticks], color='gray', size=8)
    
    theta_ticks = np.arange(0, 360, BEARING_BIN)
    ax.set_xticks(np.radians(theta_ticks))
    
    # 目标真实落点
    target_theta = np.radians(bearing_deg if bearing_deg >= 0 else bearing_deg + 360)
    
    # 网格掩码边界
    # [修改点3]: 动态适应新的非均匀 Range 网格的绘制跨度
    if r_bin <= 500.0:
        range_span = 100.0
        # 特殊处理：如果是最小 100 的网格，里面画到0，外面画到150
        if r_bin == 100.0:
            r_inner = 0.0
            r_outer = 150.0 # 100.0 + 50.0
        else:
            r_inner = r_bin - range_span / 2
            r_outer = r_bin + range_span / 2
    elif r_bin <= 2000.0:
        range_span = 500.0
        # 如果刚好衔接在 500 处，内侧和 100区间的要拼上
        if r_bin == 500.0:
            r_inner = 450.0 # 500以内的精度是100，所以内侧边界画到 450
            r_outer = 750.0 # (500 + 250)
        else:
            r_inner = r_bin - range_span / 2
            r_outer = r_bin + range_span / 2
    else:
        range_span = 1000.0
        if r_bin == 2000.0:
            r_inner = 1750.0
            r_outer = 2500.0
        else:
            r_inner = r_bin - range_span / 2
            r_outer = r_bin + range_span / 2
            
    r_inner = max(0, r_inner) # 确保内圆不小于0
    
    # 确保中心角度被转换为 0-360 的绝对正角度
    theta_center_deg = float(b_bin) % 360.0
    
    # 计算起始和结束角度
    theta_start_deg = theta_center_deg - (BEARING_BIN / 2)
    theta_end_deg = theta_center_deg + (BEARING_BIN / 2)
    
    # 转换为弧度
    theta_start = np.radians(theta_start_deg)
    theta_end = np.radians(theta_end_deg)
    
    # 高亮颜色（收到水平机动发红，不机动发绿）
    highlight_color = 'red' if h_code in [2, 3] else 'lightgreen'
    
    # 处理扇区跨越 0 度（或跨越 360 度）的问题
    if theta_start_deg < 0:
        # 扇区跨越了正北方向（例如从 345° 到 15°）
        # 需要分成两块画
        theta_fill_1 = np.linspace(theta_start + 2*np.pi, 2*np.pi, 25)
        theta_fill_2 = np.linspace(0, theta_end, 25)
        ax.fill_between(theta_fill_1, r_inner, r_outer, color=highlight_color, alpha=0.4)
        ax.fill_between(theta_fill_2, r_inner, r_outer, color=highlight_color, alpha=0.4, label='Active State Bin')
    elif theta_end_deg > 360:
        # 同理，如果上限超了 360（逻辑上其实和上面等价，但看取余情况）
        theta_fill_1 = np.linspace(theta_start, 2*np.pi, 25)
        theta_fill_2 = np.linspace(0, theta_end - 2*np.pi, 25)
        ax.fill_between(theta_fill_1, r_inner, r_outer, color=highlight_color, alpha=0.4)
        ax.fill_between(theta_fill_2, r_inner, r_outer, color=highlight_color, alpha=0.4, label='Active State Bin')
    else:
        # 正常的、没有跨越边界的扇区
        theta_fill = np.linspace(theta_start, theta_end, 50)
        ax.fill_between(theta_fill, r_inner, r_outer, color=highlight_color, alpha=0.4, label='Active State Bin')
    
    # 绘制两机位置
    ax.scatter(0, 0, c='blue', s=200, zorder=5, label='Ownship')
    ax.scatter(target_theta, r, c='red', s=100, marker='x', zorder=5, label='Intruder (Exact)')

    # 绘制航向箭头
    arrow_length = max_range_plot * 0.2
    target_x_cart = r * np.sin(target_theta)
    target_y_cart = r * np.cos(target_theta)
    target_abs_heading_rad = np.radians(psi_deg if psi_deg >= 0 else psi_deg + 360)
    target_end_x_cart = target_x_cart + arrow_length * np.sin(target_abs_heading_rad)
    target_end_y_cart = target_y_cart + arrow_length * np.cos(target_abs_heading_rad)
    
    theta_end_arrow = np.arctan2(target_end_x_cart, target_end_y_cart)
    r_end_arrow = np.hypot(target_end_x_cart, target_end_y_cart)
    
    ax.annotate('',
                xy=(theta_end_arrow, r_end_arrow),
                xytext=(target_theta, r),
                arrowprops=dict(facecolor='red', edgecolor='red', shrink=0.0, width=1.5, headwidth=6),
                zorder=4)

    # 标签配置
    # [修改处]: 将垂直动作追加到标题中
    plt.title(f"Horizontal State Space (Polar)\nAction: {action_str}\n  H: {h_text}\n  V: {v_text}", 
              fontsize=13, fontweight='bold', pad=20)
    
    info_text = (
        f"Real State:\n"
        f"  Range: {r} ft\n"
        f"  Bearing: {bearing_deg}°\n"
        f"  Psi: {psi_deg}°\n\n"
        f"Discretized Into:\n"
        f"  Range Bin: {r_bin}\n"
        f"  Bearing Bin: {b_bin}°"
    )
    plt.text(-0.15, -0.1, info_text, transform=ax.transAxes, fontsize=10,
             bbox=dict(facecolor='white', alpha=0.8, edgecolor='gray'))

    ax.set_ylim(0, max_range_plot)
    ax.legend(loc='lower right', bbox_to_anchor=(1.3, 0.0))
    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    # 加载 CSV 查询表
    csv_file = "d:/workforce/project/suma/suma/my_lightweight_table.csv"
    table = load_lookup_table(csv_file)
    
    # === 测试场景 ===
    # 状态: (距离, 相高, 方位, 偏航, 目标速, 本机速, 本机升降, 目标升降, Tau)
    state = (3000.0, -100.0, 0.0, 180.0, 50.0, 50.0, 20.0, 20.0, 40.0)
    
    # 动态查表，缺省时默认为 H:0 | V:0
    discrete_key = discretize_state(*state)
    action = table.get(discrete_key, "H:0 | V:0")
    
    print(f"查表得到的动作为: {action}")
    print("绘制极坐标状态图...")
    
    # [修改点]: 动态调整图表的缩放大小，使得高亮区域可见
    target_r = state[0]
    if target_r <= 500.0:
        plot_range = 800  # 极近距离时，只画半径 800，这样 150-250 的高亮扇区就非常明显了
    elif target_r <= 2000.0:
        plot_range = 2500
    else:
        plot_range = 5000
        
    plot_polar_state(state, action, max_range_plot=plot_range)