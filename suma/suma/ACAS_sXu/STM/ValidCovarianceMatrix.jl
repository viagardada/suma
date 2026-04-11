function ValidCovarianceMatrix(Sigma::Matrix{R})
if any(isnan, Sigma) || any(isinf, Sigma)
valid::Bool = false
else
eigenvalues = eigvals(Sigma)
valid = (typeof(eigenvalues) != Array{Complex{R},1}) && all(eigenvalues .> 0) && !any(eigenvalues.== Inf)
end
return valid::Bool
end
