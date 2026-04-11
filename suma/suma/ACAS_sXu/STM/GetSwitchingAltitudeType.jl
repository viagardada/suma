function GetSwitchingAltitudeType(this::STM, trk::Union{V2VTrackFile, AGTTrackFile}, alt_pres_ft::R, alt_hae_ft::R, valid_alt_pres::Bool, valid_alt_hae::Bool, sigma_vepu_ft::R, is_large::Bool)
epsilon_sigma_ft::R = this.params["surveillance"]["vertical"]["epsilon_sigma_ft"]
max_switch_alt_count::Z = this.params["surveillance"]["vertical"]["max_switch_alt_count"]
if is_large
pres_aem_sigma = this.params["surveillance"]["vertical"]["pres_large_intruder"]["aem_sigma"]
else
pres_aem_sigma::Vector{R} = this.params["surveillance"]["vertical"]["pres_small_intruder"]["aem_sigma"]
end
pres_alt_bias_sigma::R = GetPresAEMSigma(this, alt_pres_ft, pres_aem_sigma)
own_valid_alt_pres::Bool = !isnan(this.own.toa_vert)
own_valid_alt_hae::Bool = !isnan(this.own.wgs84_toa_vert)
own_only_has_pres::Bool = own_valid_alt_pres && !own_valid_alt_hae
own_only_has_hae::Bool = own_valid_alt_hae && !own_valid_alt_pres
own_single_source::Bool = own_only_has_pres || own_only_has_hae
if !trk.valid_vert || own_single_source
trk.switch_alt_count = max_switch_alt_count
must_use_hae = valid_alt_hae && (!valid_alt_pres || own_only_has_hae)
must_use_pres = valid_alt_pres && (!valid_alt_hae || own_only_has_pres)
hae_better_quality = valid_alt_hae && valid_alt_pres && (sigma_vepu_ft < pres_alt_bias_sigma)
alt_src_hae = (must_use_hae || hae_better_quality) && !must_use_pres
else
if trk.alt_src_hae
switch_alt = valid_alt_pres && ( (!valid_alt_hae) || (sigma_vepu_ft > (pres_alt_bias_sigma + epsilon_sigma_ft)) )
else
switch_alt = valid_alt_hae && ( (!valid_alt_pres) || (sigma_vepu_ft < (pres_alt_bias_sigma - epsilon_sigma_ft)) )
end
if switch_alt
if (0 < trk.switch_alt_count)
trk.switch_alt_count -= 1
alt_src_hae = trk.alt_src_hae
else
trk.switch_alt_count = max_switch_alt_count
alt_src_hae = !trk.alt_src_hae
end
else
trk.switch_alt_count = max_switch_alt_count
alt_src_hae = trk.alt_src_hae
end
end
if alt_src_hae
alt = alt_hae_ft
else
alt = alt_pres_ft
end
return (alt::R, alt_src_hae::Bool)
end
