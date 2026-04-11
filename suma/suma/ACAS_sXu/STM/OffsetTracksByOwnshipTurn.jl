function OffsetTracksByOwnshipTurn( this::STM, trk::ORNCTTrackFile, lat::R, lon::R, vel_ew::R, vel_ns::R, toa::R )
idx_vel::Vector{Z} = [2, 4]
(offset_dx, offset_dy) = CalculateOwnshipVelocityOffsets(this, lat, lon, vel_ew, vel_ns)
trk.mu_cart[idx_vel] = trk.mu_cart[idx_vel] - [offset_dx, offset_dy]
dt = toa - trk.toa
(trk.mu_vert, trk.Sigma_vert, trk.mu_rng, trk.Sigma_rng, trk.mu_cart, trk.Sigma_cart) =
PredictORNCTTrack(this, trk, dt)
trk.toa = toa
end
