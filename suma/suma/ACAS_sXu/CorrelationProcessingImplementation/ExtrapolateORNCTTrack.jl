function ExtrapolateORNCTTrack(this::STM, trk::ORNCTTrackFile, T::R)
lag_uncertainty::Vector{R} = this.params["surveillance"]["ornct"]["lag_uncertainty_minimum"]
cgr_uncertainty::R = this.params["surveillance"]["ornct"]["cgr_uncertainty_minimum"]
I_xy::Vector{Z} = [1,3]
dt = T - trk.toa
TS::TrackSummary = trk.trk_summary
(TS.mu_vert, TS.Sigma_vert, TS.mu_range, TS.Sigma_range, mu_xy, Sigma_xy) = PredictORNCTTrack(this, trk, dt)
zdz_rel = TS.mu_vert
hdh_own = this.own.trk_summary.mu_vert
TS.mu_vert = zdz_rel + hdh_own
TS.alt_src_hae = this.own.trk_summary.alt_src_hae
(TS.mu_rng_az, TS.Sigma_rng_az) = LinearTransform(mu_xy[I_xy], Sigma_xy[I_xy,I_xy])
TS.Sigma_range[1,1] = max(TS.Sigma_range[1,1], lag_uncertainty[1]^2)
TS.Sigma_rng_az[2,2] = max(TS.Sigma_rng_az[2,2], lag_uncertainty[2]^2)
TS.Sigma_rng_az[2,2] = max(TS.Sigma_rng_az[2,2], atan(cgr_uncertainty, TS.mu_rng_az[1,1])^2)
TS.valid_rng = true
TS.valid_vert = trk.valid_vert && this.own.trk_summary.valid_vert
end
