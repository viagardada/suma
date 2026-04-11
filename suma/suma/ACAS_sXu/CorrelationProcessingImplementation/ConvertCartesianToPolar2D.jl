function ConvertCartesianToPolar2D(this::STM, mu_xy::Vector{R}, Sigma_xy::Matrix{R})
(S_xy::Matrix{R}, weights_xy::Vector{R}) = SigmaPointSample(this, mu_xy, Sigma_xy)
S_ra::Matrix{R} = zeros(size(S_xy))
for i in 1:length(weights_xy)
S_ra[1,i] = sqrt(S_xy[1,i]^2 + S_xy[3,i]^2)
S_ra[3,i] = atan(S_xy[1,i], S_xy[3,i])
S_ra[2,i] = (S_xy[2,i] * sin(S_ra[3,i])) + (S_xy[4,i] * cos(S_ra[3,i]))
S_ra[4,i] = (S_xy[2,i] * cos(S_ra[3,i])) - (S_xy[4,i] * sin(S_ra[3,i]))
end
(mu_ra, Sigma_ra) = WeightedMeanAndCovariance(S_ra, weights_xy)
return (mu_ra::Vector{R}, Sigma_ra::Matrix{R})
end
