function HeadingAtToa(this::STM, t::R)
Q::R = this.params["surveillance"]["ownship_heading"]["Q"]
heading::R = NaN
if (this.own.heading_initialized)
if (length(this.own.history.heading.time) > 1) && (t < maximum(this.own.history.heading.time))
(time1, time2, h1, h2) = SurroundingPoints(this.own.history.heading.time, this.own.history.heading.value, t)
rate::R = AngleDifference(h1, h2) / (time2 - time1)
heading = WrapToPi(h1 + rate * (t - time1))
elseif (this.own.heading_state != OWN_HEADING_INVALID)
dt = t - this.own.toa_heading
(mu_s, Sigma_s) = Predict1DKalmanFilter(this, this.own.mu_heading, this.own.Sigma_heading, Q, dt)
heading = WrapToPi(mu_s[1])
else
heading = 0.0
end
end
return heading::R
end
