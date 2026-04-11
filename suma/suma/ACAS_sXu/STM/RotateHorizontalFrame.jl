function RotateHorizontalFrame(mu_h::Vector{R}, Sigma_h::Matrix{R}, angle::R)
R0 = [ cos(angle) -sin(angle);
sin(angle) cos(angle); ]
I_pos::Vector{Z} = [1, 2]
I_vel::Vector{Z} = [3, 4]
I_output::Vector{Z} = [I_pos; I_vel]
(mu_cart, Sigma_cart) = MatrixRotation(mu_h, Sigma_h, I_pos, I_vel, I_output, R0)
return (mu_cart::Vector{R}, Sigma_cart::Matrix{R})
end
