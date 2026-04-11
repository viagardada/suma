function DetermineCrossing(this::TRM, dz_min::R, dz_max::R, z_own_ave::R, z_int_ave::Vector{R},
sense_int::Vector{Symbol}, code_int::Vector{UInt8}, st_own::TRMOwnState,
source_int::Vector{Z}, classification_int::Vector{UInt8} )
H_V2Vlargecrossthrhi = this.params["display"]["V2Vlargecrossthrhi"]
H_V2Vsmallcrossthrhi = this.params["display"]["V2Vsmallcrossthrhi"]
H_ORNCTcrossthrhi = this.params["display"]["ORNCTcrossthrhi"]
H_AGTcrossthrhi = this.params["display"]["AGTcrossthrhi"]
H_crossthrhi = this.params["display"]["crossthrhi"]
H_V2Vlargecrossthrlo = this.params["display"]["V2Vlargecrossthrlo"]
H_V2Vsmallcrossthrlo = this.params["display"]["V2Vsmallcrossthrlo"]
H_ORNCTcrossthrlo = this.params["display"]["ORNCTcrossthrlo"]
H_AGTcrossthrlo = this.params["display"]["AGTcrossthrlo"]
H_crossthrlo = this.params["display"]["crossthrlo"]
is_crossing::Bool = false
sense_own::Symbol = RatesToSense( dz_min, dz_max )
h_cross_thresh::R = 0
thresh_high::Bool = true
if st_own.crossing_prev
thresh_high = false
end
for i = 1:length( code_int )
if (code_int[i] == SXUCODE_RA) &&
((sense_int[i] == sense_own) || IsMTLO( this, dz_min, dz_max ))
if thresh_high
if (source_int[i] == SOURCE_ORNCT)
h_cross_thresh = H_ORNCTcrossthrhi
elseif (source_int[i] == SOURCE_AGT)
h_cross_thresh = H_AGTcrossthrhi
elseif (source_int[i] == SOURCE_V2V)
if (classification_int[i] == CLASSIFICATION_SMALL_UNMANNED)
h_cross_thresh = H_V2Vsmallcrossthrhi
else
h_cross_thresh = H_V2Vlargecrossthrhi
end
else
h_cross_thresh = H_crossthrhi
end
else
if (source_int[i] == SOURCE_ORNCT)
h_cross_thresh = H_ORNCTcrossthrlo
elseif (source_int[i] == SOURCE_AGT)
h_cross_thresh = H_AGTcrossthrlo
elseif (source_int[i] == SOURCE_V2V)
if (classification_int[i] == CLASSIFICATION_SMALL_UNMANNED)
h_cross_thresh = H_V2Vsmallcrossthrlo
else
h_cross_thresh = H_V2Vlargecrossthrlo
end
else
h_cross_thresh = H_crossthrlo
end
end
if (sense_int[i] == :Up) && (h_cross_thresh < (z_int_ave[i] - z_own_ave))
is_crossing = true
elseif (sense_int[i] == :Down) && (h_cross_thresh < (z_own_ave - z_int_ave[i]))
is_crossing = true
end
end
end
st_own.crossing_prev = is_crossing
return is_crossing::Bool
end
