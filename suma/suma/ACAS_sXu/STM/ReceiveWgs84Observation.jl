function ReceiveWgs84Observation(this::STM, lat_deg::R, lon_deg::R, vel_ew_kts::R, vel_ns_kts::R, alt_hae_ft::R, alt_rate_hae_fps::R, nacp::UInt32, nacv::UInt32, vfom_m::R, toa::R)
kappa::R = this.params["surveillance"]["horizontal_adsb"]["kappa"]
max_coasts_ownship_turn_offset::R = this.params["surveillance"]["ornct"]["max_coasts_ownship_turn_offset"]
min_nacp::UInt32 = this.params["surveillance"]["ownship_wgs84"]["min_nacp"]
min_nacv::UInt32 = this.params["surveillance"]["ownship_wgs84"]["min_nacv"]
if !isnan(toa) && !isnan(lat_deg) && !isnan(lon_deg) && !isnan(vel_ew_kts) && !isnan(vel_ns_kts) && (nacp >= min_nacp) && (nacv >= min_nacv)
wgs84_previously_initialized::Bool = (this.own.wgs84_state != OWN_WGS84_INVALID)
this.own.wgs84_state = OWN_WGS84_VALID
for id in keys(this.target_db)
if (wgs84_previously_initialized)
if (TrackExists(this.target_db[id].ornct_track))
trk = this.target_db[id].ornct_track
if ( (toa - trk.toa_update) > max_coasts_ownship_turn_offset)
OffsetTracksByOwnshipTurn(this, trk, lat_deg, lon_deg, vel_ew_kts, vel_ns_kts, toa)
end
end
end
end
this.own.wgs84_lat_deg = lat_deg
this.own.wgs84_lon_deg = lon_deg
this.own.wgs84_vel_ew_kts = vel_ew_kts
this.own.wgs84_vel_ns_kts = vel_ns_kts
this.own.wgs84_alt_hae_ft = alt_hae_ft
this.own.wgs84_alt_rate_hae_fps = alt_rate_hae_fps
this.own.wgs84_toa = toa
h_sigma_tmp = zeros(4,2)
h_sigma_tmp[1,1] = h_sigma_tmp[3,2] = ConvertNACpToSigmaHEPU(nacp)
h_sigma_tmp[2,1] = h_sigma_tmp[4,2] = ConvertNACvToSigmaHVA(nacv)
this.own.wgs84_Sigma_hor = h_sigma_tmp * h_sigma_tmp'
this.own.wgs84_Sigma_hor = this.own.wgs84_Sigma_hor + kappa*eye(4)
AdvanceOwnHAETrack(this, alt_hae_ft, alt_rate_hae_fps, vfom_m, toa)
end
end
