function ReceiveStateVectorV2VReport(this::STM, lat::R, lon::R, alt_pres_ft::R, alt_hae_ft::R, vel_ew::R, vel_ns::R, nic::UInt32, nacp::UInt32, nacv::UInt32, vfom_m::R, sil::UInt32, sda::UInt32, v2v_uid::UInt128, mode_s::UInt32, mode_s_non_icao::Bool, mode_s_valid::Bool, classification::UInt8, q_int::UInt32, toa::R)
kts2mps::R = geoutils.kts_to_mps
min_obs_toa_step::R = this.params["surveillance"]["min_obs_toa_step"]
if isnan(lat) || isnan(lon) || isnan(vel_ew) || isnan(vel_ns)
return
end
is_large::Bool = (classification != CLASSIFICATION_SMALL_UNMANNED)
if is_large
max_vfom_m = this.params["surveillance"]["vertical"]["hae_large_intruder"]["max_vfom"]
else
max_vfom_m::R = this.params["surveillance"]["vertical"]["hae_small_intruder"]["max_vfom"]
end
invalid_gillham_pres_alt::Bool = mode_s_valid && ((alt_pres_ft < NARS_THRESHOLD_MIN) || (NARS_THRESHOLD_MAX < alt_pres_ft))
invalid_gillham_hae_alt::Bool = mode_s_valid && ((alt_hae_ft < NARS_THRESHOLD_MIN) || (NARS_THRESHOLD_MAX < alt_hae_ft))
valid_alt_pres::Bool = !isnan(alt_pres_ft) && !invalid_gillham_pres_alt
valid_alt_hae::Bool = !isnan(alt_hae_ft) && !invalid_gillham_hae_alt && (vfom_m <= max_vfom_m)
sigma_vepu_ft::R = ConvertVFOMToSigmaVEPU(vfom_m)
id = AssociateV2VToTarget(this, v2v_uid)
if (id == NO_TARGET_FOUND)
trk = V2VTrackFile(v2v_uid, mode_s, mode_s_non_icao, mode_s_valid, classification)
(alt, alt_src_hae) = GetSwitchingAltitudeType(this, trk, alt_pres_ft, alt_hae_ft, valid_alt_pres, valid_alt_hae, sigma_vepu_ft, is_large)
obs_lla = [deg2rad(lat), deg2rad(lon), alt]
InitializePassiveTrackFile(this, trk, obs_lla, alt_src_hae, nic, toa)
trk.mu_hor[2] = vel_ew * kts2mps
trk.mu_hor[4] = vel_ns * kts2mps
trk.init_velocity = true
AddV2VTrackToDB(this, trk)
else
tgt = RetrieveWithID(this.target_db, id)
trk = tgt.v2v_track
dt = toa - trk.toa
if (dt >= min_obs_toa_step)
(alt, alt_src_hae) = GetSwitchingAltitudeType(this, trk, alt_pres_ft, alt_hae_ft, valid_alt_pres, valid_alt_hae, sigma_vepu_ft, is_large)
obs_lla = [deg2rad(lat), deg2rad(lon), alt]
last_valid_vert::Bool = trk.valid_vert
last_alt_src_hae::Bool = trk.alt_src_hae
AdvanceVerticalTrack(this, trk, alt, q_int, alt_src_hae, is_large, toa)
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
trk.sigma_vepu = sigma_vepu_ft
trk.classification = classification
trk.nacp = nacp
trk.nacv = nacv
trk.sil = sil
trk.sda = sda
trk.mode_s = mode_s
trk.mode_s_non_icao = mode_s_non_icao
trk.mode_s_valid = mode_s_valid
UpdatePassiveQualityHistory(this, trk)
end
