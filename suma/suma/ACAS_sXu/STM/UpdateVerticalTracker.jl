function UpdateVerticalTracker(this::STM, o::Union{R, Vector{R}}, q_int::UInt32, mu_s::Vector{R}, Sigma_s::Matrix{R},is_alt_geo_hae::Bool, is_ownship::Bool, is_large::Bool)
partition_thresh::R = this.params["surveillance"]["vertical"]["partition_estimator_threshold"]
if is_alt_geo_hae
if is_ownship
R_k = this.params["surveillance"]["vertical"]["hae_small_ownship"]["R"]
else
if is_large
R_k = this.params["surveillance"]["vertical"]["hae_large_intruder"]["R"]
else
R_k = this.params["surveillance"]["vertical"]["hae_small_intruder"]["R"]
end
end
else
if is_ownship
R_k = this.params["surveillance"]["vertical"]["pres_small_ownship"]["R"]
else
if is_large
R_k = this.params["surveillance"]["vertical"]["pres_large_intruder"]["R"]
else
R_k = this.params["surveillance"]["vertical"]["pres_small_intruder"]["R"]
end
end
end
m::Z = length(o)
if (m == 1)
H::Matrix{R} = [1.0 0.0]
else
H = [1.0 0.0; 0.0 1.0]
end
use_partition_estimator::Bool = (q_int > partition_thresh) && (m == 1)
(mu_o, Sigma_o) = (o, zeros(m,m))
if use_partition_estimator
S = H*Sigma_s*H' .+ R_k
(mu_o, Sigma_o) = PredictedAltitude(this, o, mu_s, S[1,1], q_int)
end
(mu, Sigma) = UpdateKalmanFilter(mu_o, mu_s, Sigma_s, H, R_k)
if use_partition_estimator
K = Sigma_s*H'*inv(S)
Sigma += K*Sigma_o*K'
end
return (mu::Vector{R}, Sigma::Matrix{R})
end
