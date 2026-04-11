function ReCenterHorizontalTrackLocation(trk::TrackFile, toa::R)
I_xy = [1, 3]
if trk.valid_vert
dt = toa - trk.toa_vert
alt_ft_toa = trk.mu_vert[1] + trk.mu_vert[2] * dt
else
alt_ft_toa = trk.lla_at_hor_toa[3]
end
delta_up = alt_ft_toa - trk.lla_at_hor_toa[3]
delta_enu = [trk.mu_hor[I_xy]; delta_up]
delta_ecef = RotateENUToECEF(delta_enu, trk.lla_at_hor_toa)
ecef = trk.ecef_at_hor_toa + delta_ecef
(ecef, lla) = RefineECEFAndLLA(ecef, alt_ft_toa, trk.alt_src_hae)
trk.mu_hor[I_xy] = zeros(2)
(trk.mu_hor, trk.Sigma_hor) = RedefineEstimateInRotatedFrame(trk.mu_hor, trk.Sigma_hor, trk.lla_at_hor_toa, trk.ecef_at_hor_toa, lla, ecef)
trk.lla_at_hor_toa = lla
trk.ecef_at_hor_toa = ecef
end
