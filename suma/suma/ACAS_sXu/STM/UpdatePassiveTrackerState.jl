function UpdatePassiveTrackerState(this::STM, x_rel::R, dx_rel::R, y_rel::R, dy_rel::R, nacv::UInt32, mu_s::Vector{R},Sigma_s::Matrix{R}, is_v2v::Bool)
if is_v2v
cov_inflation_factor::R = this.params["surveillance"]["horizontal_v2v"]["cov_inflation_factor"]
update_sigma_pos::R = this.params["surveillance"]["horizontal_v2v"]["update_sigma_pos"]
else
cov_inflation_factor = this.params["surveillance"]["horizontal_adsb"]["cov_inflation_factor"]
update_sigma_pos = this.params["surveillance"]["horizontal_adsb"]["update_sigma_pos"]
end
H = eye(4)
sigma_hva = ConvertNACvToSigmaHVA(nacv)
R_q = diagm(0 => [update_sigma_pos*update_sigma_pos, sigma_hva*sigma_hva, update_sigma_pos*update_sigma_pos, sigma_hva*sigma_hva])
(mu, Sigma) = UpdateKalmanFilter([x_rel, dx_rel, y_rel, dy_rel], mu_s, Sigma_s, H, R_q)
Sigma = cov_inflation_factor*Sigma
return (mu::Vector{R}, Sigma::Matrix{R})
end
