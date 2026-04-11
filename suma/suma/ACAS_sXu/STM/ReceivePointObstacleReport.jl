function ReceivePointObstacleReport(this::STM, po_id::UInt32, lat_deg::R, lon_deg::R, alt_hae_ft::R, to_be_deleted::Bool)
if ( !isnan(lat_deg) && !isnan(lon_deg) && !isnan(alt_hae_ft) ) || to_be_deleted
id = AssociatePointObstacleReportToTarget(this, po_id)
if !to_be_deleted
if (id == NO_TARGET_FOUND)
trk = PointObstacleTrackFile()
trk.po_id = po_id
trk.lla_hae_rad_ft = [deg2rad(lat_deg), deg2rad(lon_deg), alt_hae_ft]
trk.ecef_hae_m = ConvertWGS84ToECEF(trk.lla_hae_rad_ft, true)
AddPointObstacleTrackToDB(this, trk)
else
tgt = RetrieveWithID(this.target_db, id)
trk = tgt.point_obstacle_track
trk.po_id = po_id
trk.lla_hae_rad_ft = [deg2rad(lat_deg), deg2rad(lon_deg), alt_hae_ft]
trk.ecef_hae_m = ConvertWGS84ToECEF(trk.lla_hae_rad_ft, true)
end
elseif (id != NO_TARGET_FOUND)
delete!(this.target_db, id)
end
end
end
