"""

缺少霍尼韦尔内部库，本文件暂时无法使用

"""


#!/usr/bin/env python3
import json
import os
from os.path import dirname, abspath, join

# 1. 导入您现存的模块（去掉了CASCARA依赖）
from juliainterpreter import JuliaInterpreter
from julia_stm import JuliaSTM
from julia_trm import JuliaTRM

def main():
    # 2. 准备查找表路径 (替换为您的实际路径)
    params_file = './LookupTables/DO-396_paramsfile_acassxu_origami_20220908.txt'
    if not os.path.exists(params_file):
        print(f"找不到查找表: {params_file}")
        return

    # 3. 初始化 Julia 运行时环境
    print("正在启动 Julia 引擎...")
    runtime = JuliaInterpreter("Standalone_Run", history=[])
    
    # 挂载核心业务逻辑
    pkg_dir = dirname(abspath(__file__))
    runtime.use_module('ACAS_sXu', join(pkg_dir, 'ACAS_sXu'))

    # 初始化 STM (监视与跟踪模块) 和 TRM (威胁解析模块)
    stm = JuliaSTM(runtime, params_file)
    trm = JuliaTRM(runtime, params_file, stm.stm_context_variable_name)

    # 4. 加载测试的 Encounter JSON 数据
    input_file = "Encounter1000003Aircraft1Input.json"
    print(f"加载遭遇数据: {input_file} ...")
    events = []
    with open(input_file, 'r') as f:
        for line in f:
            if line.strip():
                events.append(json.loads(line))
                
    # 按时间戳排序事件（保证时序正确）
    events.sort(key=lambda x: x.get('report_time', 0.0))

    import math
    _sxuLastTick = 0

    # 5. 替代 CASCARA 的核心：时间步长循环 (Event Loop)
    print("开始独立仿真推演...")
    
    for report in events:
        report_time = report["report_time"]
        report_type = report["report_type"]
        
        # 解析深层数据 (Acas_sXu_V3R0 格式)
        report_content = report[report_type.lower()]
        data_type = report_content["data_type"]
        report_data = report_content[data_type.lower()]
        
        method_name = None
        
        # --- [核心映射] 将 JSON 的消息类型，转换为 STM 接口的方法调用 ---
        if data_type == "OWNSHIP_DISCRETES":
            if report_type == 'Acas_sXu_V3R0':
                report_data['v2v_uid'] = report_data['remote_id']
                report_data['requested_opmode'] = 3 
                report_data['effective_turn_rate_rad'] = report_data['turn_rate_limit_rad']
                report_data['effective_vert_rate_fps'] = report_data['vert_rate_limit_fps']
                report_data['perform_poa'] = False
                report_data['disable_gpoa'] = False
                report_data['equipment'] = 15
            method_name = 'ReceiveDiscretessXuV4R2'
        elif data_type == "HEADING_OBS":
            method_name = 'ReceiveHeadingObservationV15R2'
        elif data_type == "PRES_ALT_OBS":
            method_name = 'ReceivePresAltObservation'
        elif data_type == "HEIGHT_AGL_OBS":
            method_name = 'ReceiveHeightAglObservation'
        elif data_type == "WGS84_OBS":
            if report_type == 'Acas_sXu_V3R0':
                report_data['vfom_m'] = 8
            method_name = 'ReceiveWgs84ObservationsXuV4R0'
        elif data_type == "VEHICLE_TO_VEHICLE_REPORT":
            if report_type == 'Acas_sXu_V3R0':
                report_data['v2v_uid'] = report_data['remote_id']
                report_data['mode_s'] = report_data['remote_id']
                report_data['mode_s_non_icao'] = False
                report_data['mode_s_valid'] = True 
                report_data['vfom_m'] = 8
                report_data['sil'] = 3
                report_data['sda'] = 1
                report_data['nic'] = 7
                report_data['q_int'] = 1
            method_name = 'ReceiveStateVectorV2VReportsXuV4R2'
        elif data_type in ["EXTERNALLY_VALIDATED_V2V", "EXTERNALLY_VALIDATED_ADSB"]:
            if report_type == 'Acas_sXu_V3R0':
                report_data['v2v_uid'] = report_data.get('remote_id', 0)
            method_name = 'ReceiveExternallyValidatedV2VsXuV4R0' if "V2V" in data_type else 'ReceiveExternallyValidatedADSB'
        
        # 1. 把传感器数据送入系统STM
        if method_name:
            input_call = getattr(stm, method_name, None)
            if input_call:
                input_call(report_data, report_time)
        
        # 2. 判断是不是跨越了 1.0 秒的新周期 (防撞逻辑系统为离散步长计算)
        curTick = math.floor(report_time - 0.00001)
        if curTick > _sxuLastTick:
            _sxuLastTick = curTick
            print(f"--- [Time: {curTick}.0] 分析当前态势与威胁 ---")
            
            # 提取本周期的环境感知(STM)报告
            stm_report = stm.GenerateStmReport(report_time)
            
            # 交给TRM（威胁解析模块）计算是不是快撞击了，产生机动指令
            if trm is not None:
                trm_output = trm.sXuTRMUpdate(f"{stm.stm_report_variable_name}.trm_input")
                # 进行管家回收清理工作
                stm.StmHousekeeping(trm.trm_report_variable_name, report_time)
                
                # 你可以在这里记录本帧系统的避让指令
                # 对于可视化或者打印：
                print("  => TRM指令更新 (建议高度/航向机动): ", trm_output)

    print("仿真结束。")
    # 退出并清理环境
    runtime.__exit__(None, None, None)

if __name__ == '__main__':
    main()