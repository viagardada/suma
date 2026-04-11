function IsOutlier(this::STM, o::Union{R, Vector{R}}, mu::Union{R, Vector{R}}, Sigma::Union{R, Matrix{R}}, thresh::R)
if (thresh > 0) && (!any(isnan, o)) && (!any(isnan, mu)) && (!any(isnan, Sigma))
D = mahal(this, o, Sigma, mu, 0)^2
return (D >= thresh)::Bool
else
return false
end
end
