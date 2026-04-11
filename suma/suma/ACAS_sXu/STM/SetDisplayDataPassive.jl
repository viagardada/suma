function SetDisplayDataPassive(this::STM, report::StmReport, intruder::TRMIntruderInput, mu_vert::Vector{R},mu_hor::Vector{R}, valid_vert::Bool, T::R, display_arrow_current::Z)
display::StmDisplayStruct = StmDisplayStruct()
display.toa = T
display.source = intruder.source
display.available_sources = SetAvailableSources(this, intruder.id)
SetInternalVertTrackAltType(this, intruder.id, display.internal_vert_track_altType)
display.id = intruder.id
display.id_directory = intruder.id_directory
SetExternalValidationFlags(this, intruder.id, display.external_validation)
display.r_ground_ft = hypot(mu_hor[1], mu_hor[3])
own_heading::R = HeadingAtToa(this, T)
if (this.own.heading_state == OWN_HEADING_NOMINAL)
display.bearing_rel_rad = WrapToPi(atan(mu_hor[1], mu_hor[3]) - own_heading)
display.bearing_valid = true
display.dx_rel_fps = mu_hor[2]
display.dy_rel_fps = mu_hor[4]
else
display.bearing_rel_rad = 0.0
display.bearing_valid = false
azimuth_rad = atan(mu_hor[1], mu_hor[3])
I_xydxdy::Vector{Z} = [1, 3, 2, 4]
(mu_xgrgr, _) = RotateHorizontalFrame(mu_hor[I_xydxdy], eye(4), azimuth_rad)
display.dx_rel_fps = 0.0
display.dy_rel_fps = mu_xgrgr[4]
end
if valid_vert && (report.trm_input.own.trm_altmode != TRM_ALTMODE_NONE)
display.z_rel_ft = mu_vert[1] - report.trm_input.own.belief_vert[1].z
display.dz_rel_fps = mu_vert[2] - report.trm_input.own.belief_vert[1].dz
display.alt_reporting = true
else
display.z_rel_ft = NaN
display.dz_rel_fps = NaN
display.alt_reporting = false
end
if valid_vert && (report.trm_input.own.trm_altmode != TRM_ALTMODE_NONE)
display.arrow = display_arrow_current
else
display.arrow = DISPLAY_ARROW_LEVEL
end
intruder.stm_display = display
push!(report.display, display)
end
