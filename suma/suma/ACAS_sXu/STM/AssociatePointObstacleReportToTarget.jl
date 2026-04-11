function AssociatePointObstacleReportToTarget(this::STM, po_id::UInt32)
for id in keys(this.target_db)
tgt = this.target_db[id]
if (TrackExists(tgt.point_obstacle_track))
trk::PointObstacleTrackFile = tgt.point_obstacle_track
if (trk.po_id == po_id)
return (id::UInt32)
end
end
end
return NO_TARGET_FOUND::UInt32
end
