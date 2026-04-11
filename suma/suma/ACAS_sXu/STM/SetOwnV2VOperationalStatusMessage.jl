function SetOwnV2VOperationalStatusMessage(this::STM)
if (this.own.opmode == OPMODE_RA)
this.own.v2v_osm.ca_status = CA_STATUS_RA
elseif (this.own.opmode == OPMODE_SURV_ONLY)
this.own.v2v_osm.ca_status = CA_STATUS_RA_INHIBITED
elseif (this.own.opmode == OPMODE_STANDBY)
this.own.v2v_osm.ca_status = CA_STATUS_NONE
end
this.own.v2v_osm.v2v_cccb.sense = CAS_SENSE_BLENDED
this.own.v2v_osm.v2v_cccb.type_capability = CAS_V2V_SXU
this.own.v2v_osm.v2v_cccb.priority = SXU_V2V_CCCB_PRIORITY_MIDDLE
this.own.v2v_osm.equipment = this.own.discrete.equipment
this.own.v2v_osm.pilot_or_passengers = V2V_OSM_NONE_ONBOARD
return
end
