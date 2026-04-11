function MatrixRotation( mu::Vector{R} , Sigma::Matrix{R}, I_pos::Vector{Z}, I_vel::Vector{Z},
I_output::Vector{Z}, R0::Matrix{R} )
mu_p = mu[I_pos]
mu_v = mu[I_vel]
mu_p_R = R0 * mu_p
mu_v_R = R0 * mu_v
mu_pv_R = [ mu_p_R; mu_v_R]
mu_R = mu_pv_R[I_output]
Sigma_PP::Matrix{R} = Sigma[I_pos, I_pos]
Sigma_PV::Matrix{R} = Sigma[I_pos, I_vel]
Sigma_VP::Matrix{R} = Sigma[I_vel, I_pos]
Sigma_VV::Matrix{R} = Sigma[I_vel, I_vel]
Sigma_PP_R::Matrix{R} = R0 * Sigma_PP * R0'
Sigma_PV_R::Matrix{R} = R0 * Sigma_PV * R0'
Sigma_VP_R::Matrix{R} = R0 * Sigma_VP * R0'
Sigma_VV_R::Matrix{R} = R0 * Sigma_VV * R0'
Sigma_PPVV_R::Matrix{R} = [Sigma_PP_R Sigma_PV_R; Sigma_VP_R Sigma_VV_R]
Sigma_R = Sigma_PPVV_R[I_output, I_output]
Sigma_R = (Sigma_R + Sigma_R') / 2.0
return (mu_R::Vector{R}, Sigma_R::Matrix{R})
end
