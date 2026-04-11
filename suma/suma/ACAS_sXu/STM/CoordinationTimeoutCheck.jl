function CoordinationTimeoutCheck(this::STM, tgt::Target, report_time::R)
timeout::Z = this.params["coordination"]["timeout"]
vert_intent::Vector{Z} = this.params["coordination"]["vert_intent"]
hor_intent::Vector{Z} = this.params["coordination"]["hor_intent"]
cancel_index_vert::Z = 0
cancel_index_hor::Z = 0
if (tgt.coord_data.toa_vert > 0) && ((report_time - tgt.coord_data.toa_vert) >= timeout)
if (tgt.coord_data.vrc > 0)
cancel_index_vert = vert_intent[tgt.coord_data.vrc]
end
tgt.coord_data.toa_vert = 0.0
tgt.coord_data.vrc = 0
DeleteIntent(this, cancel_index_vert, true)
end
if (tgt.coord_data.toa_hor > 0) && ((report_time - tgt.coord_data.toa_hor) >= timeout)
if (tgt.coord_data.hrc > 0)
cancel_index_hor = hor_intent[tgt.coord_data.hrc]
end
tgt.coord_data.toa_hor = 0.0
tgt.coord_data.hrc = 0
DeleteIntent(this, cancel_index_hor, false)
end
end
