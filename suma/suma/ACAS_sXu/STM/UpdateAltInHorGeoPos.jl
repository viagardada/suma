function UpdateAltInHorGeoPos(trk::TrackFile)
if trk.valid_vert
dt_hor_toa = trk.toa_hor - trk.toa_vert
trk.lla_at_hor_toa[3] = trk.mu_vert[1] + trk.mu_vert[2] * dt_hor_toa
else
trk.lla_at_hor_toa[3] = 0.0
end
trk.ecef_at_hor_toa = ConvertWGS84ToECEF(trk.lla_at_hor_toa, trk.alt_src_hae)
end
