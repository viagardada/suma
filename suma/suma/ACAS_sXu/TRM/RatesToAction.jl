function RatesToAction(this::TRM, dz_min::R, dz_max::R, ddz::R )
R_dz_min_adv::Vector{R} = this.params["actions"]["min_rates"]
R_dz_max_adv::Vector{R} = this.params["actions"]["max_rates"]
R_ddz_adv::Vector{R} = this.params["actions"]["accelerations"]
action::Z = 0
maintain::Z = 0
for i = 1:length( R_dz_min_adv )
if (dz_min == R_dz_min_adv[i]) && (dz_max == R_dz_max_adv[i]) && (ddz == R_ddz_adv[i])
action = i
break
elseif isnan( R_dz_min_adv[i] ) || isnan( R_dz_max_adv[i] )
maintain = i
end
end
if (action == 0) &&
(((dz_min == -Inf) && (dz_max < 0)) ||
((0 <= dz_min) && (dz_max == Inf)) ||
isnan( dz_min ) ||
isnan( dz_max ))
action = maintain
end
return action::Z
end
