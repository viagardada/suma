function UpdatePassiveTrackerVelocity(this::STM, dx_rel::R, dy_rel::R, nacv::UInt32, mu_s::Vector{R}, Sigma_s::Matrix{R})
cov_inflation_factor::R = this.params["surveillance"]["horizontal_adsb"]["cov_inflation_factor"]
H = zeros(2,4)
H[1,2] = H[2,4] = 1
sigma_hva = ConvertNACvToSigmaHVA(nacv)
R_k = diagm(0 => [sigma_hva*sigma_hva, sigma_hva*sigma_hva])
(mu, Sigma) = UpdateKalmanFilter([dx_rel, dy_rel], mu_s, Sigma_s, H, R_k)
Sigma = cov_inflation_factor*Sigma
return (mu::Vector{R}, Sigma::Matrix{R})
end
