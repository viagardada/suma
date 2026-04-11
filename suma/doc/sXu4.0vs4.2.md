# ACAS sXu interface: 4.0 vs. 4.2

## Removed
* ReceiveStateVectorPositionReport
  * rebroadcast
* ReceiveStateVectorVelocityReport
  * rebroadcast
* ReceiveModeStatusReport
  * rebroadcast
* ReceiveStateVectorV2VReport
  * vpl_m
* ReceiveDiscretes
  * turn_rate_limit
  * vert_rate_limit
* StmDisplayStruct (StmReport.trm_input.intruder[].stm_display and StmReport.stm_display[])
  * validated_adsb
* TRMOwnInput (StmReport.trm_input.own)
  * h_opmode
  * turn_rate_limit
  * vert_rate_limit
  * h_lo_ft
  * h_hi_ft
* TRMIntruderInput (StmReport.trm_input.intruder[])
  * valid
* VTRMDisplayData (sXuTRMReport.display_vert)
  * opmode
* HTRMDisplayData (sXuTRMReport.display_horiz)
  * h_opmode
* TRMCoordinationInterrogationData
* sXuTRMBroadcastData (sXuTRMReport.broadcast_msg)
  * mid
  * ico
  * tti
  * tid
  * ico2
  * tti2
  * tid2
* TID
* TIDAddress

## Added
* ReceiveDiscretes
  * equipment
  * effective_turn_rate
  * effective_vert_rate
* ReceiveV2VOperationalStatusMessage
  * pilot_or_passengers
* StmDisplayStruct (StmReport.trm_input.intruder[].stm_display and StmReport.stm_display[])
  * external_validation
  * internal_vert_track_altType
* InternalVertTrackAltType (STMReport.trm_input.intruder[].stm_display.internal_vert_track_altType and STMReport.display[].internal_vert_track_altType)
* AgtAltType (STMReport.trm_input.intruder[].stm_display.internal_vert_track_altType.agt_tracks_use_hae[] and STMReport.display[].internal_vert_track_altType.agt_tracks_use_hae[])
* IntruderExternalValidation (STMReport.trm_input.intruder[].stm_display.external_validation and STMReport.display[].external_validation)
* AgtExternalValidation (STMReport.trm_input.intruder[].stm_display.external_validation.agt_tracks_validated[] and STMReport.display[].external_validation.agt_tracks_validated[])
* V2VOperationalStatusMessage (STMReport.own_v2v_osm)
  * pilot_or_passengers
* TRMOwnInput (STMReport.trm_input.own)
  * v2v_uid_valid
  * effective_turn_rate
  * effective_vert_rate
* TRMCoordinationData (sXuTRMReport.coordination[])
* TRMAlertingData (sXuTRMReport.alerting_data)
  * opmode
* sXuTRMBroadcastData (sXuTRMReport.broadcast_msg)
  * v2v_uid
  * v2v_uid_valid
  * tid_alt_rng_brg
  * tid_alt_rng_brg2

## Changed
* ReceiveOwnRelNonCoopTrack
  * trackId to ornct_id
* ReceiveTrueAirspeedObservation
  * airspeed_kts to hor_true_airspeed_kts
* IntruderIDEntry to IntruderIDEntry{T<:Union{UInt32,UInt128}}

## 4.0 CASCARA inputs
* ReceiveStateVectorPositionReportXuV4R2
* ReceiveStateVectorVelocityReport
* ReceiveStateVectorUatReportXuV4R2
* ReceiveModeStatusReportsXuV4R0
* ReceiveExternallyValidatedADSB
* ReceiveStateVectorV2VReportsXuV4R0
* ReceiveExternallyValidatedV2VsXuV4R0
* ReceiveOwnRelNonCoopTracksXuV4R0
* ReceiveAbsoluteGeodeticTracksXuV4R0
* ReceivePointObstacleReportsXuV4R0
* ReceiveDiscretessXuV4R0
* ReceivePresAltObservation
* ReceiveHeightAglObservation
* ReceiveTrueAirspeedObservation
* ReceiveHeadingObservationV15R2
* ReceiveWgs84ObservationsXuV4R0
* ReceiveV2VCoordinationsXuV4R0
* ReceiveV2VOperationalStatusMessage
* ReceiveADSBOperationalStatusMessage
* ReceiveDescentInhibitThresholds
* ReceiveTargetDesignationsXuV4R0

## 4.0 CASCARA outputs
* STMReportsXuV4R0
* sXuTRMReportsXuV4R0

## 4.2 CASCARA inputs
**changes**

* **ReceiveStateVectorPositionReportsXuV4R2**
* **ReceiveStateVectorVelocityReportsXuV4R2**
* ReceiveStateVectorUatReportXuV4R2
* **ReceiveModeStatusReportsXuV4R2**
* ReceiveExternallyValidatedADSB
* **ReceiveStateVectorV2VReportsXuV4R2**
* ReceiveExternallyValidatedV2VsXuV4R0
* **ReceiveOwnRelNonCoopTracksXuV4R2**
* ReceiveAbsoluteGeodeticTracksXuV4R0
* ReceivePointObstacleReportsXuV4R0
* **ReceiveDiscretessXuV4R2**
* ReceivePresAltObservation
* ReceiveHeightAglObservation
* **ReceiveTrueAirspeedObservationsXuV4R2**
* ReceiveHeadingObservationV15R2
* ReceiveWgs84ObservationsXuV4R0
* ReceiveV2VCoordinationsXuV4R0
* **ReceiveV2VOperationalStatusMessagesXuV4R2**
* ReceiveADSBOperationalStatusMessage
* ReceiveDescentInhibitThresholds
* ReceiveTargetDesignationsXuV4R0

## 4.2 CASCARA outputs
**changes**

* **STMReportsXuV4R2**
* **sXuTRMReportsXuV4R2**
