mutable struct EnuPositionVelocity
pos_enu::Vector{R} # position, EastNorthUp, meters
vel_enu::Vector{R} # velocity, EastNorthUp, m/s
#
EnuPositionVelocity() = new( fill( 0.0, 3) , fill( 0.0, 3) )
EnuPositionVelocity(pos_enu::Vector{R}, vel_enu::Vector{R}) = new( pos_enu, vel_enu )
end
