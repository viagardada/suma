function GetOwnWeightedAverages( belief_vert_own::Vector{OwnVerticalBelief} )
z_own_ave::R = 0.0
dz_own_ave::R = 0.0
for b::OwnVerticalBelief in belief_vert_own
z_own_ave = z_own_ave + (b.z * b.weight)
dz_own_ave = dz_own_ave + (b.dz * b.weight)
end
return (z_own_ave::R, dz_own_ave::R)
end
