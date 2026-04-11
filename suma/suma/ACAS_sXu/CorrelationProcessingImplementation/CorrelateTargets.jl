function CorrelateTargets(this::STM, T::R)
range_gate::R = this.params["surveillance"]["correlation"]["range_gate"]
lead_track_list::Vector{TrackMap} = GenerateLeadTrackList(this)
lead_track_list = SortByRange(lead_track_list)
pending_deletion::Vector{Bool} = fill(false, length(lead_track_list))
lowIndexB::Z = 1
for indexA in 1:length(lead_track_list)
if (!pending_deletion[indexA])
trackA = lead_track_list[indexA].track
for indexB in lowIndexB:length(lead_track_list)
if (!pending_deletion[indexB]) && (indexA != indexB)
trackB = lead_track_list[indexB].track
(targetA_id, targetB_id) = (lead_track_list[indexA].db_id, lead_track_list[indexB].db_id)
if (trackA.trk_summary.mu_range[1] - trackB.trk_summary.mu_range[1] > range_gate)
lowIndexB = indexB
continue
elseif (trackB.trk_summary.mu_range[1] - trackA.trk_summary.mu_range[1] <= range_gate)
(pending_deletion[indexA], pending_deletion[indexB]) = CorrelateIndividualTracks(this, trackA, targetA_id, trackB, targetB_id, T)
if (pending_deletion[indexA])
break
end
end
end
end
end
end
end
