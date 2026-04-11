function ReceiveStateVectorPositionReport(this::STM, lat::R, lon::R, alt::R, is_alt_geo_hae::Bool, mode_s::UInt32, nic::UInt32, q_int::UInt32, non_icao::Bool, toa::R)
min_obs_toa_step::R = this.params["surveillance"]["min_obs_toa_step"]
if !isnan(lat) && !isnan(lon)
obs_lla = [deg2rad(lat), deg2rad(lon), alt]
id = AssociateADSBReportToTarget(this, mode_s, non_icao)
if (id == NO_TARGET_FOUND)
trk = ADSBTrackFile(mode_s, non_icao, false)
InitializePassiveTrackFile(this, trk, obs_lla, is_alt_geo_hae, nic, toa)
AddADSBTrackToDB(this, trk)
else
tgt = RetrieveWithID(this.target_db, id)
trk = tgt.adsb_track
if (!trk.uat)
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
AdvancePassiveTrackPosition(this, trk, obs_lla, obs_ecef, nic, toa)
end
end
end
end
end
