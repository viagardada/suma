function OptimalQualityTrack(this::STM, tracks::Vector{TrackFile}, valid_vert::Bool, T::R)
w_hor = this.params["surveillance"]["report_generation"]["optimal_quality_track"]["w_hor"]
w_vert = this.params["surveillance"]["report_generation"]["optimal_quality_track"]["w_vert"]
w_hor_pos = this.params["surveillance"]["report_generation"]["optimal_quality_track"]["w_hor_pos"]
w_hor_vel = this.params["surveillance"]["report_generation"]["optimal_quality_track"]["w_hor_vel"]
w_vert_pos = this.params["surveillance"]["report_generation"]["optimal_quality_track"]["w_vert_pos"]
w_vert_vel = this.params["surveillance"]["report_generation"]["optimal_quality_track"]["w_vert_vel"]
I_hor_pos = [1,3]
I_hor_vel = [2,4]
I_vert_pos = [1]
I_vert_vel = [2]
opt_trk = nothing
trk_error = zeros(length(tracks))
for k in 1:length(tracks)
trk = tracks[k]
(_, Sigma_hor, _, Sigma_vert) = PredictPreTrackedTrack(this, trk, T)
hor_pos_error = norm(diag(Sigma_hor)[I_hor_pos]) * w_hor_pos
hor_vel_error = norm(diag(Sigma_hor)[I_hor_vel]) * w_hor_vel
hor_error = hor_pos_error + hor_vel_error
if valid_vert
vert_pos_error = norm(diag(Sigma_vert)[I_vert_pos]) * w_vert_pos
vert_vel_error = norm(diag(Sigma_vert)[I_vert_vel]) * w_vert_vel
vert_error = vert_pos_error + vert_vel_error
trk_error[k] = (w_hor * hor_error) + (w_vert * vert_error)
else
trk_error[k] = hor_error
end
end
if length(tracks)>0
sort_idx = sortperm(trk_error)
opt_trk = tracks[sort_idx[1]]
end
return (opt_trk::Union{AGTTrackFile, ORNCTTrackFile, Nothing})
end
