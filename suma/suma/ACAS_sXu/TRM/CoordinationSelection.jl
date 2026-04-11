function CoordinationSelection( this::TRM, act_indiv::Z, act_global::Z, dz_min_global::R, dz_max_global::R,
ddz_global::R, dz_own_ave::R, a_global_prev::GlobalAdvisory,
a_indiv_prev::IndividualAdvisory, equipage_int::Z )
dz_min_indiv::R = -Inf
dz_max_indiv::R = Inf
ddz_indiv::R = 0.0
if (COC == act_global)
(dz_min_indiv, dz_max_indiv, ddz_indiv) = (dz_min_global, dz_max_global, 0.0)
elseif IsMaintain( this, a_global_prev.dz_min, a_global_prev.dz_max )
(dz_min_indiv, dz_max_indiv, ddz_indiv) =
ActionToRates( this, act_indiv, dz_own_ave, a_indiv_prev.action,
a_global_prev.dz_min, a_global_prev.dz_max, ddz_global )
elseif IsMaintain( this, dz_min_global, dz_max_global )
(dz_min_indiv, dz_max_indiv, ddz_indiv) =
ActionToRates( this, act_indiv, dz_own_ave, a_indiv_prev.action,
dz_min_global, dz_max_global, ddz_global )
else
(dz_min_indiv, dz_max_indiv, ddz_indiv) =
ActionToRates( this, act_indiv, dz_own_ave, -1, NaN, NaN, NaN )
end
(cvc::UInt32, vrc::UInt32, vsb::UInt32, sense_indiv::Symbol) =
Crosslink( this, dz_min_indiv, dz_max_indiv, a_indiv_prev.vrc, a_indiv_prev.cvc, equipage_int )
if (COC == a_indiv_prev.action)
a_indiv_prev.ra_prev = false
else
a_indiv_prev.ra_prev = true
end
a_indiv_prev.action = act_indiv
a_indiv_prev.dz_min = dz_min_indiv
a_indiv_prev.dz_max = dz_max_indiv
a_indiv_prev.ddz = ddz_indiv
a_indiv_prev.sense = sense_indiv
a_indiv_prev.vrc = vrc
a_indiv_prev.cvc = cvc
return (cvc::UInt32, vrc::UInt32, vsb::UInt32, sense_indiv::Symbol)
end
