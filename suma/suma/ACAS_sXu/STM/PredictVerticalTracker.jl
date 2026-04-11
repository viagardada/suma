function PredictVerticalTracker(this::STM, mu::Vector{R}, Sigma::Matrix{R}, dt::R, is_alt_geo_hae::Bool, is_ownship::Bool,is_large::Bool)
if is_alt_geo_hae
if is_ownship
Q::R = this.params["surveillance"]["vertical"]["hae_small_ownship"]["Q"]
else
if is_large
Q = this.params["surveillance"]["vertical"]["hae_large_intruder"]["Q"]
else
Q = this.params["surveillance"]["vertical"]["hae_small_intruder"]["Q"]
end
end
else
if is_ownship
Q = this.params["surveillance"]["vertical"]["pres_small_ownship"]["Q"]
else
if is_large
Q = this.params["surveillance"]["vertical"]["pres_large_intruder"]["Q"]
else
Q = this.params["surveillance"]["vertical"]["pres_small_intruder"]["Q"]
end
end
end
return Predict1DKalmanFilter(this, mu, Sigma, Q, dt)
end
