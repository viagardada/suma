mutable struct StmDisplayStruct
toa::R # Time of Applicability
source::UInt32 # What type of surveillance did this track come from
available_sources::UInt16 # Bit vector indicating available surveillance source tracks
id::UInt32 # Intruder ID inside the Target database
id_directory::IntruderIDDirectory
# All external IDs assigned to the intruder
external_validation::IntruderExternalValidation
# Are the ADS-B, V2V, and AGT, tracks externally validated
r_ground_ft::R # Tracked ground-range (feet)
bearing_rel_rad::R # Bearing relative to own airframe (radians)
bearing_valid::Bool # Indicates that a bearing is available for the intruder
dx_rel_fps::R # Relative horizontal velocity east/west (feet per sec)
dy_rel_fps::R # Relative horizontal velocity north/south (feet per sec)
z_rel_ft::R # Relative altitude (feet)
alt_reporting::Bool # Indicates that the intruder is altitude reporting
dz_rel_fps::R # Relative altitude rate (feet/sec)
arrow::Int32 # Display vertical rate arrow
internal_vert_track_altType::InternalVertTrackAltType
# What altitude type is the vertical tracker using: geo or baro
StmDisplayStruct( toa::R, source::UInt32, available_sources::UInt16, id::UInt32, id_directory::IntruderIDDirectory, external_validation::IntruderExternalValidation, r_ground_ft::R,bearing_rel_rad::R, bearing_valid::Bool, dx_rel_fps::R, dy_rel_fps::R, z_rel_ft::R, alt_reporting::Bool, dz_rel_fps::R, arrow::Int32, internal_vert_track_altType::InternalVertTrackAltType ) = 
new( toa, source, available_sources, id, id_directory, external_validation, r_ground_ft,bearing_rel_rad, bearing_valid, dx_rel_fps, dy_rel_fps, z_rel_ft, alt_reporting, dz_rel_fps, arrow, internal_vert_track_altType )
StmDisplayStruct() =
new(0.0, 0, 0, 0, IntruderIDDirectory(), IntruderExternalValidation(), 0.0, 0.0, false, 0.0, 0.0, 0.0, false, 0.0, 0, InternalVertTrackAltType() )
end
