function AddORNCTTrackToReport(this::STM, report::StmReport, id::UInt32, T::R)
min_extrap_toa_step::R = this.params["surveillance"]["min_extrap_toa_step"]
I_xydxdy::Vector{Z} = [1, 3, 2, 4]
tgt = this.target_db[id]
trk = tgt.ornct_track
intruder = TRMIntruderInput()
intruder.id = id
intruder.source = SOURCE_ORNCT
SetClassification(this, intruder)
SetIntruderIDDirectory(tgt, intruder.id_directory)
SetCoordination(this, intruder)
SetIntruderDegradedFlags(this, intruder, tgt, trk, false)
valid_vert = (0 == (intruder.degraded_surveillance & DEGRADED_SURVEILLANCE_NAR))
valid_rel_z = copy(trk.valid_vert)
(mu_vert::Vector{R}, Sigma_vert::Matrix{R}) = (trk.mu_vert, trk.Sigma_vert)
(mu_rng::Vector{R}, Sigma_rng::Matrix{R}) = (trk.mu_rng, trk.Sigma_rng)
(mu_cart::Vector{R}, Sigma_cart::Matrix{R} ) = (trk.mu_cart, trk.Sigma_cart)
dt::R = T - trk.toa
if (dt >= min_extrap_toa_step)
(mu_vert, Sigma_vert, mu_rng, Sigma_rng, mu_cart, Sigma_cart) = PredictORNCTTrack(this, trk, dt)
end
if (report.trm_input.own.trm_altmode != TRM_ALTMODE_NONE)
zdz_rel = mu_vert
hdh_own = [report.trm_input.own.belief_vert[1].z, report.trm_input.own.belief_vert[1].dz]
mu_vert = zdz_rel + hdh_own
end
(vsamples,vweights) = SigmaPointSample(this, mu_vert, Sigma_vert)
(hsamples,hweights) = SigmaPointSample(this, mu_cart[I_xydxdy], Sigma_cart[I_xydxdy, I_xydxdy])
SetIntruderBeliefStates(intruder, vsamples, vweights, hsamples, hweights)
SetDisplayDataORNCT(this, report, intruder, mu_vert, mu_cart, mu_rng, valid_vert, valid_rel_z, T, trk.display_arrow_current)
intruder.adsb_cccb = deepcopy(tgt.adsb_osm.adsb_cccb)
intruder.v2v_cccb = deepcopy(tgt.v2v_osm.v2v_cccb)
push!(report.trm_input.intruder,intruder)
end
