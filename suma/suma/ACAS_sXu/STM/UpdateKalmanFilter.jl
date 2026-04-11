function UpdateKalmanFilter(o::Union{R, Vector{R}}, mu_s::Vector{R}, Sigma_s::Matrix{R}, H::Matrix{R}, R_k::Union{R, Matrix{R}})
S = H*Sigma_s*H' .+ R_k
K = Sigma_s * H' * inv(S)
mu = mu_s + K*(o .- H*mu_s)
I = eye(size(Sigma_s,1))
Sigma = (I - K*H)*Sigma_s*(I - K*H)' + K*R_k*K'
return (mu::Vector{R}, Sigma::Matrix{R})
end
