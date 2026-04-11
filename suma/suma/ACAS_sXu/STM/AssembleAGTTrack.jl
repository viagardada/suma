function AssembleAGTTrack( this::STM, trk::AGTTrackFile, lat_deg::R, lon_deg::R, vel_ew::R, vel_ns::R,
covariance_horiz_ft_fps::Matrix{R}, alt_pres_ft::R, alt_rate_pres_fps::R, covariance_pres_ft_fps::Matrix{R},
alt_hae_ft::R, alt_rate_hae_fps::R, covariance_hae_ft_fps::Matrix{R}, classification::UInt8,
mode_s_valid::Bool )
bound_hor::Vector{R} = this.params["surveillance"]["agt"]["variance_bound_hor"]
bound_vert::Vector{R} = this.params["surveillance"]["agt"]["variance_bound_vert"]
scalar::R = this.params["surveillance"]["agt"]["variance_check_scalar"]
kts2mps::R = geoutils.kts_to_mps
m2ft::R = geoutils.meters_to_feet
invalid_gillham_pres_alt::Bool = mode_s_valid && ((alt_pres_ft < NARS_THRESHOLD_MIN) || (NARS_THRESHOLD_MAX < alt_pres_ft))
invalid_gillham_hae_alt::Bool = mode_s_valid && ((alt_hae_ft < NARS_THRESHOLD_MIN) || (NARS_THRESHOLD_MAX < alt_hae_ft))
variance_bound_hor = (bound_hor * scalar).^2
variance_bound_vert = (bound_vert * scalar).^2
hor_sigmas_too_large::Bool = any(diag(covariance_horiz_ft_fps) .> variance_bound_hor)
pres_sigmas_too_large::Bool = any(diag(covariance_pres_ft_fps) .> variance_bound_vert)
hae_sigmas_too_large::Bool = any(diag(covariance_hae_ft_fps) .> variance_bound_vert)
valid_alt_pres::Bool = !isnan(alt_pres_ft) && !isnan(alt_rate_pres_fps) && ValidCovarianceMatrix(covariance_pres_ft_fps) && !pres_sigmas_too_large && !invalid_gillham_pres_alt
valid_alt_hae::Bool = !isnan(alt_hae_ft) && !isnan(alt_rate_hae_fps) && ValidCovarianceMatrix(covariance_hae_ft_fps) && !hae_sigmas_too_large && !invalid_gillham_hae_alt
sigma_vepu_ft::R = sqrt(covariance_hae_ft_fps[1, 1])
is_large = (classification != CLASSIFICATION_SMALL_UNMANNED)
(alt, alt_src_hae) = GetSwitchingAltitudeType(this, trk, alt_pres_ft, alt_hae_ft, valid_alt_pres,valid_alt_hae, sigma_vepu_ft, is_large)
if alt_src_hae
alt_rate = alt_rate_hae_fps
Sigma_vert = covariance_hae_ft_fps
else
alt_rate::R = alt_rate_pres_fps
Sigma_vert = covariance_pres_ft_fps
end
obs_lla = [deg2rad(lat_deg), deg2rad(lon_deg), alt]
mu_hor = [0.0, vel_ew, 0.0, vel_ns] * kts2mps
Sigma_hor = covariance_horiz_ft_fps / (m2ft * m2ft)
mu_vert::Vector{R} = [alt, alt_rate]
valid_hor::Bool = ValidCovarianceMatrix(covariance_horiz_ft_fps) && !hor_sigmas_too_large
valid_vert::Bool = (alt_src_hae && valid_alt_hae) || (!alt_src_hae && valid_alt_pres)
return (mu_hor::Vector{R}, Sigma_hor::Matrix{R}, mu_vert::Vector{R}, Sigma_vert::Matrix{R}, alt_src_hae::Bool, valid_hor::Bool, valid_vert::Bool, obs_lla::Vector{R})
end
