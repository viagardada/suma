function InitializeVerticalTracker(this::STM, trk::Union{ADSBTrackFile, V2VTrackFile}, z_int::R, is_alt_geo_hae::Bool, is_large::Bool)
if is_alt_geo_hae
if is_large
var_zint::R = this.params["surveillance"]["vertical"]["hae_large_intruder"]["var_zint"]
var_dzint::R = this.params["surveillance"]["vertical"]["hae_large_intruder"]["var_dzint"]
else
var_zint = this.params["surveillance"]["vertical"]["hae_small_intruder"]["var_zint"]
var_dzint = this.params["surveillance"]["vertical"]["hae_small_intruder"]["var_dzint"]
end
else
if is_large
var_zint = this.params["surveillance"]["vertical"]["pres_large_intruder"]["var_zint"]
var_dzint = this.params["surveillance"]["vertical"]["pres_large_intruder"]["var_dzint"]
else
var_zint = this.params["surveillance"]["vertical"]["pres_small_intruder"]["var_zint"]
var_dzint = this.params["surveillance"]["vertical"]["pres_small_intruder"]["var_dzint"]
end
end
gillham_alt::Bool = isa(trk, ADSBTrackFile) || (isa(trk, V2VTrackFile) && trk.mode_s_valid)
invalid_gillham_alt::Bool = gillham_alt && ((z_int < NARS_THRESHOLD_MIN) || (NARS_THRESHOLD_MAX < z_int))
if isnan(z_int) || invalid_gillham_alt
trk.mu_vert = fill(NaN,2)
trk.Sigma_vert = fill(NaN,2,2)
trk.alt_src_hae = is_alt_geo_hae
trk.updates_vert = 0
trk.valid_vert = false
else
trk.mu_vert = [z_int, 0]
trk.Sigma_vert = diagm(0 => [var_zint, var_dzint])
trk.alt_src_hae = is_alt_geo_hae
trk.updates_vert = 1
trk.display_arrow_current = DISPLAY_ARROW_LEVEL
trk.vert_arrow_history = Z[]
pushfirst!(trk.vert_arrow_history, DISPLAY_ARROW_LEVEL)
end
end
