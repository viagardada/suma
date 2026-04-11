function CombineVerticalBeliefs( b_vert_own::Vector{OwnVerticalBelief},
b_vert_int::Vector{IntruderVerticalBelief},
b_int::AdvisoryBeliefState )
w_vert::R = 0.0
if !b_int.need_init
w_vert_prev_sum::R = sum( b_int.w_vert_prev )
end
samples_vert::Vector{CombinedVerticalBelief} = CombinedVerticalBelief[]
b_int.w_vert_prev = R[]
for i in 1:length( b_vert_own )
for j in 1:length( b_vert_int )
if !b_int.need_init
w_vert = w_vert_prev_sum * b_vert_own[i].weight * b_vert_int[j].weight
else
w_vert = b_vert_own[i].weight * b_vert_int[j].weight
end
push!( samples_vert,
CombinedVerticalBelief( b_vert_int[j].z - b_vert_own[i].z,
b_vert_own[i].dz, b_vert_int[j].dz, w_vert )
)
push!( b_int.w_vert_prev, w_vert )
end
end
b_int.w_vert_prev = Normalize( b_int.w_vert_prev )
b_int.need_init = (length( b_int.w_vert_prev ) == 0)
for i in 1:length( samples_vert )
samples_vert[i].weight = b_int.w_vert_prev[i]
end
return samples_vert::Vector{CombinedVerticalBelief}
end
