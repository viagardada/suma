# 导入内置 JSON 解析库 (需要: import Pkg; Pkg.add("JSON"))
using JSON

println("正在启动 Julia 原生引擎模块...")

# 1. 直接引入底层的防撞逻辑核心模块
include("D:/workforce/project/suma/suma/suma/ACAS_sXu/ACAS_sXu.jl")
using .ACAS_sXu

function run_simulation()
    # 2. 准备参数查找表
    params_file = "D:/workforce/project/suma/suma/suma/LookupTables/DO-396_paramsfile_acassxu_origami_20220908.txt"
    if !isfile(params_file)
        println("错误: 找不到查找表 -> $params_file")
        return
    end

    # 3. 初始化 STM 和 TRM 模型对象
    println("初始化防撞模块 STM & TRM...")
    stm = ACAS_sXu.STM(params_file)
    trm = ACAS_sXu.TRM(params_file, stm) 
    
    # +++ 新增这一行：初始化 TRM 用来记忆上一帧追踪结果的状态器 +++
    trm_state = ACAS_sXu.sXuTRMState()

    # 4. 加载并在内存中解析 JSON 输入数据
    input_file = "D:/workforce/project/suma/suma/suma/Encounter1000003Aircraft1Input.json"
    println("加载推演剧本: $input_file")
    
    # 修复：直接作为整体文件解析，以支持跨行 JSON
    parsed_json = JSON.parsefile(input_file)

    # 提取顶层的 acasx_reports 列表
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

    println("开始原生 Julia 时序推演...")
    for report in reports
        report_time = report["report_time"]
        report_type = report["report_type"]
        
        report_content = report[lowercase(report_type)]
        data_type = report_content["data_type"]
        data = report_content[lowercase(data_type)]
        
        # 5. [核心翻译层] 将 JSON 报文字典转换为 ACAS_sXu 原生数据结构并调用
        if data_type == "OWNSHIP_DISCRETES"
            ACAS_sXu.ReceiveDiscretes(
                stm,
                UInt128(data["remote_id"]),           # remote_id (UInt128)
                Bool(data["opflg"]),                  # opflg
                UInt8(3),                             # requested_opmode (3)
                Float64(data["turn_rate_limit_rad"]), # turn_rate_limit_rad
                Float64(data["vert_rate_limit_fps"]), # vert_rate_limit_fps
                Bool(data["surv_only_disp_on"]),      # surv_only_disp_on
                false,                                # perform_poa_gpoa
                false,                                # disable_gpoa
                UInt8(15)                             # equipment
            )
        elseif data_type == "WGS84_OBS"
            ACAS_sXu.ReceiveWgs84Observation(
                stm,
                Float64(data["lat_deg"]),          # lat
                Float64(data["lon_deg"]),          # lon
                Float64(data["vel_ew_kts"]),       # vel_ew
                Float64(data["vel_ns_kts"]),       # vel_ns
                Float64(data["alt_hae_ft"]),       # alt
                Float64(data["alt_rate_hae_fps"]), # alt_rate
                UInt32(data["nacp"]),              # nacp
                UInt32(data["nacv"]),              # nacv
                Float64(8.0),                      # vfom_m
                Float64(data["toa"])               # toa
            )
        elseif data_type == "HEADING_OBS"
            ACAS_sXu.ReceiveHeadingObservation(
                stm,
                Float64(data["psi_rad"]),       # Psi (航向角)
                Float64(data["toa"]),           # toa (到达时间)
                Bool(data["heading_degraded"])  # heading_degraded (是否降级)
            )
        elseif data_type == "PRES_ALT_OBS"
            ACAS_sXu.ReceivePresAltObservation(
                stm,
                Float64(data["alt_pres_ft"]),
                Float64(data["toa"])
            )
        elseif data_type == "HEIGHT_AGL_OBS"
            ACAS_sXu.ReceiveHeightAglObservation(
                stm,
                Float64(data["h_ft"])
            )
        elseif data_type == "EXTERNALLY_VALIDATED_V2V"
            # 底层真实的函数名是 ReceiveExternallyValidatedV2V
            ACAS_sXu.ReceiveExternallyValidatedV2V(
                stm,
                Bool(data["externally_validated"]),
                UInt128(data["remote_id"])
            )
        elseif data_type == "VEHICLE_TO_VEHICLE_REPORT"
            # 提取信号质量参数（设置默认备用值以防json中没有）
            nic_val = haskey(data, "nic") ? UInt32(data["nic"]) : UInt32(6)
            nacp_val = haskey(data, "nacp") ? UInt32(data["nacp"]) : UInt32(7)
            nacv_val = haskey(data, "nacv") ? UInt32(data["nacv"]) : UInt32(1)
            vfom_val = haskey(data, "vfom_m") ? Float64(data["vfom_m"]) : Float64(8.0)
            sil_val = haskey(data, "sil") ? UInt32(data["sil"]) : UInt32(1)
            sda_val = haskey(data, "sda") ? UInt32(data["sda"]) : UInt32(2)
            cls_val = haskey(data, "classification") ? UInt8(data["classification"]) : UInt8(1)
            q_int_val = haskey(data, "q_int") ? UInt32(data["q_int"]) : UInt32(25)
            mode_s_val = haskey(data, "mode_s") ? UInt32(data["mode_s"]) : UInt32(0)
            non_icao = haskey(data, "mode_s_non_icao") ? Bool(data["mode_s_non_icao"]) : false
            valid = haskey(data, "mode_s_valid") ? Bool(data["mode_s_valid"]) : true
            
            ACAS_sXu.ReceiveStateVectorV2VReport(
                stm,
                Float64(data["lat_deg"]),          # lat
                Float64(data["lon_deg"]),          # lon
                haskey(data, "alt_pres_ft") ? Float64(data["alt_pres_ft"]) : NaN, # alt_pres_ft
                Float64(data["alt_hae_ft"]),       # alt_hae_ft
                Float64(data["vel_ew_kts"]),       # vel_ew
                Float64(data["vel_ns_kts"]),       # vel_ns
                nic_val,
                nacp_val,
                nacv_val,
                vfom_val,
                sil_val,
                sda_val,
                UInt128(haskey(data, "v2v_uid") ? data["v2v_uid"] : data["remote_id"]), # 兼容两种写法
                mode_s_val,
                non_icao,
                valid,
                cls_val,
                q_int_val,
                Float64(data["toa"])               # toa 取放最后
            )
        elseif data_type == "EXTERNALLY_VALIDATED_ADSB"
            # 身份认证 ADS-B
            ACAS_sXu.ReceiveExternallyValidatedADSB(
                stm,
                Bool(data["externally_validated"]),
                UInt32(data["address"]),         # 很多json中叫做 address 或 mode_s
                Bool(data["non_icao_address"])   # 很多json中叫做 non_icao_address
            )
        elseif data_type == "ADSB_AIRCRAFT_OPERATIONAL_STATUS"
            # 其它可继续补充...
            # ACAS_sXu.ReceiveAdsbAircraftOperationalStatus(...)
        # （另外还需要补充 EXTERNALLY_VALIDATED_ADSB 等）
        end
        
        # 6. 每满一秒，结算当前帧的避碰指令
        curTick = floor(Int, report_time - 0.00001)
        if curTick > _sxuLastTick
            _sxuLastTick = curTick
            println("--- [Time: ", curTick, ".0] 分析当前态势与威胁 ---")
            
            # 生成监控报告
            stm_report = ACAS_sXu.GenerateStmReport(stm, report_time)
            
            # 计算威胁并生成规避机动建议
            trm_report = ACAS_sXu.sXuTRMUpdate(trm, trm_state, stm_report.trm_input)
            
            # 记录旧轨迹并清理
            ACAS_sXu.StmHousekeeping(stm, trm_report)
            
            println("  => 水平建议机动: ","\n" , trm_report.display_horiz)
            println("")
            println("  => 垂直建议机动: ","\n" , trm_report.display_vert)
            
            println("---------------------------------------------------------------------------------------------")
        end
    end
    println("仿真结束。")
end

run_simulation()