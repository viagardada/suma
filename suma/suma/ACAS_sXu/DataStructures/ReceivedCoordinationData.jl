mutable struct ReceivedCoordinationData
vrc::UInt32 # Vertical RA complement
hrc::UInt32 # Horizontal RA complement
toa_vert::R # Time of Applicability for vertical (seconds)
toa_hor::R # Time of Applicability for horizontal (seconds)
ReceivedCoordinationData() = new( 0, 0, 0.0, 0.0 )
end
