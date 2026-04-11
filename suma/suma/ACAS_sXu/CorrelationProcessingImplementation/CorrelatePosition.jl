function CorrelatePosition(this::STM, trackA::Union{TrackFile,OwnShipData}, trackB::TrackFile, unique_scale::R, correlation_params)
altitude_gate::R = correlation_params["altitude_gate"]
range_gate::R = correlation_params["range_gate"]
altitude_inflation::R = correlation_params["altitude_inflation"]
correlation_threshold::R = correlation_params["correlation_threshold"]
correlation_alt_threshold::R = correlation_params["correlation_alt_threshold"]
correlation_az_threshold::R = correlation_params["correlation_az_threshold"]
TS1 = deepcopy(trackA.trk_summary)
TS2 = deepcopy(trackB.trk_summary)
own_valid_alt_pres::Bool = !isnan(this.own.toa_vert)
own_valid_alt_hae::Bool = !isnan(this.own.wgs84_toa_vert)
if (TS1.alt_src_hae != TS2.alt_src_hae) && TS1.valid_vert && TS2.valid_vert && own_valid_alt_pres && own_valid_alt_hae
own_pres_alt = this.own.geo_states_pres_alt.lla_rad_ft[3]
own_hae_alt = this.own.geo_states_hae_alt.lla_rad_ft[3]
if TS1.alt_src_hae
z_rel = TS1.mu_vert[1] - own_hae_alt
TS1.mu_vert[1] = z_rel + own_pres_alt
TS1.alt_src_hae = false
else
z_rel = TS1.mu_vert[1] - own_pres_alt
TS1.mu_vert[1] = z_rel + own_hae_alt
TS1.alt_src_hae = true
end
end
if (abs(TS1.mu_range[1] - TS2.mu_range[1]) > range_gate)
return false
elseif (TS1.valid_vert) && (TS2.valid_vert) && (abs(TS1.mu_vert[1] - TS2.mu_vert[1]) > altitude_gate)
return false
end
altitude_score::R = score::R = bearing_score::R = 0.0
threshold::R = correlation_threshold
bearing_comparison::Bool = (this.own.heading_state == OWN_HEADING_NOMINAL)
range_score::R = mahal(this, TS1.mu_range[1], TS1.Sigma_range[1,1], TS2.mu_range[1], TS2.Sigma_range[1,1])
rangerate_score::R = mahal(this, TS1.mu_range[2], TS1.Sigma_range[2,2], TS2.mu_range[2], TS2.Sigma_range[2,2])
if TS1.valid_vert && TS2.valid_vert
altitude_score = mahal(this, TS1.mu_vert[1], TS1.Sigma_vert[1,1], TS2.mu_vert[1], TS2.Sigma_vert[1,1])
elseif !TS1.valid_vert && !TS2.valid_vert
threshold = threshold - correlation_alt_threshold
elseif SingleNARCorrelationAuthorized(this, trackA, trackB)
threshold = threshold - correlation_alt_threshold
else
altitude_score = Inf
end
if bearing_comparison
bearing_score = mahal(this, WrapAngleDiffToPi(TS1.mu_rng_az[2],TS2.mu_rng_az[2]),TS1.Sigma_rng_az[2,2], 0, TS2.Sigma_rng_az[2,2])
if (rangerate_score < bearing_score) && (threshold < correlation_threshold)
threshold = threshold + correlation_az_threshold
end
score = altitude_score + range_score + max( bearing_score, rangerate_score)
else
score = altitude_score + range_score + rangerate_score
end
if (score < threshold*unique_scale)
return true
else
return false
end
end
