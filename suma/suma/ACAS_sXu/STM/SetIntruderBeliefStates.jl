function SetIntruderBeliefStates(intruder::TRMIntruderInput, vsamples_zdz::Matrix{R}, vweights::Vector{R},hsamples_xydxdy::Matrix{R}, hweights::Vector{R})
resize!(intruder.belief_vert, length(vweights))
for j in 1:length(vweights)
intruder.belief_vert[j] = IntruderVerticalBelief()
intruder.belief_vert[j].z = vsamples_zdz[1,j]
intruder.belief_vert[j].dz = vsamples_zdz[2,j]
intruder.belief_vert[j].weight = vweights[j]
end
resize!(intruder.belief_horiz,length(hweights))
for j in 1:length(hweights)
intruder.belief_horiz[j] = IntruderHorizontalBelief()
intruder.belief_horiz[j].x_rel = hsamples_xydxdy[1,j]
intruder.belief_horiz[j].y_rel = hsamples_xydxdy[2,j]
intruder.belief_horiz[j].dx_rel = hsamples_xydxdy[3,j]
intruder.belief_horiz[j].dy_rel = hsamples_xydxdy[4,j]
intruder.belief_horiz[j].weight = hweights[j]
end
end
