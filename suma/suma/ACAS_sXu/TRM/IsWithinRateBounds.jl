function IsWithinRateBounds(this::TRM, act::Z, dz_own_ave::R )
R_dz_min::Vector{R} = this.params["actions"]["min_rates"]
R_dz_max::Vector{R} = this.params["actions"]["max_rates"]
is_within_bounds::Bool = false
if isnan( R_dz_min[act] ) || isnan( R_dz_max[act] )
is_within_bounds = true
elseif (R_dz_min[act] <= dz_own_ave) && (dz_own_ave <= R_dz_max[act])
is_within_bounds = true
end
return is_within_bounds::Bool
end
