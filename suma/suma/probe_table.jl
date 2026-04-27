# 导入内置 JSON 解析库
using JSON
using Printf

println("正在启动 Julia 探测模块 ...")

# 引入底层的防撞逻辑核心模块
include("D:/workforce/project/suma/suma/suma/ACAS_sXu/ACAS_sXu.jl")
using .ACAS_sXu

function safe_parse_uint128(val)
    if typeof(val) <: AbstractString
        return parse(UInt128, val)
    else
        return UInt128(val)
    end
end

# [增强点 1] 扩充轻量化表的维度为 6 维: 
# Tuple{距离, 相对高度, 方位角, 相对垂直速率, 入侵者地速, 本机地速}
global lightweight_table = Dict{Tuple{Float64, Float64, Float64, Float64, Float64, Float64}, String}()

# [增强点 2] 离散化网格设置
const RANGE_BIN     = 500.0   # 距离: 每 500 ft 归为一类
const ALT_BIN       = 100.0   # 相高: 每 100 ft 归为一类
const BEARING_BIN   = 30.0    # 方位: 每 30° 归为一类
const DZ_REL_BIN    = 10.0    # 相对垂直速率: 每 10 ft/s 归为一类
const INT_SPEED_BIN = 50.0    # 入侵者地速 (新增): 每 50 ft/s 归为一类
const OWN_SPEED_BIN = 50.0    # 本机地速: 每 50 ft/s 归为一类 

# 更新 discretize_state 支持新增的 int_spd 参数
function discretize_state(r::Float64, z::Float64, b::Float64, dz::Float64, int_spd::Float64, own_spd::Float64)
    r_bin = round(r / RANGE_BIN) * RANGE_BIN
    a_bin = round(z / ALT_BIN) * ALT_BIN
    b_bin = round(b / BEARING_BIN) * BEARING_BIN
    if b_bin > 180.0
        b_bin -= 360.0
    end
    dz_bin = round(dz / DZ_REL_BIN) * DZ_REL_BIN
    int_spd_bin = round(int_spd / INT_SPEED_BIN) * INT_SPEED_BIN
    own_spd_bin = round(own_spd / OWN_SPEED_BIN) * OWN_SPEED_BIN
    return (r_bin, a_bin, b_bin, dz_bin, int_spd_bin, own_spd_bin)
end

function extract_threat_state(trm_input::ACAS_sXu.TRMInput)
    if !isempty(trm_input.intruder)
        int_display = trm_input.intruder[1].stm_display
        own_info    = trm_input.own
        
        r_ground    = isnan(int_display.r_ground_ft) ? 0.0 : int_display.r_ground_ft
        z_rel       = isnan(int_display.z_rel_ft) ? 0.0 : int_display.z_rel_ft
        
        # [增强点 3] 提取方位角 (入侵者方位角) -> 已有
        b_rad       = isnan(int_display.bearing_rel_rad) ? 0.0 : int_display.bearing_rel_rad
        bearing_deg = b_rad * (180.0 / π)
        
        dz_rel      = isnan(int_display.dz_rel_fps) ? 0.0 : int_display.dz_rel_fps
        
        # [增强点 4] 提取本机地速 (本机无人机水平速度) -> 已有
        own_speed   = isnan(own_info.ground_speed) ? 0.0 : own_info.ground_speed

        # [增强点 5] 解算入侵者绝对水平速度 (新增)
        # 1. 提取相对水平速度组件 (基于ENU坐标系)
        dx_rel_fps = isnan(int_display.dx_rel_fps) ? 0.0 : int_display.dx_rel_fps # 东西方向
        dy_rel_fps = isnan(int_display.dy_rel_fps) ? 0.0 : int_display.dy_rel_fps # 南北方向
        # 2. 提取本机航迹角
        track_angle = isnan(own_info.track_angle) ? 0.0 : own_info.track_angle
        # 3. 将本机地速分解到东西南北，算出入侵者绝对速度分量
        own_vE = own_speed * sin(track_angle)
        own_vN = own_speed * cos(track_angle)
        int_vE = dx_rel_fps + own_vE
        int_vN = dy_rel_fps + own_vN
        # 4. 合成计算目标绝对地速
        int_speed = hypot(int_vE, int_vN)
        
        return (r_ground, z_rel, bearing_deg, dz_rel, int_speed, own_speed)
    end
    return (NaN, NaN, NaN, NaN, NaN, NaN)
end

