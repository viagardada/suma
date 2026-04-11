function AddAltBiasAndSample(this::STM, trk::Union{ADSBTrackFile,V2VTrackFile,AGTTrackFile}, mu::Vector{R},Sigma::Matrix{R}, valid::Bool, is_alt_geo_hae::Bool, is_large::Bool, T::R)
aem_sigma_own::Vector{R} = this.params["surveillance"]["vertical"]["pres_small_ownship"]["aem_sigma"]
if is_large
aem_sigma = this.params["surveillance"]["vertical"]["pres_large_intruder"]["aem_sigma"]
else
aem_sigma = this.params["surveillance"]["vertical"]["pres_small_intruder"]["aem_sigma"]
end
if valid
if isa(trk, AGTTrackFile)
alt_bias_sigma::R = 0.0
elseif !is_alt_geo_hae
alt_bias_sigma = GetPresAEMSigma(this, mu[1], aem_sigma)
elseif isa(trk, ADSBTrackFile)
alt_bias_sigma = ConvertGVAToSigmaVEPU(trk)
elseif isa(trk, V2VTrackFile)
alt_bias_sigma = trk.sigma_vepu
end
if !is_alt_geo_hae
(alt_own, Sigma_vert_own) = PresAltAtToa(this, T)
alt_bias_sigma_own::R = GetPresAEMSigma(this, alt_own, aem_sigma_own)
else
(_, Sigma_vert_own) = HAEAltAtToa(this, T)
alt_bias_sigma_own = this.own.wgs84_sigma_vepu
end
inflated_Sigma = Sigma + Sigma_vert_own
inflated_Sigma[1,1] += alt_bias_sigma^2 + alt_bias_sigma_own^2
return SigmaPointSample(this, mu,inflated_Sigma)
else
return (fill(NaN,2,5), fill(NaN,5))
end
end
