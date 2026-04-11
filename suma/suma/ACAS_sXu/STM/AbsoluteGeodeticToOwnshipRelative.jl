function AbsoluteGeodeticToOwnshipRelative(this::STM, trk::TrackFile)
I_xy = [1, 3]
(lla, ecef, own_lla, own_ecef) = AlignAltitudeTypesUsedInGeodeticPositions(this, trk.lla_at_hor_toa, trk.ecef_at_hor_toa, trk.alt_src_hae, trk.valid_vert)
(mu_hor, Sigma_hor) = RedefineEstimateInRotatedFrame(trk.mu_hor, trk.Sigma_hor, lla, ecef, own_lla,own_ecef)
delta_ecef = ecef - own_ecef
delta_enu = RotateECEFToENU(delta_ecef, own_lla)
mu_hor[I_xy] = delta_enu[1:2]
mu_hor[2] = mu_hor[2] - this.own.geo_states_hae_alt.vel_ew_mps
mu_hor[4] = mu_hor[4] - this.own.geo_states_hae_alt.vel_ns_mps
return (mu_hor::Vector{R}, Sigma_hor::Matrix{R})
end
