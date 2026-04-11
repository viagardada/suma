function TRMIntruderStateUpdate( st_int::TRMIntruderState, vrc::UInt32, cvc::UInt32,
equipage::Z, coordination_msg::UInt32,
is_advisory_reset::Bool, is_initialization_reset::Bool )
st_int.sense_prev = st_int.a_prev.sense
st_int.vrc_prev = vrc
st_int.cvc_prev = cvc
st_int.equipage_prev = equipage
st_int.coordination_msg_prev = coordination_msg
st_int.a_prev.vrc = vrc
st_int.a_prev.cvc = cvc
if is_advisory_reset || is_initialization_reset
st_int.a_prev = IndividualAdvisory()
st_int.b_prev = AdvisoryBeliefState()
st_int.st_arbitrate = ActionArbitrationCState()
st_int.is_threat = false
if !is_initialization_reset
t_count_init::Z = st_int.st_cost_on.initialization.t_count
vrc_int_prev::UInt32 = st_int.st_cost_on.crossing_no_alert.vrc_int_prev
st_int.st_cost_on = OnlineCostState()
st_int.st_cost_on.initialization.t_count = t_count_init
st_int.st_cost_on.crossing_no_alert.vrc_int_prev = vrc_int_prev
else
st_int.st_cost_on = OnlineCostState()
end
end
end
