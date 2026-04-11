mutable struct OwnDiscreteData
v2v_uid::UInt128 # V2V unique identifier of ownship
opflg::Bool # system operational
requested_opmode::UInt8 # Requested operating mode
effective_turn_rate::R # Ownship effective turn rate (radians/sec)
effective_vert_rate::R # Ownship effective vertical rate (ft/sec)
prefer_wind_relative::Bool # flag indicating the desire to prefer wind relative horizontal RA's, evenwhen WGS84 velocities are available
perform_poa::Bool # Perform point obstacle awareness
disable_gpoa::Bool # Disable ground point obstacle awareness
equipment::UInt8 # Ownship equipment
OwnDiscreteData() = new( 0, true, OPMODE_STANDBY, 0.0, 0.0, false, false, false, EQUIPMENT_NONE)
OwnDiscreteData(v2v_uid::UInt128, opflg::Bool, requested_opmode::UInt8, effective_turn_rate::R, effective_vert_rate::R, prefer_wind_relative::Bool, perform_poa::Bool, disable_gpoa::Bool, equipment::UInt8) =
new(v2v_uid, opflg, requested_opmode, effective_turn_rate, effective_vert_rate, prefer_wind_relative, perform_poa, disable_gpoa, equipment)
end
