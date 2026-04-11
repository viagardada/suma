function SetDisplayDataORNCT(this::STM, report::StmReport, intruder::TRMIntruderInput, mu_vert::Vector{R},mu_cart::Vector{R}, mu_rng::Vector{R}, valid_vert::Bool, valid_rel_z::Bool, T::R, display_arrow_current::Z)
display::StmDisplayStruct = StmDisplayStruct()
display.toa = T
display.source = intruder.source
display.available_sources = SetAvailableSources(this, intruder.id)
SetInternalVertTrackAltType(this, intruder.id, display.internal_vert_track_altType)
display.id = intruder.id
display.id_directory = intruder.id_directory
SetExternalValidationFlags(this, intruder.id, display.external_validation)
display.r_ground_ft = mu_rng[1]
own_heading::R = HeadingAtToa(this, T)
if (this.own.heading_state == OWN_HEADING_NOMINAL)
display.bearing_rel_rad = WrapToPi(atan(mu_cart[1], mu_cart[3]) - own_heading)
display.bearing_valid = true
display.dx_rel_fps = mu_cart[2]
display.dy_rel_fps = mu_cart[4]
else
display.bearing_rel_rad = 0.0
display.bearing_valid = false
display.dx_rel_fps = 0.0
display.dy_rel_fps = mu_rng[2]
end
if valid_vert && (report.trm_input.own.trm_altmode != TRM_ALTMODE_NONE)
display.z_rel_ft = mu_vert[1] - report.trm_input.own.belief_vert[1].z
display.dz_rel_fps = mu_vert[2] - report.trm_input.own.belief_vert[1].dz
display.alt_reporting = true
display.arrow = display_arrow_current
elseif valid_rel_z
display.z_rel_ft = mu_vert[1]
display.dz_rel_fps = mu_vert[2]
display.alt_reporting = false
display.arrow = DISPLAY_ARROW_LEVEL
else
display.z_rel_ft = NaN
display.dz_rel_fps = NaN
display.alt_reporting = false
display.arrow = DISPLAY_ARROW_LEVEL
end
intruder.stm_display = display
push!(report.display, display)
end
