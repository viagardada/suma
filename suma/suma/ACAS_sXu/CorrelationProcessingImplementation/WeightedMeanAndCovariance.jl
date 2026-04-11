function WeightedMeanAndCovariance(z::Array{R}, w::Vector{R})
n = size(z,1)
p = size(z,2)
mu = zeros(n)
for i in 1:p
mu += w[i]*z[:,i]
end
Sigma = zeros(n,n)
for i in 1:p
Sigma += w[i]*(z[:,i]-mu)*(z[:,i]-mu)'
end
return (mu::Vector{R}, Sigma::Matrix{R})
end
