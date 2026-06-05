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

# [增强点 1] 扩充轻量化表的维度为 9 维: 
# Tuple{距离, 相对高度, 方位角, 相对航向, 入侵者地速, 本机地速, 本机垂速, 目标垂速, Tau}
global lightweight_table = Dict{Tuple{Float64, Float64, Float64, Float64, Float64, Float64, Float64, Float64, Float64}, String}()

# [增强点 2] 离散化网格设置
const RANGE_BIN     = 500.0   # 距离: 每 500 ft 归为一类
const ALT_BIN       = 100.0   # 相高: 每 100 ft 归为一类
const BEARING_BIN   = 30.0    # 方位: 每 30° 归为一类
const HEADING_BIN   = 30.0    # 相对航向: 每 30° 归为一类
const SPEED_BIN     = 50.0    # 速度: 每 50 ft/s 归为一类
const V_RATE_BIN    = 10.0    # 垂直速率: 每 10 ft/s 归为一类
const TAU_BIN       = 5.0     # 预计遭遇时间: 每 5 秒归为一类
const INT_SPEED_BIN = 50.0    # 入侵速度: 每 50 ft/s 归为一类
const OWN_SPEED_BIN = 50.0    # 本机速度: 每 50 ft/s 归为一类

# 更新 discretize_state 支持新增的 int_spd 参数
function discretize_state(r::Float64, z::Float64, b::Float64, psi::Float64, int_spd::Float64, own_spd::Float64, own_dz::Float64, int_dz::Float64, tau::Float64)
    # 距离(Range)的非均匀离散化
    r_bin = 0.0
    if r <= 500.0
        r_bin = round(r / 100.0) * 100.0
        # 防治 r 被化为了 0.0，最小值保底为 100.0 ft 保护泡
        r_bin = max(100.0, r_bin)
    elseif r <= 2000.0
        r_bin = round(r / 500.0) * 500.0
    else
        r_bin = round(r / 1000.0) * 1000.0
    end
    
    a_bin = round(z / ALT_BIN) * ALT_BIN
    
    b_bin = round(b / BEARING_BIN) * BEARING_BIN
    if b_bin > 180.0
        b_bin -= 360.0
    end
    
    psi_bin = round(psi / HEADING_BIN) * HEADING_BIN
    if psi_bin > 180.0
        psi_bin -= 360.0
    end
    
    int_spd_bin = round(int_spd / INT_SPEED_BIN) * INT_SPEED_BIN
    own_spd_bin = round(own_spd / OWN_SPEED_BIN) * OWN_SPEED_BIN
    own_dz_bin  = round(own_dz / V_RATE_BIN) * V_RATE_BIN
    int_dz_bin  = round(int_dz / V_RATE_BIN) * V_RATE_BIN
    
    # 限制 Tau 的最大离散值为 100.0，并将最小值保底为 TAU_BIN (5.0 秒)
    tau_bin = tau >= 100.0 ? 100.0 : round(tau / TAU_BIN) * TAU_BIN
    tau_bin = max(TAU_BIN, tau_bin) # 兜底，防止出现 0.0

    return (r_bin, a_bin, b_bin, psi_bin, int_spd_bin, own_spd_bin, own_dz_bin, int_dz_bin, tau_bin)
end

