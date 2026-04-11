function UpdateHeadingTracker(this::STM, Psi::R, mu_s::Vector{R}, Sigma_s::Matrix{R})
R_k::R = this.params["surveillance"]["ownship_heading"]["R"]
H::Matrix{R} = [1.0 0.0]
S = H*Sigma_s*H' .+ R_k
K = Sigma_s* H'*inv(S)
mu = mu_s + K*[WrapAngleDiffToPi(mu_s[1],Psi)]
mu[1] = WrapToPi(mu[1])
Sigma = Sigma_s - K*S*K'
return (mu::Vector{R}, Sigma::Matrix{R})
end
