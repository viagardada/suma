function Predict2DKalmanFilter(this::STM, mu::Vector{R}, Sigma::Matrix{R}, Q::R, dt::R)
min_extrap_toa_step::R = this.params["surveillance"]["min_extrap_toa_step"]
if (dt < min_extrap_toa_step)
mu_pred = copy(mu)
Sigma_pred = copy(Sigma)
else
F = [1 dt 0 0 ;
0 1 0 0 ;
0 0 1 dt ;
0 0 0 1 ]
Gdt = 0.5*dt^2
G = [Gdt 0 ;
dt 0 ;
0 Gdt;
0 dt ]
(mu_pred, Sigma_pred) = PredictKalmanFilter(mu, Sigma, F, G, Q)
end
return (mu_pred::Vector{R}, Sigma_pred::Matrix{R})
end
