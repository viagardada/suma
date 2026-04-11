mutable struct Target
# Deviation potential: Refer to ACAS sXu MOPS Vol. II Appendix L
adsb_track::Union{ADSBTrackFile, Nothing}
v2v_track::Union{V2VTrackFile, Nothing}
agt_tracks::Vector{AGTTrackFile}
ornct_track::Union{ORNCTTrackFile, Nothing}
point_obstacle_track::Union{PointObstacleTrackFile, Nothing}
coord_data::ReceivedCoordinationData
bad_v2vcoordination_vert::Bool
bad_v2vcoordination_horz::Bool
designation_state::DesignationState
init_time::R # seconds
priority_codes::PriorityCodes
adsb_osm::ADSBOperationalStatusMessage
v2v_osm::V2VOperationalStatusMessage
optimal_trk_history::Vector{String}
previously_selected_trk_uid::Union{String, Nothing}
previously_selected_trk_validated::Bool
previously_selected_trk_alt_reporting::Bool
Target() = new(
nothing, nothing,
AGTTrackFile[], nothing,
nothing, ReceivedCoordinationData(),
false, false,
DesignationState(), -1.0,
PriorityCodes(), ADSBOperationalStatusMessage(),
V2VOperationalStatusMessage(), String[],
nothing,
false, false
)
end
