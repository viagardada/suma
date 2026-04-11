function GetPresAEMSigma(this::STM, alt_pres_ft::R, pres_aem_sigmas::Vector{R})
aem_max_pres_alt::Vector{Z} = this.params["surveillance"]["vertical"]["aem_max_pres_alt"]
pres_alt_bias_sigma::R = 0
for i in 1:length(aem_max_pres_alt)
if (alt_pres_ft < aem_max_pres_alt[i])
pres_alt_bias_sigma = pres_aem_sigmas[i]
break
end
end
return pres_alt_bias_sigma::R
end
