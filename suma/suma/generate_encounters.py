import os
import json
import math
import random
import glob
import re

# 转换常数
KTS_TO_FPS = 1.68781
DEG_TO_RAD = math.pi / 180.0
FT_TO_DEG_LAT = 1.0 / 364567.0  # 极粗略：1纬度 ≈ 364567英尺

def ft_to_deg_lon(ft, lat_deg):
    return ft / (364567.0 * math.cos(lat_deg * DEG_TO_RAD))

def generate_kinematic_encounter(file_name, duration_sec=60, dt=1.0):
    """
    随机生成一次双机遭遇航迹数据，符合 ACAS sXu JSON 输入标准
    """
    # ====== 1. 随机化设定双机初始状态 ======
    # 本机 (Ownship) 初始状态
    own_lat = 40.0
    own_lon = -75.0
    own_alt = random.uniform(500, 5000)
    own_spd_kts = random.uniform(50, 150)
    own_hdg_deg = random.uniform(0, 360)
    own_dz_fps = random.uniform(-10, 10)
    
    # 随机设定入侵机 (Intruder) 相对位置：距离 5000~15000, 高度差 -500~500
    r_initial_ft = random.uniform(5000, 15000)
    b_rad = random.uniform(0, 2 * math.pi)
    int_alt = own_alt + random.uniform(-500, 500)
    # 本机和入侵机的速度分量(东北天坐标系, knots)
    own_vN = own_spd_kts * math.cos(own_hdg_deg * DEG_TO_RAD)
    own_vE = own_spd_kts * math.sin(own_hdg_deg * DEG_TO_RAD)
    
    # 入侵机速度及航向设定，这里故意设定航向直接对准本机飞，以触发避障
    int_spd_kts = random.uniform(50, 150)
    int_hdg_rad = b_rad + math.pi + random.uniform(-0.1, 0.1) # 对向偏角
    int_vN = int_spd_kts * math.cos(int_hdg_rad)
    int_vE = int_spd_kts * math.sin(int_hdg_rad)
    int_dz_fps = random.uniform(-15, 15)

    # 入侵机绝对初始经纬度
    int_lon = own_lon + ft_to_deg_lon(r_initial_ft * math.sin(b_rad), own_lat)
    int_lat = own_lat + r_initial_ft * math.cos(b_rad) * FT_TO_DEG_LAT

    # ====== 2. 模拟步进产生记录 ======
    reports = []
    
    for t in range(int(duration_sec / dt)):
        current_time = float(t) * dt + 0.956  # 稍微错开首帧时间戳
        
        # 匀速线性运动更新物理状态
        own_alt += own_dz_fps * dt
        own_lon += ft_to_deg_lon(own_vE * KTS_TO_FPS * dt, own_lat)
        own_lat += (own_vN * KTS_TO_FPS * dt) * FT_TO_DEG_LAT
        
        int_alt += int_dz_fps * dt
        int_lon += ft_to_deg_lon(int_vE * KTS_TO_FPS * dt, int_lat)
        int_lat += (int_vN * KTS_TO_FPS * dt) * FT_TO_DEG_LAT

        # [本机] 离散属性及观测传感器伪造
        reports.append({"report_time": current_time, "report_type": "Acas_sXu_DO396", "acas_sxu_do396": {"data_type": "OWNSHIP_DISCRETES", "ownship_discretes": {"toa": current_time, "v2v_uid": "111", "opflg": True, "turn_rate_limit_rad": 0.053, "vert_rate_limit_fps": 16.667}}})
        reports.append({"report_time": current_time + 0.001, "report_type": "Acas_sXu_DO396", "acas_sxu_do396": {"data_type": "HEADING_OBS", "heading_obs": {"toa": current_time + 0.001, "psi_rad": own_hdg_deg * DEG_TO_RAD, "heading_degraded": False}}})
        reports.append({"report_time": current_time + 0.002, "report_type": "Acas_sXu_DO396", "acas_sxu_do396": {"data_type": "PRES_ALT_OBS", "pres_alt_obs": {"toa": current_time + 0.002, "alt_pres_ft": own_alt}}})
        reports.append({"report_time": current_time + 0.004, "report_type": "Acas_sXu_DO396", "acas_sxu_do396": {"data_type": "WGS84_OBS", "wgs84_obs": {"toa": current_time + 0.004, "lat_deg": own_lat, "lon_deg": own_lon, "vel_ew_kts": own_vE, "vel_ns_kts": own_vN, "alt_hae_ft": own_alt, "alt_rate_hae_fps": own_dz_fps, "nacp": 10, "nacv": 3, "vfom_m": 8.0}}})

        # [入侵机] 传感器捕捉到的特征伪造
        reports.append({"report_time": current_time + 0.041, "report_type": "Acas_sXu_DO396", "acas_sxu_do396": {"data_type": "VEHICLE_TO_VEHICLE_REPORT", "vehicle_to_vehicle_report": {"toa": current_time + 0.041, "v2v_uid": "100", "mode_s": 100, "lat_deg": int_lat, "lon_deg": int_lon, "vel_ns_kts": int_vN, "vel_ew_kts": int_vE, "alt_pres_ft": int_alt, "alt_hae_ft": int_alt, "nic": 7, "nacp": 10, "nacv": 2, "sil": 3, "sda": 1, "q_int": 1, "classification": 1}}})

    # ====== 3. 封装输出 ======
    output_json = {
        "playback_header": {
            "description": {"text": "Auto-Generated Kinematic Encounter for Query Table Building"},
            "start_time": 0.0, "has_timing_control": False
        },
        "acasx_reports": reports
    }

    with open(file_name, 'w', encoding='utf-8') as f:
        json.dump(output_json, f, indent=4)
    print(f"航迹生成完毕: {file_name}，内含 {len(reports)} 条传感器通信。")

if __name__ == "__main__":
    # 动态获取当前脚本所在目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    
    # 路径拼接：直接连同级目录下的 "example" 文件夹
    example_dir = os.path.join(script_dir, "example")
    
    # 如果 example 文件夹不存在则自动创建，防止报错
    os.makedirs(example_dir, exist_ok=True)
    
    # ====== 新增自动推断起始序号的逻辑 ======
    max_index = 0
    # 遍历现有文件寻找最大编号
    for filename in os.listdir(example_dir):
        # 匹配形如 AutoGen_Encounter_0001.json 的文件名
        match = re.match(r"AutoGen_Encounter_(\d+)\.json", filename)
        if match:
            # 提取数字部分并更新最大值
            idx = int(match.group(1))
            if idx > max_index:
                max_index = idx
                
    start_index = max_index + 1
    num_to_generate = 100  # 假设你每次想新生成 10 个测试文件
    
    # 从 start_index 接着生成
    for i in range(start_index, start_index + num_to_generate):
        filename = os.path.join(example_dir, f"AutoGen_Encounter_{i:04d}.json")
        generate_kinematic_encounter(filename, duration_sec=40, dt=1.0)
