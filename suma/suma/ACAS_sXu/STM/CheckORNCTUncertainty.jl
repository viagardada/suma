function CheckORNCTUncertainty(this::STM, range_ft::R, rel_xgrgr_Sigma::Matrix{R}, rel_z_ft::R, rel_dz_fps::R, rel_zdz_Sigma::Matrix{R})
scalar::R = this.params["surveillance"]["ornct"]["variance_check_scalar"]
range_floor::R = this.params["surveillance"]["ornct"]["variance_check_range_floor"]
bound_sr_cos_el::Vector{R} = this.params["surveillance"]["ornct"]["variance_bound_sr_cos_el"]
bound_sr_sin_el::Vector{R} = this.params["surveillance"]["ornct"]["variance_bound_sr_sin_el"]
bound_cos_el::Vector{R} = this.params["surveillance"]["ornct"]["variance_bound_cos_el"]
bound_sin_el::Vector{R} = this.params["surveillance"]["ornct"]["variance_bound_sin_el"]
I_hor::Vector{Z} = 1:4
I_vert::Vector{Z} = [5,6]
el = abs(atan(rel_z_ft, range_ft))
sr = max(SlantRange(range_ft, rel_z_ft), range_floor)
variance_bound = (sr*cos(el)*bound_sr_cos_el).^2 +
(sr*sin(el)*bound_sr_sin_el).^2 +
(cos(el)*bound_cos_el).^2 +
(sin(el)*bound_sin_el).^2
variance_bound = scalar^2 * variance_bound
hor_sigmas_too_large::Bool = any(diag(rel_xgrgr_Sigma) .> variance_bound[I_hor])
vert_sigmas_too_large::Bool = any(diag(rel_zdz_Sigma) .> variance_bound[I_vert])
valid_hor::Bool = ValidCovarianceMatrix(rel_xgrgr_Sigma) && !hor_sigmas_too_large
valid_vert::Bool = !isnan(rel_z_ft) && !isnan(rel_dz_fps) && ValidCovarianceMatrix(rel_zdz_Sigma) && !vert_sigmas_too_large
return (valid_hor::Bool, valid_vert::Bool)
end
