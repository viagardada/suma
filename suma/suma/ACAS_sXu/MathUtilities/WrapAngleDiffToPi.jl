function WrapAngleDiffToPi(A::R, B::R)
phi_out::R = WrapToPi(AngleDifference(A, B))
return phi_out::R
end
