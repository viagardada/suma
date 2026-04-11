function AddPointObstacleTrackToReport(this::STM, report::StmReport, id::UInt32, T::R)
m2ft::R = geoutils.meters_to_feet
tgt = this.target_db[id]
trk = tgt.point_obstacle_track
intruder = TRMIntruderInput()
intruder.id = id
intruder.source = SOURCE_POINT_OBSTACLE
intruder.classification = CLASSIFICATION_POINT_OBSTACLE
SetIntruderIDDirectory(tgt, intruder.id_directory)
SetCoordination(this, intruder)
mu_vert = [trk.lla_hae_rad_ft[3], 0.0]
if (report.trm_input.own.trm_altmode != TRM_ALTMODE_NONE)
z_rel = GetRelativeAltitude(this, mu_vert[1], true)
h_own = report.trm_input.own.belief_vert[1].z
mu_vert[1] = z_rel + h_own
end
(_, ecef, own_lla, own_ecef) = AlignAltitudeTypesUsedInGeodeticPositions(this, trk.lla_hae_rad_ft, trk.ecef_hae_m, true, true)
delta_ecef = ecef - own_ecef
delta_enu = RotateECEFToENU(delta_ecef, own_lla)
dx_rel = 0.0 - this.own.geo_states_hae_alt.vel_ew_mps
dy_rel = 0.0 - this.own.geo_states_hae_alt.vel_ns_mps
mu_hor = [delta_enu[1], dx_rel, delta_enu[2], dy_rel] * m2ft
vweights = 1.0
resize!(intruder.belief_vert,length(vweights))
intruder.belief_vert[1] = IntruderVerticalBelief()
intruder.belief_vert[1].z = mu_vert[1]
intruder.belief_vert[1].dz = mu_vert[2]
intruder.belief_vert[1].weight = vweights
hweights = 1.0
resize!(intruder.belief_horiz,length(hweights))
intruder.belief_horiz[1] = IntruderHorizontalBelief()
intruder.belief_horiz[1].x_rel = mu_hor[1]
intruder.belief_horiz[1].dx_rel = mu_hor[2]
intruder.belief_horiz[1].y_rel = mu_hor[3]
intruder.belief_horiz[1].dy_rel = mu_hor[4]
intruder.belief_horiz[1].weight = hweights
SetDisplayDataPassive(this, report, intruder, mu_vert, mu_hor, true, T, DISPLAY_ARROW_LEVEL)
intruder.adsb_cccb = deepcopy(tgt.adsb_osm.adsb_cccb)
intruder.v2v_cccb = deepcopy(tgt.v2v_osm.v2v_cccb)
push!(report.trm_input.intruder,intruder)
end
