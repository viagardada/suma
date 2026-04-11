function TargetIsEmpty( tgt::Target )
return (!TrackExists(tgt.adsb_track)) &&
(!TrackExists(tgt.agt_tracks)) &&
(!TrackExists(tgt.v2v_track)) &&
(!TrackExists(tgt.point_obstacle_track)) &&
(!TrackExists(tgt.ornct_track))::Bool
end
