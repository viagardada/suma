function SetCoordination(this::STM, intruder::TRMIntruderInput)
intruder.own_coordination_policy = OWN_COORDINATION_POLICY_NONE
intruder.equipage = EQUIPAGE_NONE
intruder.coordination_msg = COORDINATION_NONE
tgt = RetrieveWithID(this.target_db, intruder.id)
own_v2v_coordination_capable::Bool = ((this.own.discrete.equipment & EQUIPMENT_V2V_IN) != 0) && ((this.own.discrete.equipment & EQUIPMENT_V2V_OUT) != 0)
int_v2v_coordination_capable::Bool = ((tgt.v2v_osm.equipment & EQUIPMENT_V2V_IN) != 0) && ((tgt.v2v_osm.equipment & EQUIPMENT_V2V_OUT) != 0)
int_adsb_in_v2v_in_out_only::Bool = tgt.v2v_osm.equipment == (EQUIPMENT_ADSB_1090ES_IN + EQUIPMENT_ADSB_UAT_IN + EQUIPMENT_V2V_IN + EQUIPMENT_V2V_OUT)
if own_v2v_coordination_capable && int_v2v_coordination_capable && (tgt.v2v_osm.ca_status == CA_STATUS_RA)
intruder.vrc = tgt.coord_data.vrc
intruder.hrc = tgt.coord_data.hrc
if (tgt.v2v_osm.v2v_cccb.type_capability == CAS_V2V_SXU) || ((tgt.v2v_osm.v2v_cccb.type_capability== CAS_V2V_XR) && int_adsb_in_v2v_in_out_only)
if (this.own.v2v_osm.v2v_cccb.priority == tgt.v2v_osm.v2v_cccb.priority)
intruder.own_coordination_policy = OWN_COORDINATION_POLICY_PEER
intruder.equipage = EQUIPAGE_CASRA
intruder.coordination_msg = COORDINATION_V2V_OCM
elseif (this.own.v2v_osm.v2v_cccb.priority > tgt.v2v_osm.v2v_cccb.priority)
intruder.own_coordination_policy = OWN_COORDINATION_POLICY_SENIOR
intruder.equipage = EQUIPAGE_CASRESP
intruder.coordination_msg = COORDINATION_V2V_OCM
elseif (this.own.v2v_osm.v2v_cccb.priority < tgt.v2v_osm.v2v_cccb.priority)
intruder.own_coordination_policy = OWN_COORDINATION_POLICY_JUNIOR
intruder.equipage = EQUIPAGE_SXU_SENIOR
intruder.coordination_msg = COORDINATION_NONE
end
elseif (tgt.v2v_osm.v2v_cccb.type_capability == CAS_V2V_XR) && !int_adsb_in_v2v_in_out_only
intruder.own_coordination_policy = OWN_COORDINATION_POLICY_JUNIOR
intruder.equipage = EQUIPAGE_XR_V2V
intruder.coordination_msg = COORDINATION_NONE
end
elseif (tgt.v2v_osm.ca_status == CA_STATUS_RA_INHIBITED)
intruder.own_coordination_policy = OWN_COORDINATION_POLICY_NONE
intruder.equipage = EQUIPAGE_CASTA
intruder.coordination_msg = COORDINATION_NONE
else
if (tgt.adsb_osm.adsb_cccb.type_capability != CAS_ACTIVE_TCAS)
if own_v2v_coordination_capable && ((tgt.coord_data.vrc != 0) || (tgt.coord_data.hrc != 0))
intruder.vrc = tgt.coord_data.vrc
intruder.hrc = tgt.coord_data.hrc
intruder.own_coordination_policy = OWN_COORDINATION_POLICY_JUNIOR
intruder.equipage = EQUIPAGE_XR_V2V
intruder.coordination_msg = COORDINATION_NONE
else
intruder.own_coordination_policy = OWN_COORDINATION_POLICY_NONE
intruder.equipage = EQUIPAGE_LARGE_CAS
intruder.coordination_msg = COORDINATION_NONE
end
else
if (tgt.adsb_osm.ca_operational == 1)
intruder.own_coordination_policy = OWN_COORDINATION_POLICY_NONE
intruder.equipage = EQUIPAGE_TCAS
intruder.coordination_msg = COORDINATION_NONE
elseif (tgt.adsb_osm.ca_operational == 0)
intruder.own_coordination_policy = OWN_COORDINATION_POLICY_NONE
intruder.equipage = EQUIPAGE_NONE
intruder.coordination_msg = COORDINATION_NONE
end
end
end
end
