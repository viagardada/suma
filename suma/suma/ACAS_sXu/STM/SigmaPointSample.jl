function SigmaPointSample(this::STM, x::Vector{R}, Sigma::Matrix{R})
m = length(x)
kappa = m/2.0
S = zeros(m,2*m+1)
w = zeros(2*m+1)
S_u = uchol(this, Sigma)
S[:,1] = x
w[1] = kappa/(m+kappa)
for i in 2:m+1
S[:,i] = x+sqrt(m+kappa)*S_u[:,i-1]
w[i] = 1/(2*(m+kappa))
S[:,i+m] = x-sqrt(m+kappa)*S_u[:,i-1]
w[i+m] = 1/(2*(m+kappa))
end
return (S::Matrix{R}, w::Vector{R})
end
