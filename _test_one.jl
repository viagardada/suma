println("开始快速测试...")

include("suma/suma/ACAS_sXu/ACAS_sXu.jl")
using .ACAS_sXu

params_file = "D:/workforce/project/suma/suma/suma/LookupTables/DO-396_paramsfile_acassxu_origami_20220908.txt"

# 初始化
stm = ACAS_sXu.STM(params_file)
trm = ACAS_sXu.TRM(params_file, stm)
trm_state = ACAS_sXu.sXuTRMState()

println("初始化完成，加载JSON...")

using JSON
parsed_json = JSON.parsefile("D:/workforce/project/suma/suma/suma/example/AutoGen_Encounter_0101.json"; allownan=true)

if haskey(parsed_json, "acasx_reports")
    reports = parsed_json["acasx_reports"]
else
    reports = parsed_json
end

sort!(reports, by = x -> get(x, "report_time", 0.0))
println("共 $(length(reports)) 条报告")

_sxuLastTick = 0
non_zero_count = 0
total_ticks = 0

for report in reports
    report_time = report["report_time"]
    report_type = report["report_type"]
    report_content = report[lowercase(report_type)]
    data_type = report_content["data_type"]
    data = report_content[lowercase(data_type)]

    if data_type == "OWNSHIP_DISCRETES"
        uid_val = haskey(data, "v2v_uid") ? data["v2v_uid"] : get(data, "remote_id", 0)
        ACAS_sXu.ReceiveDiscretes(stm, UInt128(parse(Int, string(uid_val))),
            Bool(data["opflg"]), UInt8(3), Float64(get(data, "turn_rate_limit_rad", 0.053)),
            Float64(get(data, "vert_rate_limit_fps", 16.667)),
            Bool(get(data, "surv_only_disp_on", true)), false, false, UInt8(15))
    elseif data_type == "WGS84_OBS"
        ACAS_sXu.ReceiveWgs84Observation(stm, Float64(data["lat_deg"]), Float64(data["lon_deg"]),
            Float64(data["vel_ew_kts"]), Float64(data["vel_ns_kts"]),
            Float64(data["alt_hae_ft"]), Float64(data["alt_rate_hae_fps"]),
            UInt32(data["nacp"]), UInt32(data["nacv"]), Float64(8.0), Float64(data["toa"]))
    elseif data_type == "HEADING_OBS"
        ACAS_sXu.ReceiveHeadingObservation(stm, Float64(data["psi_rad"]), Float64(data["toa"]), Bool(data["heading_degraded"]))
    elseif data_type == "PRES_ALT_OBS"
        ACAS_sXu.ReceivePresAltObservation(stm, Float64(data["alt_pres_ft"]), Float64(data["toa"]))
    elseif data_type == "HEIGHT_AGL_OBS"
        ACAS_sXu.ReceiveHeightAglObservation(stm, Float64(data["h_ft"]))
    elseif data_type == "VEHICLE_TO_VEHICLE_REPORT"
        uid_val = haskey(data, "v2v_uid") ? data["v2v_uid"] : get(data, "remote_id", 0)
        ACAS_sXu.ReceiveStateVectorV2VReport(stm, Float64(data["lat_deg"]), Float64(data["lon_deg"]),
            haskey(data, "alt_pres_ft") ? Float64(data["alt_pres_ft"]) : NaN,
            Float64(data["alt_hae_ft"]),
            Float64(data["vel_ew_kts"]), Float64(data["vel_ns_kts"]),
            UInt32(get(data, "nic", 6)), UInt32(get(data, "nacp", 7)),
            UInt32(get(data, "nacv", 1)), Float64(get(data, "vfom_m", 8.0)),
            UInt32(get(data, "sil", 1)), UInt32(get(data, "sda", 2)),
            UInt128(parse(Int, string(uid_val))),
            UInt32(get(data, "mode_s", 0)),
            Bool(get(data, "mode_s_non_icao", false)),
            Bool(get(data, "mode_s_valid", true)),
            UInt8(get(data, "classification", 1)),
            UInt32(get(data, "q_int", 25)), Float64(data["toa"]))
    elseif data_type == "EXTERNALLY_VALIDATED_V2V"
        uid_val = haskey(data, "v2v_uid") ? data["v2v_uid"] : get(data, "remote_id", 0)
        ACAS_sXu.ReceiveExternallyValidatedV2V(stm, Bool(data["externally_validated"]),
            UInt128(parse(Int, string(uid_val))))
    elseif data_type == "V2V_OPERATIONAL_STATUS_MESSAGE"
        uid_val = haskey(data, "v2v_uid") ? data["v2v_uid"] : get(data, "remote_id", 0)
        ACAS_sXu.ReceiveV2VOperationalStatusMessage(stm,
            UInt8(get(data, "ca_status", 1)), UInt8(get(data, "sense", 1)),
            UInt8(get(data, "type_capability", 1)), UInt8(get(data, "priority", 0)),
            UInt8(get(data, "equipment", 15)), UInt8(get(data, "pilot_or_passengers", 0)),
            UInt128(parse(Int, string(uid_val))))
    end

    curTick = floor(Int, report_time - 0.00001)
    if curTick > _sxuLastTick
        _sxuLastTick = curTick
        total_ticks += 1

        stm_report = ACAS_sXu.GenerateStmReport(stm, report_time)
        trm_report = ACAS_sXu.sXuTRMUpdate(trm, trm_state, stm_report.trm_input)
        ACAS_sXu.StmHousekeeping(stm, trm_report)

        adv_str = "H:" * string(trm_report.display_horiz.cc) * " | V:" * string(trm_report.display_vert.cc)
        if adv_str != "H:0 | V:0"
            non_zero_count += 1
            if non_zero_count <= 5
                @printf("  Non-zero: %s at time %.1f\n", adv_str, report_time)
            end
        end
    end
end

println("\n总tick数: $total_ticks, 非零动作数: $non_zero_count")
println("水平最后: H:$(trm_report.display_horiz.cc)")
println("垂直最后: V:$(trm_report.display_vert.cc)")