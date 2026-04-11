function TurnEnuPositionVelocity( position_velocity::EnuPositionVelocity, rate::R, dt::R )
normal_to_earth_surface::Vector{R} = [0.0, 0.0, 1.0]
current_velocity::Vector{R} = position_velocity.vel_enu
acceleration_direction::Vector{R} = UnitVectorNormalize( cross( current_velocity, normal_to_earth_surface ) )
acceleration::Vector{R} = rate * norm( current_velocity ) * acceleration_direction
position_velocity.vel_enu = norm( current_velocity ) * UnitVectorNormalize(current_velocity + (dt * acceleration))
position_velocity.pos_enu = position_velocity.pos_enu + (dt * current_velocity) + (dt * dt * 0.5 * acceleration)
end
