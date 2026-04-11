function LookupEntryDistribution(this::TRM, mode_int::Z, datum::Vector{R}, table::RDataTableScaled, num_blocks::Z,idx_scale::Z )
T_threshold_factor::R = this.params["modes"][mode_int]["state_estimation"]["tau"]["threshold_factor"]
w_samp::Vector{R} = zeros( R, num_blocks + 1 )
w_interp::Vector{R} = InterpolateBlocks( datum, table, num_blocks, idx_scale )
threshold::R = T_threshold_factor * nanmax( nanmaximum( w_interp ), 1.0 - sum( w_interp ) )
for j = 1:num_blocks
if (threshold <= w_interp[j])
w_samp[j] = w_interp[j]
end
end
w_samp[end] = 1.0 - sum( w_samp )
return w_samp::Vector{R}
end
