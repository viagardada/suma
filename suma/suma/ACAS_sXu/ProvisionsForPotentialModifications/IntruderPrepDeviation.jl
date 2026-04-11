function IntruderPrepDeviation( input_own::TRMOwnInputDeviation, input_int::TRMIntruderInput,
st_own::TRMOwnStateDeviation, st_int::TRMIntruderState )
st_int.is_threat = false
belief_vert_int::Vector{IntruderVerticalBelief} = deepcopy( input_int.belief_vert )
if (0 != (input_int.degraded_surveillance & DEGRADED_SURVEILLANCE_NAR))
st_int.processing = RA_PROCESSING_DEGRADED_SURVEILLANCE
belief_vert_int = Vector{IntruderVerticalBelief}( undef, length( input_own.belief_vert ) )
for i in 1:length( input_own.belief_vert )
belief_vert_int[i] = IntruderVerticalBelief( input_own.belief_vert[i].z,
input_own.belief_vert[i].dz,
input_own.belief_vert[i].weight )
end
elseif (0 != (input_int.degraded_surveillance & DEGRADED_SURVEILLANCE_PASSIVE_NOT_VALIDATED))
st_int.processing = RA_PROCESSING_DEGRADED_SURVEILLANCE
elseif (OPMODE_RA == input_own.opmode)
if (RA_PROCESSING_DEGRADED_SURVEILLANCE == st_int.processing)
st_int.st_cost_on = OnlineCostStateDeviation()
end
st_int.processing = RA_PROCESSING_GLOBAL_RA
end
z_int_ave::R = 0.0
dz_int_ave::R = 0.0
for b::IntruderVerticalBelief in belief_vert_int
z_int_ave = z_int_ave + (b.z * b.weight)
dz_int_ave = dz_int_ave + (b.dz * b.weight)
end
mode_int::Z = NO_Xo_MODE_INDEX
exclude_int::Bool = (RA_PROCESSING_DEGRADED_SURVEILLANCE == st_int.processing)
equip_int::Bool = IsIntruderEquipped(input_own.opmode, input_int.equipage)
master_int::Bool = IsIntruderMaster( input_own, input_int )
# Deviation Change for Inhibits
# Set the altitude inhibit online cost state for this intruder
st_int.st_cost_on.alt_inhibit = st_own.st_alt_inhibit[mode_int]
if (OPMODE_SURV_ONLY == st_own.opmode_prev) && (OPMODE_RA == input_own.opmode)
st_int.st_cost_on.coord_delay = CoordinationDelayCState( true )
end
if (OWN_COORDINATION_POLICY_PEER != input_int.own_coordination_policy) && (OWN_COORDINATION_POLICY_JUNIOR != input_int.own_coordination_policy)
st_int.st_cost_on.coord_delay = CoordinationDelayCState( false )
end
return (mode_int::Z, equip_int::Bool, master_int::Bool, exclude_int::Bool, input_int.belief_horiz,
belief_vert_int::Vector{IntruderVerticalBelief}, z_int_ave::R, dz_int_ave::R)
end
