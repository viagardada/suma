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
        # 您可以根据需要继续增加如 HEADING_OBS 等的解析
        end
        
        # 6. 每满一秒，结算当前帧的避碰指令
        curTick = floor(Int, report_time - 0.00001)
        if curTick > _sxuLastTick
            _sxuLastTick = curTick
            println("--- [Time: ", curTick, ".0] 分析当前态势与威胁 ---")
            
            # 生成监控报告
            stm_report = ACAS_sXu.GenerateStmReport(stm, report_time)
            
            # 计算威胁并生成规避机动建议 (传入 trm_state 并用掉没有感叹号的内置函数)
            trm_report = ACAS_sXu.sXuTRMUpdate(trm, trm_state, stm_report.trm_input)
            
            # 记录旧轨迹并清理
            ACAS_sXu.StmHousekeeping(stm, trm_report)
            
            println("  => 水平建议机动: ", trm_report.display_horiz)
            println("  => 垂直建议机动: ", trm_report.display_vert)
        end
    end
    println("仿真结束。")
end

run_simulation()