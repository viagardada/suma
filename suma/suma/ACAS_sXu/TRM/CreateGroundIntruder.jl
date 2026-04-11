function CreateGroundIntruder( z::R, h_agl::R)
intruder = TRMIntruderInput()
intruder.id = ID_GROUND
intruder.classification = CLASSIFICATION_GROUND
intruder.degraded_surveillance = DEGRADED_SURVEILLANCE_NONE
mu_vert = [z - h_agl, 0.0]
mu_hor = [0.0, 0.0, 0.0, 0.0]
vweights = 1.0
resize!(intruder.belief_vert,length(vweights))
intruder.belief_vert[1] = IntruderVerticalBelief()
intruder.belief_vert[1].z = mu_vert[1]
intruder.belief_vert[1].dz = mu_vert[2]
intruder.belief_vert[1].weight = vweights
hweights = 1.0
resize!(intruder.belief_horiz,length(hweights))
intruder.belief_horiz[1] = IntruderHorizontalBelief()
intruder.belief_horiz[1].x_rel = mu_hor[1]
intruder.belief_horiz[1].dx_rel = mu_hor[2]
intruder.belief_horiz[1].y_rel = mu_hor[3]
intruder.belief_horiz[1].dy_rel = mu_hor[4]
intruder.belief_horiz[1].weight = hweights
return (intruder::TRMIntruderInput)
end
