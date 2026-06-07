import csv
import sys
import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

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

#  垂直动作字典映射
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
    
    # [修改点2]: Tau 处理：tau < 0（两机正在远离）强制赋值为 -1，否则正常离散化
    if tau < 0:
        tau_bin = -1.0
    else:
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
    """ 'H:2 | V:4' 返回水平动作和垂直动作编号"""
    try:
        parts = action_str.split("|")
        h_code = int(parts[0].split(":")[1].strip())
        v_code = int(parts[1].split(":")[1].strip())
        return h_code, v_code
    except:
        return 0, 0

def plot_polar_state(state, action_str="H:0 | V:0", max_range_plot=5000):
    """联合展示：左侧为极坐标水平空间，右侧为二维垂直剖面"""
    (r, z_rel, bearing_deg, psi_deg, 
     int_spd, own_spd, own_dz, int_dz, tau) = state

    # 离散化获取网格边界
    discrete_key = discretize_state(*state)
    r_bin, a_bin, b_bin = discrete_key[0], discrete_key[1], discrete_key[2]

    # 获取 h_code 和 v_code
    h_code, v_code = parse_action_str(action_str)
    h_text = H_ACTION_MAP.get(h_code, f"UNKNOWN({h_code})")
    v_text = V_ACTION_MAP.get(v_code, f"UNKNOWN({v_code})")

    # 创建 1行2列 的画布
    fig = plt.figure(figsize=(16, 8))
    
    # ==========================================
    # 子图1：水平方向极坐标图 (左侧)
    # ==========================================
    ax1 = fig.add_subplot(1, 2, 1, projection='polar')
    ax1.set_theta_zero_location("N")
    ax1.set_theta_direction(-1)
    
    # 画网格背景
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
    
    # 扇形高亮填充
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
    target_abs_heading_rad = np.radians(psi_deg if psi_deg >= 0 else psi_deg + 360)
    target_end_x_cart = r * np.sin(target_theta) + arrow_length * np.sin(target_abs_heading_rad)
    target_end_y_cart = r * np.cos(target_theta) + arrow_length * np.cos(target_abs_heading_rad)
    
    ax1.annotate('',
                xy=(np.arctan2(target_end_x_cart, target_end_y_cart), np.hypot(target_end_x_cart, target_end_y_cart)),
                xytext=(target_theta, r),
                arrowprops=dict(facecolor='red', edgecolor='red', shrink=0.0, width=1.5, headwidth=6), zorder=4)

    ax1.set_ylim(0, max_range_plot)
    ax1.set_title(f"Horizontal Control (Polar)\nH: {h_text}", fontsize=12, fontweight='bold', pad=15)
    
    # ==========================================
    # 子图2：垂直方向二维图 (右侧)
    # ==========================================
    ax2 = fig.add_subplot(1, 2, 2)
    ax2.grid(True, linestyle='--', alpha=0.6)
    
    # 计算相对高度的上下边界（离散网格边界）
    alt_bottom = a_bin - ALT_BIN / 2
    alt_top = a_bin + ALT_BIN / 2
    
    # 垂直建议高亮颜色：如果有特定控制指令 (v_code >= 2)，显示红色表示警告或干预
    v_highlight_color = 'red' if v_code >= 2 else 'lightgreen'
    
    # 矩形区域 (Range_inner -> Range_outer, Alt_bottom -> Alt_top)
    rect = Rectangle((r_inner, alt_bottom), (r_outer - r_inner), (alt_top - alt_bottom),
                     color=v_highlight_color, alpha=0.4, label='V-State Bin')
    ax2.add_patch(rect)
    
    # 绘制两机位置 (横轴是距离，纵轴是本机的相对高度)
    ax2.scatter(0, 0, c='blue', s=200, zorder=5, label='Ownship')
    ax2.scatter(r, z_rel, c='red', s=100, marker='x', zorder=5, label='Intruder')
    
    # 用箭头展示两机的垂直升降趋势（时间尺度放大，假设 5秒 的趋势）
    time_scale = 5.0
    ax2.annotate('', xy=(r, z_rel + int_dz * time_scale), xytext=(r, z_rel),
                 arrowprops=dict(facecolor='red', edgecolor='red', width=1.5, headwidth=6), zorder=4)
    ax2.annotate('', xy=(0, own_dz * time_scale), xytext=(0, 0),
                 arrowprops=dict(facecolor='blue', edgecolor='blue', width=1.5, headwidth=6), zorder=4)

    # 动态适应垂直Y轴和水平X轴范围
    max_alt_plot = max(abs(z_rel) + 300, 1000)
    ax2.set_xlim(-100, max_range_plot)
    ax2.set_ylim(-max_alt_plot, max_alt_plot)
    
    ax2.set_xlabel("Horizontal Range (ft)", fontsize=11)
    ax2.set_ylabel("Relative Altitude (ft)", fontsize=11)
    ax2.axhline(0, color='black', linewidth=1, zorder=1) # 本机高度基准线
    ax2.set_title(f"Vertical Profile (Range vs Rel-Alt)\nV: {v_text}", fontsize=12, fontweight='bold', pad=15)
    
    # ==========================================
    # 全局信息和图例
    # ==========================================
    fig.suptitle(f"State Rendering for Collision Avoidance\nAction: {action_str}", fontsize=14, fontweight='bold')
    
    info_text = (
        f"Real State:\n"
        f"  Range: {r} ft\n"
        f"  Rel Alt: {z_rel} ft\n"
        f"  Bearing: {bearing_deg}°\n"
        f"  Psi: {psi_deg}°\n\n"
        f"Discretized Into:\n"
        f"  Range Bin: {r_bin}\n"
        f"  Bearing Bin: {b_bin}°\n"
        f"  Alt Bin: {a_bin} ft"
    )
    plt.figtext(0.02, 0.05, info_text, fontsize=10, bbox=dict(facecolor='white', alpha=0.9, edgecolor='gray'))

    ax1.legend(loc='lower right', bbox_to_anchor=(1.35, 0.0))
    ax2.legend(loc='upper right')
    
    plt.tight_layout()
    # 调整一点顶部间距以便放下总标题
    plt.subplots_adjust(top=0.88, bottom=0.15) 
    plt.show()

if __name__ == "__main__":
    # 加载 CSV 查询表
    csv_file = "d:/workforce/project/suma/suma/my_lightweight_table.csv"
    table = load_lookup_table(csv_file)
    
    # === 测试场景 ===
    # 状态: (距离, 相高, 方位, 偏航, 目标速, 本机速, 本机升降, 目标升降, Tau)
    state = (1500.0, -200.0, 90.0, -150.0, 200.0, 350.0, 20.0, 20.0, 10.0)
    
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