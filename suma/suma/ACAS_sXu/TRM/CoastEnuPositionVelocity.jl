function CoastEnuPositionVelocity( position_velocity::EnuPositionVelocity, dt::R )
position_velocity.pos_enu = position_velocity.pos_enu + (dt * position_velocity.vel_enu)
end
