function ENUToECEFRotation(phi::R, lambda::R)
s_phi = sin(phi)
c_phi = cos(phi)
s_lambda = sin(lambda)
c_lambda = cos(lambda)
R0::Matrix{R} = [-s_lambda -s_phi*c_lambda c_phi*c_lambda;
c_lambda -s_phi*s_lambda c_phi*s_lambda;
0 c_phi s_phi]
return R0::Matrix{R}
end
