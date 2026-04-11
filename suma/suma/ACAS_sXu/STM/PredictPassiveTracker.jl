function PredictPassiveTracker(this::STM, mu::Vector{R}, Sigma::Matrix{R}, dt::R, is_v2v::Bool)
if is_v2v
Q::R = this.params["surveillance"]["horizontal_v2v"]["Q"]
else
Q = this.params["surveillance"]["horizontal_adsb"]["Q"]
end
return Predict2DKalmanFilter(this, mu, Sigma, Q, dt)
end
