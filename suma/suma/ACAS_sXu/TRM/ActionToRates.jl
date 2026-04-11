function ActionToRates(this::TRM, act::Z, dz_own_ave::R, act_prev::Z, dz_min_prev::R, dz_max_prev::R, ddz_prev::R )
R_dz_min_adv::Vector{R} = this.params["actions"]["min_rates"]
R_dz_max_adv::Vector{R} = this.params["actions"]["max_rates"]
R_ddz_adv::Vector{R} = this.params["actions"]["accelerations"]
dz_min::R = 0.0
dz_max::R = 0.0
ddz::R = 0.0
if isnan( R_dz_min_adv[act] ) || isnan( R_dz_max_adv[act] )
if (act_prev == act)
(dz_min, dz_max, ddz) = (dz_min_prev, dz_max_prev, ddz_prev)
else
(dz_min, dz_max) = MaintainRates( this, dz_own_ave )
ddz = R_ddz_adv[act]
end
else
(dz_min, dz_max, ddz) = (R_dz_min_adv[act], R_dz_max_adv[act], R_ddz_adv[act])
end
return (dz_min::R, dz_max::R, ddz::R)
end
