function InitializePassiveTrackerPosition(this::STM, is_v2v::Bool)
if is_v2v
init_sigma_pos::R = this.params["surveillance"]["horizontal_v2v"]["init_sigma_pos"]
init_NACv::UInt32 = this.params["surveillance"]["horizontal_v2v"]["init_nacv"]
kappa::R = this.params["surveillance"]["horizontal_v2v"]["kappa"]
else
init_sigma_pos = this.params["surveillance"]["horizontal_adsb"]["init_sigma_pos"]
init_NACv = this.params["surveillance"]["horizontal_adsb"]["init_nacv"]
kappa = this.params["surveillance"]["horizontal_adsb"]["kappa"]
end
mu = zeros(4)
Sigma_tmp = zeros(4,2)
Sigma_tmp[1,1] = Sigma_tmp[3,2] = init_sigma_pos
Sigma_tmp[2,1] = Sigma_tmp[4,2] = ConvertNACvToSigmaHVA(init_NACv)
Sigma = Sigma_tmp * Sigma_tmp'
Sigma = Sigma + kappa*eye(4)
return (mu::Vector{R}, Sigma::Matrix{R})
end
