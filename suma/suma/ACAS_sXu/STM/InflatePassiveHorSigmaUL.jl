function InflatePassiveHorSigmaUL(this::STM, mu::Vector{R}, Sigma::Matrix{R}, Q::R)
vel_min_ul::R = this.params["surveillance"]["horizontal_v2v"]["covariance_inflation"]["uncompensated_latency"]["vel_min_ul"]
mean_delay_ul::R = this.params["surveillance"]["horizontal_v2v"]["covariance_inflation"]["uncompensated_latency"]["mean_delay_ul"]
v_x::R = abs(mu[2]) + vel_min_ul
v_y::R = abs(mu[4]) + vel_min_ul
inflated_Sigma = copy(Sigma)
inflated_Sigma[1,1] = inflated_Sigma[1,1] + v_x * v_x * mean_delay_ul * mean_delay_ul
inflated_Sigma[3,3] = inflated_Sigma[3,3] + v_y * v_y * mean_delay_ul * mean_delay_ul
B::Matrix{R} = zeros(4,2)
B[1, 1] = B[3, 2] = 0.5 * mean_delay_ul * mean_delay_ul
B[2, 1] = B[4, 2] = mean_delay_ul
inflated_Sigma = inflated_Sigma + (B * Q * B')
return inflated_Sigma::Matrix{R}
end
