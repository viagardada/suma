function SetIntruderIDDirectory(tgt::Target, id_directory::IntruderIDDirectory)
if TrackExists(tgt.adsb_track)
if !tgt.adsb_track.non_icao
id_directory.icao24 = IntruderIDEntry(tgt.adsb_track.mode_s)
else
id_directory.anon24 = IntruderIDEntry(tgt.adsb_track.mode_s)
end
end
if TrackExists(tgt.v2v_track)
id_directory.v2v_uid = IntruderIDEntry(tgt.v2v_track.v2v_uid)
if tgt.v2v_track.mode_s_valid
if !tgt.v2v_track.mode_s_non_icao && !id_directory.icao24.valid
id_directory.icao24 = IntruderIDEntry(tgt.v2v_track.mode_s)
elseif tgt.v2v_track.mode_s_non_icao && !id_directory.anon24.valid
id_directory.anon24 = IntruderIDEntry(tgt.v2v_track.mode_s)
end
end
end
if TrackExists(tgt.ornct_track)
id_directory.ornct_id = IntruderIDEntry(tgt.ornct_track.ornct_id)
end
for trk in tgt.agt_tracks
push!(id_directory.agt_ids, trk.agt_id)
if trk.v2v_uid_valid && !id_directory.v2v_uid.valid
id_directory.v2v_uid = IntruderIDEntry(trk.v2v_uid)
end
if trk.mode_s_valid
if !trk.mode_s_non_icao && !id_directory.icao24.valid
id_directory.icao24 = IntruderIDEntry(trk.mode_s)
elseif trk.mode_s_non_icao && !id_directory.anon24.valid
id_directory.anon24 = IntruderIDEntry(trk.mode_s)
end
end
end
if TrackExists(tgt.point_obstacle_track)
id_directory.po_id = IntruderIDEntry(tgt.point_obstacle_track.po_id)
end
return
end
