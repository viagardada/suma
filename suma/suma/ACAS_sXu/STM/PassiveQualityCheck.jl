function PassiveQualityCheck(this::STM, trk::Union{TrackFile, Nothing})
passive_quality_good::Bool = false
quality_state_valid::Bool = false
if TrackExists(trk)
if (typeof(trk) == ADSBTrackFile)
M::UInt32 = this.params["surveillance"]["report_generation"]["min_adsb_quality"]["M"]
N::UInt32 = this.params["surveillance"]["report_generation"]["min_adsb_quality"]["N"]
init_N::Z = this.params["surveillance"]["report_generation"]["min_adsb_quality"]["init_N"]
init_M::Z = this.params["surveillance"]["report_generation"]["min_adsb_quality"]["init_M"]
M_revalidate::Z = this.params["surveillance"]["report_generation"]["min_adsb_quality"]["M_revalidate"]
elseif (typeof(trk) == V2VTrackFile)
M = this.params["surveillance"]["report_generation"]["min_v2v_quality"]["M"]
N = this.params["surveillance"]["report_generation"]["min_v2v_quality"]["N"]
init_N = this.params["surveillance"]["report_generation"]["min_v2v_quality"]["init_N"]
init_M = this.params["surveillance"]["report_generation"]["min_v2v_quality"]["init_M"]
M_revalidate = this.params["surveillance"]["report_generation"]["min_v2v_quality"]["M_revalidate"]
end
vert_initialized::Bool = (trk.updates_vert > 1)
if (sum(trk.passive_qual_history) >= M)
passive_quality_good = true
elseif (init_N == length(trk.passive_qual_history)) && (init_M <= sum(trk.passive_qual_history)) &&vert_initialized
passive_quality_good = true
end
if (passive_quality_good) && (trk.init_velocity) && (QUAL_STATE_NOT_VALIDATED == trk.qual_state)
trk.qual_state = QUAL_STATE_VALID
elseif ((!passive_quality_good && (N == length(trk.passive_qual_history))) || !trk.init_velocity) &&(QUAL_STATE_VALID == trk.qual_state)
trk.qual_state = QUAL_STATE_INVALID
elseif (M_revalidate <= sum(trk.passive_qual_history)) && (trk.init_velocity)
trk.qual_state = QUAL_STATE_VALID
end
quality_state_valid = (QUAL_STATE_VALID == trk.qual_state)
end
return quality_state_valid::Bool
end
