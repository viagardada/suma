function DetermineORNCTDeletion(this::STM, targetId::UInt32, valid_hor::Bool, track_negation::Bool)
close_rng_ft::R = this.params["surveillance"]["ornct"]["close_rng_ft"]
min_established_track_updates::Z = this.params["surveillance"]["ornct"]["min_established_track_updates"]
if (targetId != NO_TARGET_FOUND)
tgt::Target = this.target_db[targetId]
is_established_trk::Bool = tgt.ornct_track.update_count >= min_established_track_updates
FOV_spatially_eligible::Bool = (tgt.ornct_track.high_priority) || (tgt.ornct_track.mu_rng[1] <close_rng_ft)
FOV_threat::Bool = tgt.priority_codes.had_code
if valid_hor && is_established_trk && FOV_spatially_eligible && FOV_threat && !track_negation
tgt.ornct_track.is_FOV_coast = true
else
tgt.ornct_track = nothing
if (TargetIsEmpty(tgt))
delete!(this.target_db, targetId)
end
end
end
end
