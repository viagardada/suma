mutable struct AltitudeInhibitCState
inhibited::Vector{Bool} # Whether each altitude inhibit is in effect
initialized::Bool # Whether the AltitudeInhibitCost has been initialized
ldi::UInt8 # Low-level Descend Inhibits
invalid_agl_cycles::Z # number of cycles without valid height-AGL data
#
AltitudeInhibitCState( params::paramsfile_type, mode_idx::Z ) = new( ones( Bool, length( params["modes"][mode_idx]["cost_estimation"]["online"]["altitude_inhibit"]["B_init"] ) ), false, LDI_ALL, params["modes"]["mode_idx"]["cost_estimation"]["online"]["altitude_inhibit"]["T_agl_lost"] )
end
