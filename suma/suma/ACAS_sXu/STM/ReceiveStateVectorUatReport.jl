function ReceiveStateVectorUatReport(this::STM, lat::R, lon::R, alt::R, is_alt_geo_hae::Bool, vel_ew::R, vel_ns::R, mode_s::UInt32, nic::UInt32, q_int::UInt32, non_icao::Bool, toa::R)
kts2mps::R = geoutils.kts_to_mps
min_obs_toa_step::R = this.params["surveillance"]["min_obs_toa_step"]
if isnan(lat) || isnan(lon) || isnan(vel_ew) || isnan(vel_ns)
return
end
id = AssociateADSBReportToTarget(this, mode_s, non_icao)
obs_lla = [deg2rad(lat), deg2rad(lon), alt]
if (id == NO_TARGET_FOUND)
trk = ADSBTrackFile(mode_s, non_icao, true)
InitializePassiveTrackFile(this, trk, obs_lla, is_alt_geo_hae, nic, toa)
trk.mu_hor[2] = vel_ew * kts2mps
trk.mu_hor[4] = vel_ns * kts2mps
trk.init_velocity = true
AddADSBTrackToDB(this, trk)
else
tgt = RetrieveWithID(this.target_db, id)
trk = tgt.adsb_track
if (trk.uat)
dt = toa - trk.toa
if (dt >= min_obs_toa_step)
last_valid_vert::Bool = trk.valid_vert
last_alt_src_hae::Bool = trk.alt_src_hae
AdvanceVerticalTrack(this, trk, alt, q_int, is_alt_geo_hae, true, toa)
if (last_valid_vert != trk.valid_vert) || (last_alt_src_hae != trk.alt_src_hae)
UpdateAltInHorGeoPos(trk)
end
(obs_lla[3], _) = GetAltForHorTrkObservation(trk, toa)
obs_ecef = ConvertWGS84ToECEF(obs_lla, trk.alt_src_hae)
R_obs_to_trk = PolarAlignmentHorizontalRotation(obs_lla, obs_ecef, trk.lla_at_hor_toa, trk.ecef_at_hor_toa)
(obs_dx, obs_dy) = R_obs_to_trk * [vel_ew, vel_ns] * kts2mps
AdvancePassiveTrackState(this, trk, obs_lla, obs_ecef, obs_dx, obs_dy, nic, toa)
end
end
end
end
