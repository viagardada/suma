function UpdateORNCTTrack(this::STM, trk::ORNCTTrackFile,
mu_cart::Vector{R}, Sigma_cart::Matrix{R},
mu_vert::Vector{R}, Sigma_vert::Matrix{R}, valid_vert::Bool,
mu_rng::Vector{R}, Sigma_rng::Matrix{R},
high_priority::Bool, first_update::Bool, is_coasted::Bool,
reset_estimate::Bool, classification::UInt8, toa::R)
max_outliers::Z = this.params["surveillance"]["ornct"]["max_outlier_detections"]
trk.toa = toa
trk.mu_cart = mu_cart
trk.Sigma_cart = Sigma_cart
trk.mu_vert = mu_vert
trk.Sigma_vert = Sigma_vert
trk.valid_vert = valid_vert
trk.mu_rng = mu_rng
trk.Sigma_rng = Sigma_rng
trk.is_FOV_coast = false
trk.high_priority = high_priority
trk.odc = max_outliers
trk.classification = classification
trk.reset_estimate = reset_estimate
if first_update
trk.toa_update = toa
trk.update_count = 1
else
if reset_estimate || !is_coasted
trk.toa_update = toa
trk.update_count = trk.update_count + 1
end
if valid_vert
VerticalRateArrowUpdate(this, trk, true)
end
end
end
