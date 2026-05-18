import csv
import sys

# ---------------------------------------------------------
# 1. 离散化网格设置 (务必与 probe_table.jl 中保持绝对一致)
# ---------------------------------------------------------
RANGE_BIN     = 500.0
ALT_BIN       = 100.0
BEARING_BIN   = 30.0
HEADING_BIN   = 30.0
INT_SPEED_BIN = 50.0
OWN_SPEED_BIN = 50.0
V_RATE_BIN    = 10.0
TAU_BIN       = 5.0

def discretize_state(r, z, b, psi, int_spd, own_spd, own_dz, int_dz, tau):
    """将连续物理状态转换为离散状态"""
    r_bin = round(r / RANGE_BIN) * RANGE_BIN
    a_bin = round(z / ALT_BIN) * ALT_BIN
    
    b_bin = round(b / BEARING_BIN) * BEARING_BIN
    if b_bin > 180.0: b_bin -= 360.0
        
    psi_bin = round(psi / HEADING_BIN) * HEADING_BIN
    if psi_bin > 180.0: psi_bin -= 360.0
        
    int_spd_bin = round(int_spd / INT_SPEED_BIN) * INT_SPEED_BIN
    own_spd_bin = round(own_spd / OWN_SPEED_BIN) * OWN_SPEED_BIN
    
    own_dz_bin = round(own_dz / V_RATE_BIN) * V_RATE_BIN
    int_dz_bin = round(int_dz / V_RATE_BIN) * V_RATE_BIN
    
    tau_bin = 100.0 if tau >= 100.0 else round(tau / TAU_BIN) * TAU_BIN
    
    return (r_bin, a_bin, b_bin, psi_bin, int_spd_bin, own_spd_bin, own_dz_bin, int_dz_bin, tau_bin)

# ---------------------------------------------------------
# 2. 从 CSV 加载轻量化查询表为内存字典
# ---------------------------------------------------------
def load_lookup_table(csv_path):
    lookup_table = {}
    try:
        with open(csv_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                # 构建 9 维 Tuple 作为 Key
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

# ---------------------------------------------------------
# 3. 决策主逻辑
# ---------------------------------------------------------
def get_action(lookup_table, raw_state):
    """
    输入 raw_state: (距离, 相高, 方位角, 偏航角, 目标速, 本机速, 本机垂速, 目标垂速, Tau)
    输出 action_str (默认缺省值为 H:0 | V:0 即无告警)
    """
    # 获取离散化索引格子
    discrete_key = discretize_state(*raw_state)
    
    # 查表，若无此极端状态的记录，则默认无危险动作
    action = lookup_table.get(discrete_key, "H:0 | V:0")
    
    return action, discrete_key

# ---------------------------------------------------------
# 4. 测试与演示
# ---------------------------------------------------------
if __name__ == "__main__":
    csv_file = "d:/workforce/project/suma/suma/my_lightweight_table.csv"
    table = load_lookup_table(csv_file)
    
    # === 构建一个模拟的当前状态 ===
    # 你可以把这里替换为实时传感器喂进来的数据
    test_states = [
        # (距离, 相高,   方位, 偏航, 目标速,本机速,本机升降,目标升降,  Tau)
        (3100.0, 50.0,   12.0, 170.0, 48.0,  52.0,   0.0,    0.0,    14.2), # 危险逼近
        (10000.0, 500.0, 90.0, 90.0,  100.0, 100.0,  0.0,    0.0,    80.0)  # 安全距离
    ]
    
    for i, state in enumerate(test_states):
        print(f"\n--- 测试场景 {i+1} ---")
        print(f"原始传感器输入 : {state}")
        
        action, disc_key = get_action(table, state)
        
        print(f"离散化网格坐标 : {disc_key}")
        print(f"最终输出动作   : {action}")