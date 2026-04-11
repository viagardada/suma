function UpdateIntruderHRC(this::STM, intruders::Vector{TRMIntruderInput})
for id in keys(this.target_db)
for intruder::TRMIntruderInput in intruders
if ( intruder.id == id )
if (intruder.equipage == EQUIPAGE_LARGE_CAS) && ((this.target_db[id].coord_data.vrc != 0) || (this.target_db[id].coord_data.hrc != 0))
intruder.equipage = EQUIPAGE_XR_V2V
intruder.own_coordination_policy = OWN_COORDINATION_POLICY_JUNIOR
end
if (intruder.equipage != EQUIPAGE_NONE) && (intruder.equipage != EQUIPAGE_TCAS) && (intruder.equipage != EQUIPAGE_LARGE_CAS) && (intruder.equipage != EQUIPAGE_CASTA)
intruder.hrc = this.target_db[id].coord_data.hrc
end
end
end
end
received_hrcs::Vector{Bool} = copy( this.own.received_hrcs )
return received_hrcs::Vector{Bool}
end
