function IsVerticallyConverging(this::TRM, mode_int::Z, z_own_ave::R, dz_own_ave::R, z_int_ave::R, dz_int_ave::R )
R_converge_thres_vert::R =
this.params["modes"][mode_int]["state_estimation"]["tau"]["R_converge_thres_vert"]
is_vertically_converging::Bool = false
if (R_converge_thres_vert < abs( dz_own_ave - dz_int_ave )) &&
(0.0 < ((z_int_ave - z_own_ave) / (dz_own_ave - dz_int_ave)))
is_vertically_converging = true
end
return is_vertically_converging::Bool
end
