function PredictPreTrackedTrack(this::STM, trk::Union{AGTTrackFile, ORNCTTrackFile}, T::R)
m2ft::R = geoutils.meters_to_feet
if (typeof(trk) == AGTTrackFile)
dt_vert = T - trk.toa_vert
dt_hor = T - trk.toa_hor
(mu_hor_pred, Sigma_hor_pred) = PredictPassiveTracker(this, trk.mu_hor, trk.Sigma_hor, dt_hor, false)
mu_hor_pred *= m2ft
Sigma_hor_pred *= m2ft^2
is_large::Bool = (trk.classification != CLASSIFICATION_SMALL_UNMANNED)
(mu_vert_pred, Sigma_vert_pred) = PredictVerticalTracker(this, trk.mu_vert, trk.Sigma_vert, dt_vert, trk.alt_src_hae, false, is_large)
else
dt = T - trk.toa
(mu_vert_pred, Sigma_vert_pred, _, _, mu_cart_pred, Sigma_cart_pred) = PredictORNCTTrack(this, trk, dt)
mu_hor_pred = mu_cart_pred
Sigma_hor_pred = Sigma_cart_pred
end
return (mu_hor_pred::Vector{R}, Sigma_hor_pred::Matrix{R}, mu_vert_pred::Vector{R}, Sigma_vert_pred::Matrix{R})
end
