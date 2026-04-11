function PredictKalmanFilter(mu::Vector{R}, Sigma::Matrix{R}, F::Matrix{R}, G::Matrix{R}, Q::Union{R, Matrix{R}})
mu_s = F*mu
Sigma_s = (F*Sigma*F') + (G*Q*G')
return (mu_s::Vector{R}, Sigma_s::Matrix{R})
end
