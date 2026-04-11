function InitializeOwnVerticalTracker(this::STM, z_int::R, dz_int::R, is_alt_geo_hae::Bool)
if is_alt_geo_hae
var_zint::R = this.params["surveillance"]["vertical"]["hae_small_ownship"]["var_zint"]
var_dzint::R = this.params["surveillance"]["vertical"]["hae_small_ownship"]["var_dzint"]
else
var_zint = this.params["surveillance"]["vertical"]["pres_small_ownship"]["var_zint"]
var_dzint = this.params["surveillance"]["vertical"]["pres_small_ownship"]["var_dzint"]
end
mu = [z_int, dz_int]
Sigma = diagm(0 => [var_zint, var_dzint])
if is_alt_geo_hae
this.own.wgs84_updates_vert = 1
else
this.own.updates_vert = 1
end
return (mu::Vector{R}, Sigma::Matrix{R})
end
