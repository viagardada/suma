function GetAltForHorTrkObservation(trk::Union{ADSBTrackFile, V2VTrackFile, AGTTrackFile}, toa_obs::R)
if trk.valid_vert
dt_vert = toa_obs - trk.toa_vert
alt_ft_toa = trk.mu_vert[1] + trk.mu_vert[2] * dt_vert
alt_rate_fps_toa = trk.mu_vert[2]
else
alt_ft_toa = trk.lla_at_hor_toa[3]
alt_rate_fps_toa = 0.0
end
return (alt_ft_toa::R, alt_rate_fps_toa::R)
end