function extract_threat_state(trm_input::ACAS_sXu.TRMInput)
    if !isempty(trm_input.intruder)
        int_display = trm_input.intruder[1].stm_display
        own_info    = trm_input.own
        
        # 1. 距离与相对高度
        r_ground = isnan(int_display.r_ground_ft) ? 0.0 : int_display.r_ground_ft
        z_rel    = isnan(int_display.z_rel_ft) ? 0.0 : int_display.z_rel_ft
        
        # 2. 方位角 (Theta)
        b_rad = isnan(int_display.bearing_rel_rad) ? 0.0 : int_display.bearing_rel_rad
        bearing_deg = b_rad * (180.0 / π)
        
        # 3. 速度解算
        dx_rel = isnan(int_display.dx_rel_fps) ? 0.0 : int_display.dx_rel_fps
        dy_rel = isnan(int_display.dy_rel_fps) ? 0.0 : int_display.dy_rel_fps
        own_speed = isnan(own_info.ground_speed) ? 0.0 : own_info.ground_speed
        
        own_track = isnan(own_info.track_angle) ? 0.0 : own_info.track_angle
        own_vE = own_speed * sin(own_track)
        own_vN = own_speed * cos(own_track)
        int_vE = dx_rel + own_vE
        int_vN = dy_rel + own_vN
        int_speed = hypot(int_vE, int_vN)
        
        # 4. 相对航向角 (Psi) - 【原版算法强依赖】
        int_track = atan(int_vE, int_vN)
        psi_rad = int_track - own_track
        # 归一化到 [-pi, pi]
        psi_rad = atan(sin(psi_rad), cos(psi_rad))
        psi_deg = psi_rad * (180.0 / π)
        
        # 5. 独立垂直速率 - 【原版算法垂直逻辑强依赖】
        own_dz = isnan(own_info.effective_vert_rate) ? 0.0 : own_info.effective_vert_rate
        # ACAS_sXu 中 dz_rel 通常 = dz_int - dz_own
        dz_rel = isnan(int_display.dz_rel_fps) ? 0.0 : int_display.dz_rel_fps
        int_dz = dz_rel + own_dz
        
        # 6. Tau (相遇时间) - 【原版触发逻辑强依赖】
        # 简单横向径向接近率求 Tau (t = -r / r_dot)
        # 注意需要防范 r_dot 为负面逼近的情况
        dot_r = (int_vE * sin(b_rad) + int_vN * cos(b_rad)) - own_speed 
        tau_h = (dot_r < -0.1) ? (-r_ground / dot_r) : 999.0 # 无限大代表不会相撞
        
        # 7. (可选) 历史告警 prev_adv 
        # 此处如果要提取 prev_adv，需要传入 trm_report 或者维护上一时刻状态。
        
        return (r_ground, z_rel, bearing_deg, psi_deg, int_speed, own_speed, own_dz, int_dz, tau_h)
    end
    return (NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN)
end

