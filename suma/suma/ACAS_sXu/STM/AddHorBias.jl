function AddHorBias(this::STM, trk::V2VTrackFile)
Q_ul::R = this.params["surveillance"]["horizontal_v2v"]["covariance_inflation"]["uncompensated_latency"]["Q_ul"]
init_NACp_bias::UInt32 = this.params["surveillance"]["horizontal_v2v"]["covariance_inflation"]["init_NACp_bias"]
init_NACv_bias::UInt32 = this.params["surveillance"]["horizontal_v2v"]["covariance_inflation"]["init_NACv_bias"]
nacp_factor::R = this.params["surveillance"]["horizontal_v2v"]["covariance_inflation"]["nacp_factor"]
nacv_factor::R = this.params["surveillance"]["horizontal_v2v"]["covariance_inflation"]["nacv_factor"]
trk.Sigma_hor = InflatePassiveHorSigmaUL(this, trk.mu_hor, trk.Sigma_hor, Q_ul)
if (trk.nacp == 0)
NACp = init_NACp_bias
NACv = init_NACv_bias
else
NACp = trk.nacp
NACv = trk.nacv
end
NPInflate::R = (ConvertNACpToSigmaHEPU(NACp) * nacp_factor)^2
NVInflate::R = (ConvertNACvToSigmaHVA(NACv) * nacv_factor)^2
trk.Sigma_hor += diagm(0 => [NPInflate, NVInflate, NPInflate, NVInflate])
trk.Sigma_hor += this.own.wgs84_Sigma_hor .* eye(4)
return
end
