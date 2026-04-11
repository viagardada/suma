function RedefineEstimateInRotatedFrame(mu_hor_0::Vector{R}, Sigma_hor_0::Matrix{R}, lla_0::Vector{R}, ecef_0::Vector{R}, lla_1::Vector{R}, ecef_1::Vector{R})
I_pos::Vector{Z} = [1, 3]
I_vel::Vector{Z} = [2, 4]
I_output::Vector{Z} = [1, 3, 2, 4]
R_0_to_1 = PolarAlignmentHorizontalRotation(lla_0, ecef_0, lla_1, ecef_1)
(mu_hor_1::Vector{R}, Sigma_hor_1::Matrix{R}) =
MatrixRotation(mu_hor_0, Sigma_hor_0, I_pos, I_vel, I_output, R_0_to_1)
return (mu_hor_1::Vector{R}, Sigma_hor_1::Matrix{R})
end
