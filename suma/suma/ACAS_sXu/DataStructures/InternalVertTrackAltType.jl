mutable struct InternalVertTrackAltType
adsb_track_uses_hae::Bool
v2v_track_uses_hae::Bool
agt_tracks_use_hae::Vector{AgtAltType}
InternalVertTrackAltType() = new(false, false, AgtAltType[])
end
