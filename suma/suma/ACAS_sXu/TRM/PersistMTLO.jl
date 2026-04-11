function PersistMTLO( this::TRM, action::Z, multithreat::Bool,
dz_own_ave::R, dz_own_ave_prev::R,
a_global_prev::GlobalAdvisory )
persist_mtlo::Bool = false
if multithreat && (a_global_prev.action == MTLOAction(this))
(dz_min::R, dz_max::R) =
ActionToRates( this, action, dz_own_ave, a_global_prev.action,
a_global_prev.dz_min, a_global_prev.dz_max, a_global_prev.ddz )
if IsDNC( dz_min, dz_max ) && (0 <= dz_own_ave_prev)
persist_mtlo = true
elseif IsDND( dz_min, dz_max ) && (dz_own_ave_prev < 0)
persist_mtlo = true
end
end
return persist_mtlo::Bool
end
