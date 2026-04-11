function UpdateHorizontalVelocityMode(this::STM)
v_lo::R = this.params["surveillance"]["report_generation"]["hor_trm_velmode"]["v_lo"]
v_hi::R = this.params["surveillance"]["report_generation"]["hor_trm_velmode"]["v_hi"]
valid_WGS84 = (this.own.wgs84_state != OWN_WGS84_INVALID)
valid_airspeed = !isnan(this.own.airspeed)
valid_heading = (this.own.heading_state == OWN_HEADING_NOMINAL)
wind_relative_feasible = (valid_airspeed && valid_heading)
if valid_WGS84
v::R = GetGroundSpeed(this)
if this.own.discrete.prefer_wind_relative && wind_relative_feasible
this.own.trm_velmode = TRM_VELMODE_AIRSPEED_HEADING
elseif (v > v_hi) && !valid_heading
this.own.trm_velmode = TRM_VELMODE_GROUNDSPEED_TRACKANGLE
elseif (v < v_lo)
if valid_airspeed
this.own.trm_velmode = TRM_VELMODE_AIRSPEED_HEADING
else
this.own.trm_velmode = TRM_VELMODE_GROUNDSPEED_HEADING
end
elseif (this.own.trm_velmode == TRM_VELMODE_NONE) || ( (this.own.trm_velmode == TRM_VELMODE_AIRSPEED_HEADING) && !valid_airspeed )
v_avg = (v_lo + v_hi) / 2.0
if (v > v_avg)
this.own.trm_velmode = TRM_VELMODE_GROUNDSPEED_TRACKANGLE
else
if valid_airspeed
this.own.trm_velmode = TRM_VELMODE_AIRSPEED_HEADING
else
this.own.trm_velmode = TRM_VELMODE_GROUNDSPEED_HEADING
end
end
end
elseif wind_relative_feasible
this.own.trm_velmode = TRM_VELMODE_AIRSPEED_HEADING
else
this.own.trm_velmode = TRM_VELMODE_NONE
end
end
