function IsMTLO(this::TRM, dz_min::R, dz_max::R )
act_mtlo::Z = MTLOAction(this)
R_dz_min_LO::R = this.params["actions"]["min_rates"][act_mtlo]
R_dz_max_LO::R = this.params["actions"]["max_rates"][act_mtlo]
is_mtlo::Bool = false
if (dz_min == R_dz_min_LO) && (dz_max == R_dz_max_LO)
is_mtlo = true
end
return is_mtlo::Bool
end
