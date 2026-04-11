function AddPointObstacleTrackToDB(this::STM, trk::PointObstacleTrackFile)
tgt = Target()
tgt.point_obstacle_track = trk
AddToDB(this.target_db, tgt)
end
