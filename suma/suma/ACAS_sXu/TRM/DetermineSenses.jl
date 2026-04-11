function DetermineSenses(this::TRM, action_indiv::Vector{Z}, dz_own_ave::R, a_global::GlobalAdvisory )
R_dz_min_adv::Vector{R} = this.params["actions"]["min_rates"]
R_dz_max_adv::Vector{R} = this.params["actions"]["max_rates"]
N_intruders::Z = length( action_indiv )
senses_own_indiv::Vector{Symbol} = Vector{Symbol}(undef, N_intruders)
for i = 1:N_intruders
dz_min::R = 0.0
dz_max::R = 0.0
act::Z = action_indiv[i]
if isnan( R_dz_min_adv[act] ) || isnan( R_dz_max_adv[act] )
if (a_global.action == act)
dz_min = a_global.dz_min
dz_max = a_global.dz_max
else
(dz_min, dz_max) = MaintainRates( this, dz_own_ave )
end
else
dz_min = R_dz_min_adv[act]
dz_max = R_dz_max_adv[act]
end
senses_own_indiv[i] = RatesToSense( dz_min, dz_max )
end
return senses_own_indiv::Vector{Symbol}
end
