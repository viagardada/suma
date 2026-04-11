function PolarAlignmentHorizontalRotation(lla_0::Vector{R}, ecef_0::Vector{R}, lla_1::Vector{R}, ecef_1::Vector{R})
delta_ecef = ecef_1 - ecef_0
delta_enu_0 = RotateECEFToENU(delta_ecef, lla_0)
delta_enu_1 = RotateECEFToENU(delta_ecef, lla_1)
track_angle_0 = atan(delta_enu_0[1], delta_enu_0[2])
track_angle_1 = atan(delta_enu_1[1], delta_enu_1[2])
rotation_angle = WrapToPi(track_angle_1 - track_angle_0)
s_rotation_angle = sin(rotation_angle)
c_rotation_angle = cos(rotation_angle)
R_0_to_1::Matrix{R} = [c_rotation_angle -s_rotation_angle;
s_rotation_angle c_rotation_angle]
return R_0_to_1::Matrix{R}
end
