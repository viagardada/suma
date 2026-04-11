mutable struct TRMIntruderDisplayData
id::UInt32 # Unique identifier
id_directory::IntruderIDDirectory # All external IDs assigned to the intruder
tds::R # Track display score; used for display prioritization
code::UInt8 # Track display advisory code, corresponds to SXUCODE_ inside VTRM,
# SXUCODE_ after VerticalDAAUpdate
classification::UInt8 # Intruder classification (See CLASSIFICATION_ constants)
source::Z # Surveillance source (See SOURCE_ constants)
#
TRMIntruderDisplayData() =
new( 0, IntruderIDDirectory(), 0.0, SXUCODE_CLEAR, CLASSIFICATION_NONE, SOURCE_MODES )
TRMIntruderDisplayData( id::UInt32, id_directory::IntruderIDDirectory, tds::R, code::UInt8,
classification::UInt8, source::Z ) =
new( id, id_directory, tds, code, classification, source )
end
