function OfflineStatesScaleFactor( sample_vert::CombinedVerticalBelief, vtable_max::CombinedVerticalBelief )
scale_factor::R = 1.0
if (abs( vtable_max.dz_own ) < abs( sample_vert.dz_own ))
scale_factor = abs( vtable_max.dz_own / sample_vert.dz_own )
end
if (abs( vtable_max.dz_int ) < abs( sample_vert.dz_int ))
scale_factor = min( scale_factor, abs( vtable_max.dz_int / sample_vert.dz_int ) )
end
return scale_factor::R
end
