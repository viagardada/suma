function IsMaintain(this::TRM, dz_min::R, dz_max::R )
R_dz_min_adv::Vector{R} = this.params["actions"]["min_rates"]
R_dz_max_adv::Vector{R} = this.params["actions"]["max_rates"]
approx_zero::R = this.params["surveillance"]["approx_zero"]
is_maintain::Bool = true
for act = 1:length( R_dz_min_adv )
if (isapprox(R_dz_min_adv[act], dz_min, atol=approx_zero ) && (isapprox(R_dz_max_adv[act], dz_max, atol=approx_zero )))
is_maintain = false
end
end
return is_maintain::Bool
end
