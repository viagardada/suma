function UpdatePassiveTrackerPosition(this::STM, x_rel::R, y_rel::R, mu_s::Vector{R}, Sigma_s::Matrix{R})
cov_inflation_factor::R = this.params["surveillance"]["horizontal_adsb"]["cov_inflation_factor"]
update_sigma_pos::R = this.params["surveillance"]["horizontal_adsb"]["update_sigma_pos"]
H = zeros(2,4)
H[1,1] = H[2,3] = 1
R_q = diagm(0 => [update_sigma_pos*update_sigma_pos, update_sigma_pos*update_sigma_pos])
(mu, Sigma) = UpdateKalmanFilter([x_rel, y_rel], mu_s, Sigma_s, H, R_q)
Sigma = cov_inflation_factor*Sigma
return (mu::Vector{R}, Sigma::Matrix{R})
end