function run_probe(input_file::String, params_file::String)
    println("初始化防撞模块 STM & TRM...")
    stm = ACAS_sXu.STM(params_file)
    trm = ACAS_sXu.TRM(params_file, stm) 
    trm_state = ACAS_sXu.sXuTRMState()

    println("加载推演剧本: $input_file")
    parsed_json = JSON.parsefile(input_file)
    
    if haskey(parsed_json, "acasx_reports")
        reports = parsed_json["acasx_reports"]
    elseif typeof(parsed_json) <: AbstractArray
        reports = parsed_json
    else
        println("错误: JSON 数据中找不到 acasx_reports 结构！")
        return
    end

    sort!(reports, by = x -> get(x, "report_time", 0.0))
    _sxuLastTick = 0

    for report in reports
        report_time = report["report_time"]
        report_type = report["report_type"]
        report_content = report[lowercase(report_type)]
        data_type = report_content["data_type"]
        data = report_content[lowercase(data_type)]
        
        if data_type == "OWNSHIP_DISCRETES"
            uid_val = haskey(data, "v2v_uid") ? data["v2v_uid"] : get(data, "remote_id", 0)
            ACAS_sXu.ReceiveDiscretes(stm, safe_parse_uint128(uid_val), 
                Bool(data["opflg"]), UInt8(3), Float64(get(data, "turn_rate_limit_rad", 0.053)), Float64(get(data, "vert_rate_limit_fps", 16.667)), 
                Bool(get(data, "surv_only_disp_on", false)), false, false, UInt8(15))
        elseif data_type == "WGS84_OBS"
            ACAS_sXu.ReceiveWgs84Observation(stm, Float64(data["lat_deg"]), Float64(data["lon_deg"]), 
                Float64(data["vel_ew_kts"]), Float64(data["vel_ns_kts"]), Float64(data["alt_hae_ft"]), 
                Float64(data["alt_rate_hae_fps"]), UInt32(data["nacp"]), UInt32(data["nacv"]), Float64(8.0), Float64(data["toa"]))
        elseif data_type == "HEADING_OBS"
            ACAS_sXu.ReceiveHeadingObservation(stm, Float64(data["psi_rad"]), Float64(data["toa"]), Bool(data["heading_degraded"]))
        elseif data_type == "PRES_ALT_OBS"
            ACAS_sXu.ReceivePresAltObservation(stm, Float64(data["alt_pres_ft"]), Float64(data["toa"]))
        elseif data_type == "HEIGHT_AGL_OBS"
            ACAS_sXu.ReceiveHeightAglObservation(stm, Float64(data["h_ft"]))
        elseif data_type == "EXTERNALLY_VALIDATED_V2V"
            uid_val = haskey(data, "v2v_uid") ? data["v2v_uid"] : get(data, "remote_id", 0)
            ACAS_sXu.ReceiveExternallyValidatedV2V(stm, Bool(data["externally_validated"]), safe_parse_uint128(uid_val))
        elseif data_type == "VEHICLE_TO_VEHICLE_REPORT"
            uid_val = haskey(data, "v2v_uid") ? data["v2v_uid"] : get(data, "remote_id", 0)
            ACAS_sXu.ReceiveStateVectorV2VReport(stm, Float64(data["lat_deg"]), Float64(data["lon_deg"]), 
                haskey(data, "alt_pres_ft") ? Float64(data["alt_pres_ft"]) : NaN, Float64(data["alt_hae_ft"]), 
                Float64(data["vel_ew_kts"]), Float64(data["vel_ns_kts"]), UInt32(get(data, "nic", 6)), UInt32(get(data, "nacp", 7)), UInt32(get(data, "nacv", 1)), 
                Float64(get(data, "vfom_m", 8.0)), UInt32(get(data, "sil", 1)), UInt32(get(data, "sda", 2)), safe_parse_uint128(uid_val), 
                UInt32(get(data, "mode_s", 0)), Bool(get(data, "mode_s_non_icao", false)), Bool(get(data, "mode_s_valid", true)), UInt8(get(data, "classification", 1)), UInt32(get(data, "q_int", 25)), Float64(data["toa"]))
        end
        
        curTick = floor(Int, report_time - 0.00001)
        if curTick > _sxuLastTick
            _sxuLastTick = curTick
            
            stm_report = ACAS_sXu.GenerateStmReport(stm, report_time)
            
            # [修改处]: 解包提取更多的状态
            r_ground, z_rel, b_deg, dz_rel, int_spd, own_spd = extract_threat_state(stm_report.trm_input)
            trm_report = ACAS_sXu.sXuTRMUpdate(trm, trm_state, stm_report.trm_input)
            ACAS_sXu.StmHousekeeping(stm, trm_report)
            
            if !isnan(r_ground)
                # 将五维状态转换为离散格子
                key = discretize_state(r_ground, z_rel, b_deg, dz_rel, int_spd, own_spd)
                
                adv_str = "H:" * string(trm_report.display_horiz.cc) * " | V:" * string(trm_report.display_vert.cc)
                
                if !haskey(lightweight_table, key) || adv_str != "H:0 | V:0"
                    lightweight_table[key] = adv_str
                end
                
                @printf("[Time %4d] 距离:%04.0fft | 相高:%+4.0fft | 方位:%+4.0f° | 垂速:%+3.0ffps | 目标地速:%03.0ffps | 本机地速:%03.0ffps => %s\n", 
                        curTick, key[1], key[2], key[3], key[4], key[5], key[6], adv_str)
            end
        end
    end
end

function export_csv(out_path::String)
    open(out_path, "w") do f
        # 更新表头以反映五个维度
        write(f, "Range(ft),Rel_Altitude(ft),Bearing(deg),Rel_Vertical_Rate(fps),Intruder_Speed(fps),Own_Speed(fps),Recommended_Action\n")
        
        # 排序输出：依次优先按 距离、相对高度、方位角、等 排序
        curr_keys = sort(collect(keys(lightweight_table)))
        for key in curr_keys
            r, a, b, dz, ispd, ospd = key
            action = lightweight_table[key]
            write(f, "$(r),$(a),$(b),$(dz),$(ispd),$(ospd),\"$(action)\"\n")
        end
    end
    println("\n√ 5维轻量化查询表已经导出至: ", out_path)
end

params_file = "D:/workforce/project/suma/suma/suma/LookupTables/DO-396_paramsfile_acassxu_origami_20220908.txt"

files_to_probe = [
    "D:/workforce/project/suma/suma/example/Encounter4110010Aircraft1Input.json",
    "D:/workforce/project/suma/suma/suma/Encounter1000003Aircraft1Input.json",
    "D:/workforce/project/suma/suma/suma/Encounter1000009Aircraft1Input.json",
    "D:/workforce/project/suma/suma/suma/Encounter1000003Aircraft1Input.json"
]

for file in files_to_probe
    if isfile(file)
        run_probe(file, params_file)
    end
end

if length(lightweight_table) > 0
    export_csv("D:/workforce/project/suma/suma/my_lightweight_table.csv")
end