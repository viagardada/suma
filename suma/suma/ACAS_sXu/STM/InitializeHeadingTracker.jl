function InitializeHeadingTracker(this::STM, Psi::R)
var_dhint::R = this.params["surveillance"]["ownship_heading"]["var_dhint"]
R_k::R = this.params["surveillance"]["ownship_heading"]["R"]
if (!isnan(Psi))
mu = [Psi, 0.0]
else
mu = [0.0, 0.0]
end
Sigma = diagm(0 => [R_k, var_dhint])
return (mu::Vector{R}, Sigma::Matrix{R})
end
