function AddAGTTrackToReport(this::STM, report::StmReport, id::UInt32, trk::AGTTrackFile, T::R, passive_only::Bool)
min_extrap_toa_step::R = this.params["surveillance"]["min_extrap_toa_step"]
m2ft::R = geoutils.meters_to_feet
I_xydxdy::Vector{Z} = [1, 3, 2, 4]
tgt = this.target_db[id]
intruder = TRMIntruderInput()
intruder.id = id
intruder.source = SOURCE_AGT
SetClassification(this, intruder)
SetIntruderIDDirectory(tgt, intruder.id_directory)
SetCoordination(this, intruder)
SetIntruderDegradedFlags(this, intruder, tgt, trk, passive_only)
valid_vert = (0 == (intruder.degraded_surveillance & DEGRADED_SURVEILLANCE_NAR))
h_own = report.trm_input.own.belief_vert[1].z
is_large::Bool = (trk.classification != CLASSIFICATION_SMALL_UNMANNED)
trk_temp = deepcopy(trk)
dt::R = T - trk.toa
if (dt >= min_extrap_toa_step)
(trk_temp.mu_hor, trk_temp.Sigma_hor) = PredictPassiveTracker(this, trk_temp.mu_hor, trk_temp.Sigma_hor,dt, false)
ReCenterHorizontalTrackLocation(trk_temp, T)
(trk_temp.mu_vert, trk_temp.Sigma_vert) = PredictVerticalTracker(this, trk_temp.mu_vert, trk_temp.Sigma_vert, dt, trk_temp.alt_src_hae, false, is_large)
end
(mu_vert, Sigma_vert) = (trk_temp.mu_vert, trk_temp.Sigma_vert)
if (report.trm_input.own.trm_altmode != TRM_ALTMODE_NONE)
z_rel = GetRelativeAltitude(this, mu_vert[1], trk.alt_src_hae)
mu_vert[1] = z_rel + h_own
end
(mu_hor, Sigma_hor) = AbsoluteGeodeticToOwnshipRelative(this, trk_temp)
(vsamples,vweights) = AddAltBiasAndSample(this, trk, mu_vert, Sigma_vert, valid_vert, trk.alt_src_hae,is_large, T)
(mu_xydxdy, Sigma_xydxdy) = (mu_hor[I_xydxdy] * m2ft, Sigma_hor[I_xydxdy, I_xydxdy] * m2ft^2)
(hsamples, hweights) = SigmaPointSample(this, mu_xydxdy, Sigma_xydxdy)
SetIntruderBeliefStates(intruder, vsamples, vweights, hsamples, hweights)
SetDisplayDataPassive(this, report, intruder, mu_vert, mu_hor * m2ft, valid_vert, T, trk.display_arrow_current)
intruder.adsb_cccb = deepcopy(tgt.adsb_osm.adsb_cccb)
intruder.v2v_cccb = deepcopy(tgt.v2v_osm.v2v_cccb)
push!(report.trm_input.intruder,intruder)
end