function run_probe(input_file::String, params_file::String)
    println("初始化防撞模块 STM & TRM...")
    stm = ACAS_sXu.STM(params_file)
    trm = ACAS_sXu.TRM(params_file, stm) 
    trm_state = ACAS_sXu.sXuTRMState()

    println("加载推演剧本: $input_file")
    parsed_json = JSON.parsefile(input_file; allownan=true)
    
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
                Bool(get(data, "surv_only_disp_on", true)), false, false, UInt8(15))
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
        elseif data_type == "V2V_OPERATIONAL_STATUS_MESSAGE"
            uid_val = haskey(data, "v2v_uid") ? data["v2v_uid"] : get(data, "remote_id", 0)
            # 根据 ReceiveV2VOperationalStatusMessage(this::STM, ca_status::UInt8, sense::UInt8, type_capability::UInt8, priority::UInt8, equipment::UInt8, pilot_or_passengers::UInt8, v2v_uid::UInt128)
            ACAS_sXu.ReceiveV2VOperationalStatusMessage(
                stm,
                UInt8(get(data, "ca_status", 1)),
                UInt8(get(data, "sense", 1)),
                UInt8(get(data, "type_capability", 1)),
                UInt8(get(data, "priority", 0)),
                UInt8(get(data, "equipment", 15)),
                UInt8(get(data, "pilot_or_passengers", 0)),
                safe_parse_uint128(uid_val)
            )
        # 向下兼容处理 DO396 旧版 capability (如果你用了 V2V_CAPABILITY_REPORT)
        elseif data_type == "V2V_CAPABILITY_REPORT"
            uid_val = haskey(data, "v2v_uid") ? data["v2v_uid"] : get(data, "remote_id", 0)
            ACAS_sXu.ReceiveV2VOperationalStatusMessage(
                stm, UInt8(1), UInt8(1), UInt8(1), UInt8(0), UInt8(15), UInt8(0), safe_parse_uint128(uid_val)
            )
        end
        
        curTick = floor(Int, report_time - 0.00001)
        if curTick > _sxuLastTick
            _sxuLastTick = curTick
            
            stm_report = ACAS_sXu.GenerateStmReport(stm, report_time)
            
            # [修改处]: 解包提取更多的状态
            r_ground, z_rel, b_deg, psi_deg, int_spd, own_spd, own_dz, int_dz, tau_h = extract_threat_state(stm_report.trm_input)
            trm_report = ACAS_sXu.sXuTRMUpdate(trm, trm_state, stm_report.trm_input)
            ACAS_sXu.StmHousekeeping(stm, trm_report)
            
            if !isnan(r_ground)
                # 将 9 维状态转换为离散格子
                # ↓↓↓ 确保这行里面是 own_dz, int_dz 等9个变量，没有 dz_rel
                key = discretize_state(r_ground, z_rel, b_deg, psi_deg, int_spd, own_spd, own_dz, int_dz, tau_h)
                
                adv_str = "H:" * string(trm_report.display_horiz.cc) * " | V:" * string(trm_report.display_vert.cc)
                
                if !haskey(lightweight_table, key) || adv_str != "H:0 | V:0"
                    lightweight_table[key] = adv_str
                end
                
                @printf("[Time %4d] 距离:%04.0f | 相高:%+4.0f | 方位:%+4.0f° | 航向差:%+4.0f° | 目标速:%03.0f | 本机速:%03.0f | 目标垂速:%+3.0f | 本机垂:%+3.0f | Tau:%.1f => %s\n", 
                        curTick, key[1], key[2], key[3], key[4], key[5], key[6], key[7], key[8], key[9], adv_str)
            end
        end
    end
end

function export_csv(out_path::String)
    open(out_path, "w") do f
        # 更新表头以反映 9 个维度
        write(f, "Range(ft),Rel_Altitude(ft),Bearing(deg),Rel_Heading(deg),Intruder_Speed(fps),Own_Speed(fps),Own_Vert_Rate(fps),Int_Vert_Rate(fps),Tau(s),Recommended_Action\n")
        
        curr_keys = sort(collect(keys(lightweight_table)))
        for key in curr_keys
            r, a, b, psi, ispd, ospd, odz, idz, tau = key
            action = lightweight_table[key]
            write(f, "$(r),$(a),$(b),$(psi),$(ispd),$(ospd),$(odz),$(idz),$(tau),\"$(action)\"\n")
        end
    end
    println("\n√ 9维轻量化查询表已经导出至: ", out_path)
end

params_file = "D:/workforce/project/suma/suma/suma/LookupTables/DO-396_paramsfile_acassxu_origami_20220908.txt"

# 指定要读取的文件夹路径
target_folder = "D:/workforce/project/suma/suma/suma/example"

# 读取文件夹中新生成的场景文件（编号 >= 101）
files_to_probe = []
if isdir(target_folder)
    for file_name in readdir(target_folder)
        if endswith(file_name, ".json") && startswith(file_name, "AutoGen_Encounter_")
            # 只处理新生成的场景（编号 >= 101）
            m = match(r"AutoGen_Encounter_(\d+)\.json", file_name)
            if m !== nothing && parse(Int, m.captures[1]) >= 101
                push!(files_to_probe, joinpath(target_folder, file_name))
            end
        end
    end
else
    println("警告：找不到指定的文件夹：$target_folder")
end

println("共检测到 $(length(files_to_probe)) 个文件需要探测。")

# 批量执行探测
for file in files_to_probe
    if isfile(file)
        run_probe(file, params_file)
    end
end

if length(lightweight_table) > 0
    export_csv("D:/workforce/project/suma/suma/my_lightweight_table.csv")
end