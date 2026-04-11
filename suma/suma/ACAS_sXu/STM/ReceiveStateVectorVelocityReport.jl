function ReceiveStateVectorVelocityReport(this::STM, vel_ew::R, vel_ns::R, mode_s::UInt32, nic::UInt32, non_icao::Bool, toa::R)
kts2mps::R = geoutils.kts_to_mps
if !isnan(vel_ew) && !isnan(vel_ns)
id = AssociateADSBReportToTarget(this, mode_s, non_icao)
if (id != NO_TARGET_FOUND)
tgt = RetrieveWithID(this.target_db, id)
trk = tgt.adsb_track
if (!trk.uat)
(alt_ft_toa, alt_rate_fps_toa) = GetAltForHorTrkObservation(trk, toa)
dt_hor = toa - trk.toa_hor
geodetic_states_pred = PropagateGeodeticToToa(this, trk.lla_at_hor_toa, alt_ft_toa, trk.alt_src_hae, trk.mu_hor[2], trk.mu_hor[4], alt_rate_fps_toa, dt_hor)
obs_lla_pred = geodetic_states_pred.lla_rad_ft
obs_ecef_pred = geodetic_states_pred.ecef_m
R_obs_to_trk = PolarAlignmentHorizontalRotation(obs_lla_pred, obs_ecef_pred, trk.lla_at_hor_toa, trk.ecef_at_hor_toa)
(obs_dx, obs_dy) = R_obs_to_trk * [vel_ew, vel_ns] * kts2mps
AdvancePassiveTrackVelocity(this, trk, obs_dx, obs_dy, nic, toa, obs_lla_pred[1])
end
end
end
end
