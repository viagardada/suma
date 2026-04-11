function NoIntrudersAction( this::TRM, dz_own_ave::R, st_own::TRMOwnState )
dz_min::R = 0.0
dz_max::R = 0.0
ddz::R = 0.0
act::Z = COC
multithreat::Bool = false
(dz_min, dz_max, ddz) = ActionToRates( this, act, dz_own_ave, st_own.a_prev.action,
st_own.a_prev.dz_min, st_own.a_prev.dz_max, st_own.a_prev.ddz )
st_own.dz_ave_prev = dz_own_ave
st_own.action_prev = COC
st_own.word_prev = 0
st_own.crossing_prev = false
st_own.strength_prev = 0
st_own.st_multithreat_cost_balancing = MultithreatCostBalancingCState()
st_own.st_arbitrate = ActionArbitrationGlobalCState()
return (act::Z, dz_min::R, dz_max::R, ddz::R, multithreat::Bool)
end
