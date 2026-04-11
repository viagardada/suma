function AssessVerticalValidity(this::STM, trk::Union{ADSBTrackFile, V2VTrackFile, AGTTrackFile, ORNCTTrackFile})
min_gva::UInt32 = this.params["surveillance"]["report_generation"]["min_adsb_quality"]["gva"]
own_valid_alt_pres::Bool = !isnan(this.own.toa_vert)
own_valid_alt_hae::Bool = !isnan(this.own.wgs84_toa_vert)
valid_vert = copy(trk.valid_vert)
if isa(trk, ORNCTTrackFile)
valid_vert = valid_vert && (own_valid_alt_pres || own_valid_alt_hae)
else
compatible_alt_types::Bool = (trk.alt_src_hae && own_valid_alt_hae) || (!trk.alt_src_hae && own_valid_alt_pres)
valid_vert = valid_vert && compatible_alt_types
if isa(trk, ADSBTrackFile)
invalid_gva::Bool = trk.alt_src_hae && ((trk.gva < min_gva) || isnan(ConvertGVAToSigmaVEPU(trk)))
valid_vert = valid_vert && !invalid_gva
end
end
return valid_vert::Bool
end
