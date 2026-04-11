function VerticalRateArrowUpdate(this::STM, trk::TrackFile, is_relative_alt::Bool)
level_arrow_threshold::R = this.params["display"]["level_arrow_threshold"]
M::Z = this.params["display"]["arrow_M"]
N::Z = this.params["display"]["arrow_N"]
if (length(trk.vert_arrow_history) >= N)
pop!(trk.vert_arrow_history)
end
mu_dz::R = trk.mu_vert[2]
if is_relative_alt
own_valid_alt_pres::Bool = !isnan(this.own.toa_vert)
own_valid_alt_hae::Bool = !isnan(this.own.wgs84_toa_vert)
if own_valid_alt_pres
mu_dz = mu_dz + this.own.mu_vert[2]
elseif own_valid_alt_hae
mu_dz = mu_dz + this.own.wgs84_mu_vert[2]
end
end
if (mu_dz > level_arrow_threshold)
pushfirst!(trk.vert_arrow_history, DISPLAY_ARROW_CLIMB)
elseif (mu_dz < -level_arrow_threshold)
pushfirst!(trk.vert_arrow_history, DISPLAY_ARROW_DESCEND)
else
pushfirst!(trk.vert_arrow_history, DISPLAY_ARROW_LEVEL)
end
numClimb::Z = 0
numDes::Z = 0
numLevel::Z = 0
for i in 1:length(trk.vert_arrow_history)
if (trk.vert_arrow_history[i] == DISPLAY_ARROW_CLIMB)
numClimb += 1
elseif (trk.vert_arrow_history[i] == DISPLAY_ARROW_DESCEND)
numDes += 1
else
numLevel += 1
end
end
if (numClimb >= M)
trk.display_arrow_current = DISPLAY_ARROW_CLIMB
elseif (numDes >= M)
trk.display_arrow_current = DISPLAY_ARROW_DESCEND
elseif (numLevel >= M)
trk.display_arrow_current = DISPLAY_ARROW_LEVEL
end
end
