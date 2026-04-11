function SetOwnshipData(this::STM, report::StmReport, t::R)
# Deviation potential: Refer to ACAS sXu MOPS Vol. I section 1
max_coasts_agt::R = this.params["surveillance"]["agt"]["max_coasts"]
pres_aem_sigma::Vector{R} = this.params["surveillance"]["vertical"]["pres_small_ownship"]["aem_sigma"]
report.trm_input.own.h = this.own.h_agl
report.trm_input.own.v2v_uid = this.own.v2v_uid
report.trm_input.own.v2v_uid_valid = this.own.v2v_uid_valid
for i in reverse(1:length(this.own.agt_tracks))
dt = t - this.own.agt_tracks[i].toa_update
if (dt > max_coasts_agt)
deleteat!(this.own.agt_tracks,i)
end
end
for trk in this.own.agt_tracks
push!(report.trm_input.own.agt_ids, trk.agt_id)
end
report.trm_input.own.opmode = this.own.opmode
SetOwnshipVelocity(this, report, t)
UpdateHorizontalVelocityMode(this)
report.trm_input.own.trm_velmode = this.own.trm_velmode
report.own_v2v_osm = this.own.v2v_osm
report.trm_input.own.effective_turn_rate = this.own.discrete.effective_turn_rate
report.trm_input.own.effective_vert_rate = this.own.discrete.effective_vert_rate
valid_alt_pres::Bool = !isnan(this.own.toa_vert)
valid_alt_hae::Bool = !isnan(this.own.wgs84_toa_vert)
SetOwnshipDegradedFlags(this, report, valid_alt_pres, valid_alt_hae)
if valid_alt_pres
dt = t - this.own.toa_vert
(mu_pres, _) = PredictVerticalTracker(this, this.own.mu_vert, this.own.Sigma_vert, dt, false, true, false)
pres_alt_bias_sigma::R = GetPresAEMSigma(this, mu_pres[1], pres_aem_sigma)
end
if valid_alt_hae
dt = t - this.own.wgs84_toa_vert
(mu_hae, _) = PredictVerticalTracker(this, this.own.wgs84_mu_vert, this.own.wgs84_Sigma_vert, dt, true, true, false)
end
if valid_alt_hae && (!valid_alt_pres || (this.own.wgs84_sigma_vepu < pres_alt_bias_sigma))
mu = mu_hae
report.trm_input.own.trm_altmode = TRM_ALTMODE_HAE
elseif valid_alt_pres
mu = mu_pres
report.trm_input.own.trm_altmode = TRM_ALTMODE_PRESSURE
else
mu = [NaN, NaN]
report.trm_input.own.trm_altmode = TRM_ALTMODE_NONE
end
report.trm_input.own.perform_gpoa = !this.own.discrete.disable_gpoa
resize!(report.trm_input.own.belief_vert,1)
report.trm_input.own.belief_vert[1] = OwnVerticalBelief()
report.trm_input.own.belief_vert[1].z = mu[1]
report.trm_input.own.belief_vert[1].dz = mu[2]
report.trm_input.own.belief_vert[1].weight = 1.0
return
end
