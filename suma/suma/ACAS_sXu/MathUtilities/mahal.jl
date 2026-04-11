function mahal(this::STM, muA::Union{Vector{R},R,Z}, SigmaA::Union{Matrix{R},R,Z}, muB::Union{Vector{R},R,Z}, SigmaB::Union{Matrix{R},R,Z})
psd_stability_factor::R = this.params["surveillance"]["psd_stability_factor"]
Sigma = copy(SigmaA)
if (SigmaB != 0)
Sigma = SigmaA .+ SigmaB
end
dmu = muA
if (muB != 0)
dmu = muA .- muB
end
if (ndims(Sigma) == 2)
if any( diag(Sigma) .< psd_stability_factor )
Sigma = Sigma + psd_stability_factor*eye(size(Sigma,1))
end
D = dmu' * inv(Sigma) * dmu
D = D[1]
else
D = (dmu * dmu) / Sigma
end
return sqrt(D)::R
end
