# ACAS sXu interface: 3.1 vs. 4.0

## Removed
* ReceiveDiscretes
  * surv_only_disp_on
  * perform_poa_and_gpoa
* ReceiveAbsoluteGeodeticTrack
  * address
  * non_icao
  * external_id
  * non_coop
  * is_passive
* ReceiveStateVectorV2VReport
  * gva
  * remote_id
* ReceivePointObstacleReport
  * alt_agl_ft
* ReceiveV2VCapabilityReport
* TRMIntruderInput (StmReport.trm_input.intruder[])
  * address, is_icao (new id_directory used)
  * active_cas_version
  * ext_id
  * cccb (new adsb_cccb and v2v_cccb used)
* StmDisplayStruct (StmReport.trm_input.intruder[].stm_display and StmReport.stm_display[])
  * id, mode_s, is_icao, ext_id (new id_directory used)
* StmReport
  * capability (new own_v2v_osm used)
* VTRMDisplayData (sXuTRMReport.display_vert)
  * turn_off_aurals
* TRMIntruderDisplayData (sXuTRMReport.display_vert.intruder[])
  * mode_s, is_icao (new id_directory used)
* TRMIntruderDisplayData (sXuTRMReport.display_horiz.intruder[])
  * address, is_icao (new id_directory used)
* TRMCoordinationInterrogationData (sXuTRMReport.coordination[])
  * taa (new icao24, anon24, v2v_uid used)
* TRMIntruderDesignationData (sXuTRMReport.designation.intruder[])
  * address, is_icao (new id_directory used)

## Added
* ReceiveDiscretes
  * requested_opmode
  * perform_poa
  * disable_gpoa
* ReceiveModeStatusReport
  * gva
* ReceiveWgs84Observation
  * vfom_m
* ReceiveOwnRelNonCoopTrack
  * classification
* ReceiveAbsoluteGeodeticTrack
  * agt_id
  * mode_s
  * v2v_uid
  * classification
* ReceiveStateVectorV2VReport
  * nic
  * vfom_m
  * vpl_m
  * sil
  * sda
  * v2v_uid
  * mode_s
  * mode_s_non_icao
  * mode_s_valid
  * q_int
* ReceiveADSBOperationalStatusMessage
* ReceiveV2VOperationalStatusMessage
* ReceiveDescentInhibitThresholds
* ReceiveTargetDesignation
* TRMOwnInput (StmReport.trm_input.own)
  * agt_ids
  * h_lo_ft
  * h_hi_ft
* TRMIntruderInput (StmReport.trm_input.intruder[])
  * id_directory (replacement for address, is_icao)
  * own_coordination_policy
  * adsb_cccb, v2v_cccb (replacement for cccb)
* StmDisplayStruct (StmReport.trm_input.intruder[].stm_display and StmReport.stm_display[])
  * id_directory (replacement for id, mode_s, is_icao, ext_id)
* StmReport
  * own_v2v_osm (replacement for capability)
* sXuTRMReport
  * broadcast_msg
* VTRMDisplayData (sXuTRMReport.display_vert)
  * dz_min
  * dz_max
  * ddz_min
  * strength
  * down
  * opmode
  * trm_altmode
* TRMIntruderDisplayData (sXuTRMReport.display_vert.intruder[])
  * id_directory (replacement for mode_s, is_icao)
  * classification
  * source
* HTRMDisplayData (sXuTRMReport.display_horiz)
  * h_opmode
  * trm_velmode
  * horizontal_desensitivity_mode
* HTRMIntruderDisplayData (sXuTRMReport.display_horiz.intruder[])
  * id_directory (replacement for mode_s, is_icao)
  * classification
  * source
* TRMCoordinationInterrogationData (sXuTRMReport.coordination[])
  * icao24, anon24, v2v_uid (replacement for taa)
* TRMIntruderDesignationData (sXuTRMReport.designation.intruder[])
  * id_directory (replacement for address, is_icao)

## Changed
* ReceiveDiscretes
  * remote_id to v2v_uid
* ReceiveV2VCoordination
  * remote_id to v2v_uid
* ReceiveAbsoluteGeodeticTrack
  * track_status from uint8 to uint16
* ReceivePointObstacleReport
  * external_id to po_id
* TRMOwnInput (StmReport.trm_input.own)
  * remote_id to v2v_uid
* VTRMDisplayData (sXuTRMReport.display_vert)
  * ground (Bool) to ground_alert (UInt8)
* ReceiveExternallyValidatedV2V
  * remote_id to v2v_uid

## 3.1 CASCARA inputs
* ReceiveDiscretessXuV3R0
* ReceiveWgs84ObservationsXuV3R0
* ReceivePresAltObservation
* ReceiveHeadingObservationV15R2
* ReceiveStateVectorPositionReportXuV4R2
* ReceiveStateVectorVelocityReport
* ReceiveModeStatusReportXuV5R2
* ReceiveV2VCoordination
* ReceiveV2VCapabilityReport
* ReceiveStateVectorUatReportXuV4R2
* ReceiveOwnRelNonCoopTrack
* ReceiveTrueAirspeedObservation
* ReceiveAbsoluteGeodeticTrack
* ReceiveStateVectorV2VReport
* ReceivePointObstacleReportsXuV3R0
* ReceiveHeightAglObservation
* ReceiveExternallyValidatedADSB
* ReceiveExternallyValidatedV2V

## 3.1 CASCARA outputs
* STMReportsXuV3R0
* sXuTRMReportsXuV3R0

## 4.0 CASCARA inputs
**changes**

* ReceiveStateVectorPositionReportXuV4R2
* ReceiveStateVectorVelocityReport
* ReceiveStateVectorUatReportXuV4R2
* **ReceiveModeStatusReportsXuV4R0**
* ReceiveExternallyValidatedADSB
* **ReceiveStateVectorV2VReportsXuV4R0**
* **ReceiveExternallyValidatedV2VsXuV4R0**
* **ReceiveOwnRelNonCoopTracksXuV4R0**
* **ReceiveAbsoluteGeodeticTracksXuV4R0**
* **ReceivePointObstacleReportsXuV4R0**
* **ReceiveDiscretessXuV4R0**
* ReceivePresAltObservation
* ReceiveHeightAglObservation
* ReceiveTrueAirspeedObservation
* ReceiveHeadingObservationV15R2
* **ReceiveWgs84ObservationsXuV4R0**
* **ReceiveV2VCoordinationsXuV4R0**
* **ReceiveV2VOperationalStatusMessage (added)**
* **ReceiveADSBOperationalStatusMessage (added)**
* **ReceiveDescentInhibitThresholds (added)**
* **ReceiveTargetDesignationsXuV4R0 (added)**

## 4.0 CASCARA outputs
**changes**

* **STMReportsXuV4R0**
* **sXuTRMReportsXuV4R0**
