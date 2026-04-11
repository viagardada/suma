function ReceiveDiscretes(this::STM, v2v_uid::UInt128, opflg::Bool, requested_opmode::UInt8, effective_turn_rate::R, effective_vert_rate::R, prefer_wind_relative::Bool, perform_poa::Bool, disable_gpoa::Bool, equipment::UInt8)
this.own.v2v_uid = v2v_uid
this.own.v2v_uid_valid = ((equipment & EQUIPMENT_V2V_OUT) != 0)
this.own.discrete.v2v_uid = v2v_uid
this.own.discrete.opflg = opflg
this.own.discrete.requested_opmode = requested_opmode
this.own.discrete.effective_turn_rate = effective_turn_rate
this.own.discrete.effective_vert_rate = effective_vert_rate
this.own.discrete.prefer_wind_relative = prefer_wind_relative
this.own.discrete.perform_poa = perform_poa
this.own.discrete.disable_gpoa = disable_gpoa
this.own.discrete.equipment = equipment
end
