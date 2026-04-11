function CheckTrackStatus( track_status::UInt16 )
to_be_deleted::Bool = (track_status & AGT_STATUS_TO_BE_DELETED) > 0
is_coasted::Bool = (track_status & AGT_STATUS_MISSED_IN_LATEST_UPDATE) > 0
high_priority::Bool = (track_status & AGT_STATUS_HIGH_PRIORITY_TRACK) > 0
mode_s_valid::Bool = (track_status & AGT_STATUS_MODE_S_VALID) > 0
mode_s_non_icao::Bool = (track_status & AGT_STATUS_MODE_S_NON_ICAO) > 0
v2v_uid_valid::Bool = (track_status & AGT_STATUS_V2V_UID_VALID) > 0
return (to_be_deleted::Bool, is_coasted::Bool, high_priority::Bool, mode_s_valid::Bool, mode_s_non_icao::Bool, v2v_uid_valid::Bool)
end
