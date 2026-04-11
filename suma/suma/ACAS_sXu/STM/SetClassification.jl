function SetClassification(this::STM, intruder::TRMIntruderInput)
tgt = RetrieveWithID(this.target_db, intruder.id)
classification_vec::Vector{UInt8} = UInt8[]
large_protection_volume_needed::Bool = false
if TrackExists(tgt.adsb_track)
push!(classification_vec, CLASSIFICATION_NONE)
large_protection_volume_needed = true
end
if TrackExists(tgt.v2v_track)
push!(classification_vec, tgt.v2v_track.classification)
if tgt.v2v_track.mode_s_valid
large_protection_volume_needed = true
end
end
if TrackExists(tgt.ornct_track)
push!(classification_vec, tgt.ornct_track.classification)
end
if TrackExists(tgt.agt_tracks)
for trk in tgt.agt_tracks
push!(classification_vec, trk.classification)
if trk.mode_s_valid
large_protection_volume_needed = true
end
end
end
if (tgt.v2v_osm.pilot_or_passengers == V2V_OSM_ONLY_PILOT_ONBOARD) ||
(tgt.v2v_osm.pilot_or_passengers == V2V_OSM_ONLY_PASSENGERS_ONBOARD) ||
(tgt.v2v_osm.pilot_or_passengers == V2V_OSM_PILOT_AND_PASSENGERS_ONBOARD)
large_protection_volume_needed = true
end
if (CLASSIFICATION_MANNED in classification_vec)
classification = CLASSIFICATION_MANNED
elseif (CLASSIFICATION_UNMANNED in classification_vec)
classification = CLASSIFICATION_UNMANNED
elseif (CLASSIFICATION_SMALL_UNMANNED in classification_vec) && !large_protection_volume_needed
classification = CLASSIFICATION_SMALL_UNMANNED
else
classification = CLASSIFICATION_NONE
end
intruder.classification = classification
end
