function AddTracksToReport(this::STM, report::StmReport, t::R)
for id in keys(this.target_db)
if (RemoveStaleTracks(this, id,t))
tgt = this.target_db[id]
aircraft_trk = TrackSourceSelection(this, id, t)
aircraft_trk_exists::Bool = TrackExists(aircraft_trk)
point_obstacle_trk_exists::Bool = TrackExists(tgt.point_obstacle_track)
point_obstacle_acceptable::Bool = (this.own.wgs84_state == OWN_WGS84_VALID) && !isnan(this.own.wgs84_toa_vert)
if aircraft_trk_exists
if (typeof(aircraft_trk) == ADSBTrackFile)
AddADSBTrackToReport(this, report, id, t, !ValidationCheck(aircraft_trk))
elseif (typeof(aircraft_trk) == V2VTrackFile)
AddV2VTrackToReport(this, report, id, t, !ValidationCheck(aircraft_trk))
elseif (typeof(aircraft_trk) == ORNCTTrackFile)
AddORNCTTrackToReport(this, report, id, t)
elseif (typeof(aircraft_trk) == AGTTrackFile)
AddAGTTrackToReport(this, report, id, aircraft_trk, t, !ValidationCheck(aircraft_trk))
end
elseif point_obstacle_trk_exists && point_obstacle_acceptable && this.own.discrete.perform_poa
AddPointObstacleTrackToReport(this, report, id, t)
end
end
end
FilterTracksForTRM(this, report)
end
