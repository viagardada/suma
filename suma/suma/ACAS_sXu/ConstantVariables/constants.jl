# Protection Mode Options for TRM Look-Up Tables
global const PROTECTION_MODE_Xo_CSPO3k = UInt8( 2 )
global const PROTECTION_MODE_sXu = UInt8( 4 )
# Equipage Codes
global const EQUIPAGE_CASTA = Int( 2 )
global const EQUIPAGE_CASRA = Int( 3 )
global const EQUIPAGE_CASRESP = Int( 4 )
global const EQUIPAGE_DAARESP = Int( 5 )
global const EQUIPAGE_NONE = Int( 6 )
global const EQUIPAGE_TCAS = Int( 7 )
global const EQUIPAGE_LARGE_CAS = Int( 8 )
global const EQUIPAGE_SXU_SENIOR = Int( 9 )
global const EQUIPAGE_XR_V2V = Int( 10 )
# Aircraft Equipment Specification (bit vector)
global const EQUIPMENT_NONE = UInt8( 0x00 )
global const EQUIPMENT_V2V_IN = UInt8( 0x01 )
global const EQUIPMENT_V2V_OUT = UInt8( 0x02 )
global const EQUIPMENT_ADSB_UAT_IN = UInt8( 0x04 )
global const EQUIPMENT_ADSB_1090ES_IN = UInt8( 0x08 )
global const EQUIPMENT_ADSB_UAT_OUT = UInt8( 0x10 )
global const EQUIPMENT_ADSB_1090ES_OUT = UInt8( 0x20 )
global const EQUIPMENT_TRANSPONDER = UInt8( 0x40 )
global const EQUIPMENT_1030_TRANSMIT = UInt8( 0x80 )
# Intruder Classification Types
global const CLASSIFICATION_NONE = UInt8( 0 )
global const CLASSIFICATION_MANNED = UInt8( 1 )
global const CLASSIFICATION_UNMANNED = UInt8( 2 )
global const CLASSIFICATION_SMALL_UNMANNED = UInt8( 3 )
global const CLASSIFICATION_POINT_OBSTACLE = UInt8( 100 )
global const CLASSIFICATION_GROUND = UInt8( 101 )
# Coordination Message Types
global const COORDINATION_NONE = UInt32( 0 )
global const COORDINATION_V2V_OCM = UInt32( 3 )
# Ownship Coordination Policy
global const OWN_COORDINATION_POLICY_NONE = UInt8( 0 )
global const OWN_COORDINATION_POLICY_JUNIOR = UInt8( 1 )
global const OWN_COORDINATION_POLICY_SENIOR = UInt8( 2 )
global const OWN_COORDINATION_POLICY_PEER = UInt8( 3 )
# Surveillance Sources
global const SOURCE_MODES = Int( 0 )
global const SOURCE_MODEC = Int( 1 )
global const SOURCE_1090ES_ADSB = Int( 2 )
global const SOURCE_ORNCT = Int( 3 )
global const SOURCE_978_UAT = Int( 5 )
global const SOURCE_AGT = Int( 7 )
global const SOURCE_V2V = Int( 8 )
global const SOURCE_POINT_OBSTACLE = Int( 9 )
# Avalilable Surveillance Sources on Intruder (bit vector)
global const AVAILABLE_SURVEILLANCE_NONE = UInt16( 0x0000 )
global const AVAILABLE_SURVEILLANCE_1090ES_ADSB = UInt16( 0x0004 )
global const AVAILABLE_SURVEILLANCE_ORNCT = UInt16( 0x0008 )
global const AVAILABLE_SURVEILLANCE_978_UAT = UInt16( 0x0020 )
global const AVAILABLE_SURVEILLANCE_AGT = UInt16( 0x0080 )
global const AVAILABLE_SURVEILLANCE_V2V = UInt16( 0x0100 )
global const AVAILABLE_SURVEILLANCE_POINT_OBSTACLE = UInt16( 0x0200 )
# RA Message Format (RMF) settings
global const RMF_ACAS_sXu = UInt8( 4 )
# Low-level Descend Inhibits
# Deviation potential: Refer to ACAS sXu MOPS Vol. II Appendix L
global const LDI_NONE = UInt8( 0 )
global const LDI_INCREASE_DESCEND = UInt8( 1 )
global const LDI_DESCENDS = UInt8( 2 )
global const LDI_ALL = UInt8( 3 )
# TIDA constants
global const TIDA_MIN_ALTITUDE = -1000.0
global const TIDA_OFFSET = -1000.0
global const TIDA_MAX_CODE = UInt32( 2047 )
# TIDB constants
global const TIDB_MAX_CODE = UInt32( 60 )
# TIDR constants
global const TIDR_MAX_CODE = UInt32( 127 )
# ADS-B Quality State
global const QUAL_STATE_NOT_VALIDATED = Int( 0 )
global const QUAL_STATE_VALID = Int( 1 )
global const QUAL_STATE_INVALID = Int( 2 )
# sXu Advisory Codes - used for horizontal and vertical display outputs
global const SXUCODE_CLEAR = UInt8( 0 )
global const SXUCODE_RA = UInt8( 4 )
# COC action
global const COC = Int( 1 )
# Display combined control values
global const CC_H_NO_ADVISORY = UInt8( 0 )
global const CC_H_COC = UInt8( 1 )
global const CC_H_TURN_RIGHT = UInt8( 2 )
global const CC_H_TURN_LEFT = UInt8( 3 )
global const CC_H_STRAIGHT = UInt8( 4 )
global const CC_V_NO_ADVISORY = UInt8( 0 )
global const CC_V_COC = UInt8( 1 )
global const CC_V_CORRECTIVE_UP = UInt8( 4 )
global const CC_V_CORRECTIVE_DOWN = UInt8( 5 )
global const CC_V_PREVENTIVE = UInt8( 6 )
global const AHRA_NO_TURN = UInt8(0)
global const AHRA_RIGHT_TURN = UInt8(1)
global const AHRA_LEFT_TURN = UInt8(2)
global const AHRA_STRAIGHT = UInt8(3)
global const AVRA_STRENGTH_NO_ADVISORY = UInt8(0)
# AHRA Track Angle Indicators
global const AHRA_TRACK_ANGLE_NAN = Int( 63 )
global const AHRA_TRACK_ANGLE_BIN = Int( 10 )
# ENU indices
global const ENU_EAST_IDX = Int( 1 )
global const ENU_NORTH_IDX = Int( 2 )
global const ENU_UP_IDX = Int( 3 )
# Vertical Policy Scaling Indices
global const SCALING_VTRM_POLICY_FT = Int( 1 )
global const SCALING_VTRM_ENTRY_FT = Int( 2 )
global const SCALING_VTRM_ENTRY_FPS = Int( 3 )
# Vertical Policy Scaling Options
global const VERTICAL_SCALING_OPTION_DEFAULT = Int( 1 )
# Vertical Table Swap Indices
global const TABLE_SWAP_DEFAULT_INDEX = 1
global const TABLE_SWAP_INCREASE_DESCEND_INDEX = 9
global const TABLE_SWAP_NO_STRENGTHEN_MTLO_INDEX = 9
global const TABLE_SWAP_INCREASE_CLIMB_INDEX = 10
global const TABLE_SWAP_MTLO_ACTION_INDEX = 11
# Horizontal Policy State Indices
global const POLICY_VERTICAL_TAU = Int( 1 )
global const POLICY_RANGE = Int( 2 )
global const POLICY_THETA = Int( 3 )
global const POLICY_PSI = Int( 4 )
global const POLICY_OWN_SPEED = Int( 5 )
global const POLICY_INTR_SPEED = Int( 6 )
global const POLICY_LAST = Int( 6 )
# Horizontal Policy Scaling Indices
global const SCALING_HTRM_POLICY_RANGE = Int( 1 )
global const SCALING_HTRM_POLICY_TARGET_SEPARATION = Int( 2 )
global const SCALING_HTRM_POLICY_SPEED = Int( 3 )
global const SCALING_HTRM_POLICY_VERTICAL_TAU = Int( 4 )
# Horizontal Policy Scaling Options
global const HORIZONTAL_SCALING_OPTION_DEFAULT = Int( 1 )
# Horizontal RA Altitude Cutoff Options
# Horizontal Coordination
global const HCOORD_SENSE_NONE = Int( 0 )
global const HCOORD_SENSE_SAME = Int( 1 )
global const HCOORD_SENSE_DIFFERENT = Int( 2 )
# Force_alarm Settings for Display Logic
global const FORCE_ALARM_NONE = Int( 0 )
global const FORCE_ALARM_ON = Int( 1 )
global const FORCE_ALARM_OFF = Int( 2 )
# Target Designations for Intruders
# Deviation potential: Refer to ACAS sXu MOPS Vol. I section 1
global const DESIGNATION_NONE = UInt8( 0 )
global const DESIGNATION_DESIGNATED_NO_ALERTS = UInt8( 4 )
global const DESIGNATION_Xo_CSPO3k = UInt8( 5 )
global const DESIGNATION_UNDESIGNATE_NO_ALERTS = UInt8( 7 )
global const DESIGNATION_UNDESIGNATE_PROTECTION_MODE = UInt8( 8 )
# RA Processing of Intruders
global const RA_PROCESSING_NONE = UInt8( 0 )
global const RA_PROCESSING_DROPPED_TRACK = UInt8( 1 )
global const RA_PROCESSING_GLOBAL_RA = UInt8( 2 )
global const RA_PROCESSING_GLOBAL_SURV_ONLY = UInt8( 4 )
global const RA_PROCESSING_DEGRADED_SURVEILLANCE = UInt8( 6 )
# Target Designations for Indices
# Deviation potential: Refer to ACAS sXu MOPS Vol. I section 1
global const Xo_IDX_DNA = UInt8( 1 )
global const Xo_IDX_CSPO3k = UInt8( 2 )
# Target Designations for Status
# Deviation potential: Refer to ACAS sXu MOPS Vol. I section 1
global const Xo_STATUS_NONE = UInt8( 0x00 )
global const Xo_STATUS_DELAYED_ACTIVE_RA = UInt8( 0x11 )
global const Xo_STATUS_SUSPENDED_MULTITHREAT = UInt8( 0x21 )
global const Xo_STATUS_SUSPENDED_INVALID = UInt8( 0x22 )
global const Xo_STATUS_SUSPENDED_DROPPED = UInt8( 0x23 )
global const Xo_STATUS_SUSPENDED_TIMER = UInt8( 0x24 )
global const Xo_STATUS_UNDESIGNATED_UNAVAILABLE = UInt8( 0x31 )
global const Xo_STATUS_UNDESIGNATED_GEOMETRIC = UInt8( 0x32 )
global const Xo_STATUS_UNDESIGNATED_DROPPED = UInt8( 0x33 )
global const Xo_STATUS_UNDESIGNATED_TIMEOUT = UInt8( 0x34 )
global const Xo_STATUS_UNDESIGNATED_NO_BEARING = UInt8( 0x35 )
# Target Designation Xo mode Availability for any intruders
# Deviation potential: Refer to ACAS sXu MOPS Vol. II Appendix L
# Constant values not used in sXu; inherited from Xa/Xo, included for reference
global const Xo_AVAILABILITY_NOT_CONFIGURED = UInt8( 0 )
global const Xo_AVAILABILITY_UNAVAILABLE_TO_RUN = UInt8( 1 )
global const Xo_AVAILABILITY_AVAILABLE_TO_RUN = UInt8( 2 )
global const Xo_AVAILABILITY_ON = UInt8( 3 )
# Degraded Surveillance Types Intruder (bit vector)
global const DEGRADED_SURVEILLANCE_NONE = UInt16( 0x0000 )
global const DEGRADED_SURVEILLANCE_NAR = UInt16( 0x0001 )
global const DEGRADED_SURVEILLANCE_PASSIVE_NOT_VALIDATED = UInt16( 0x0002 )
global const DEGRADED_SURVEILLANCE_NO_BEARING = UInt16( 0x0004 )
global const DEGRADED_SURVEILLANCE_VERT_COAST = UInt16( 0x0010 )
global const DEGRADED_SURVEILLANCE_HORIZ_COAST = UInt16( 0x0020 )
global const DEGRADED_SURVEILLANCE_ORNCT_COAST = UInt16( 0x0040 )
global const DEGRADED_SURVEILLANCE_ORNCT_FOV_COAST = UInt16( 0x0200 )
global const DEGRADED_SURVEILLANCE_AGT_COAST = UInt16( 0x0800 )
global const DEGRADED_SURVEILLANCE_AGT_FOV_COAST = UInt16( 0x1000 )
global const DEGRADED_SURVEILLANCE_INVALID_V2VCOORDINATION_VERT = UInt16( 0x2000 )
global const DEGRADED_SURVEILLANCE_INVALID_V2VCOORDINATION_HORZ = UInt16( 0x4000 )
global const DEGRADED_SURVEILLANCE_ALL = UInt16( 0xffff )
# Degraded Surveillance Types Ownship (bit vector)
global const DEGRADED_OWN_NONE = UInt16( 0x0000 )
global const DEGRADED_OWN_ALTPRES_COAST = UInt16( 0x0001 )
global const DEGRADED_OWN_WGS84_COAST = UInt16( 0x0002 )
global const DEGRADED_OWN_HDG_COAST = UInt16( 0x0004 )
global const DEGRADED_OWN_HDG_INVALID = UInt16( 0x0008 )
global const DEGRADED_OWN_WGS84_INVALID = UInt16( 0x0010 )
global const DEGRADED_OWN_ALTPRES_INVALID = UInt16( 0x0020 )
global const DEGRADED_OWN_ALTHAE_COAST = UInt16( 0x0040 )
global const DEGRADED_OWN_ALTHAE_INVALID = UInt16( 0x0080 )
# Ownship Heading States
global const OWN_HEADING_INVALID = 0
global const OWN_HEADING_DEGRADED = 1
global const OWN_HEADING_NOMINAL = 2
# Ownship Wgs84 States
global const OWN_WGS84_INVALID = 0
global const OWN_WGS84_VALID = 1
# CAS Operational Mode Settings
global const OPMODE_STANDBY = UInt8( 1 )
global const OPMODE_SURV_ONLY = UInt8( 2 )
global const OPMODE_RA = UInt8( 3 )
# CAS Operational Status Settings
global const CA_STATUS_NONE = UInt8( 0 )
global const CA_STATUS_RA_INHIBITED = UInt8( 1 )
global const CA_STATUS_RA = UInt8( 2 )
# Horizontal Velocity Operational Mode Settings
global const TRM_VELMODE_NONE = UInt8(0)
global const TRM_VELMODE_GROUNDSPEED_TRACKANGLE = UInt8(1)
global const TRM_VELMODE_AIRSPEED_HEADING = UInt8(2)
global const TRM_VELMODE_GROUNDSPEED_HEADING = UInt8(3)
# Altitude Operation Mode Settings
global const TRM_ALTMODE_NONE = UInt8(0)
global const TRM_ALTMODE_PRESSURE = UInt8(1)
global const TRM_ALTMODE_HAE = UInt8(2)
# Mode C
global const MODE_C_QUANT = UInt32( 100 )
# Correlation
global const CORRELATION_MECH_NOT_AUTHORIZED = UInt8( 0 )
global const CORRELATION_MECH_ICAO24 = UInt8( 1 )
global const CORRELATION_MECH_ANON24 = UInt8( 2 )
global const CORRELATION_MECH_V2VUID = UInt8( 3 )
global const CORRELATION_MECH_ICAO24_V2VUID = UInt8( 4 )
global const CORRELATION_MECH_ANON24_V2VUID = UInt8( 5 )
global const CORRELATION_MECH_SPATIAL = UInt8( 6 )
global const CORRELATION_MECH_S_STAR = UInt8( 7 )
global const CORRELATION_SINGLE_NAR_NA = UInt8( 0 )
global const CORRELATION_SINGLE_NAR_AUTHORIZED = UInt8( 1 )
global const CORRELATION_SINGLE_NAR_TYPE_A = UInt8( 2 )
global const CORRELATION_SINGLE_NAR_TYPE_B = UInt8( 3 )
global const CORRELATION_TRKTYPE_INVALID = UInt8( 0x00 )
global const CORRELATION_TRKTYPE_ADSB_ICAO24 = UInt8( 0x01 )
global const CORRELATION_TRKTYPE_ADSB_ANON24 = UInt8( 0x02 )
global const CORRELATION_TRKTYPE_V2V_V2VUID = UInt8( 0x03 )
global const CORRELATION_TRKTYPE_V2V_V2VUID_ICAO24 = UInt8( 0x04 )
global const CORRELATION_TRKTYPE_V2V_V2VUID_ANON24 = UInt8( 0x05 )
global const CORRELATION_TRKTYPE_ORNCT_ORNCTID = UInt8( 0x06 )
global const CORRELATION_TRKTYPE_AGT_AGTID = UInt8( 0x07 )
global const CORRELATION_TRKTYPE_AGT_AGTID_ICAO24 = UInt8( 0x08 )
global const CORRELATION_TRKTYPE_AGT_AGTID_ANON24 = UInt8( 0x09 )
global const CORRELATION_TRKTYPE_AGT_AGTID_V2VUID = UInt8( 0x0A )
global const CORRELATION_TRKTYPE_AGT_AGTID_V2VUID_ICAO24 = UInt8( 0x0B )
global const CORRELATION_TRKTYPE_AGT_AGTID_V2VUID_ANON24 = UInt8( 0x0C )
global const CORRELATION_PENDING = UInt8( 0 )
global const CORRELATION_POSITIVE = UInt8( 1 )
global const CORRELATION_NEGATIVE = UInt8( 2 )
global const CORRELATION_SPATIAL_POSITIVE = UInt8( 3 )
global const CORRELATION_SPATIAL_NEGATIVE = UInt8( 4 )
# Altitude boundaries for aircraft that have Non-Altitude Reporting Surveillance
global const NARS_THRESHOLD_MIN = ( -1200.0 )
global const NARS_THRESHOLD_MAX = ( 126750.0 )
# Altitude Buffer for TRM Crossing Determination
global const CROSSING_ALTITUDE_BUFFER = 100.0
# Display Arrow Indicators
global const DISPLAY_ARROW_LEVEL = Int( 0 )
global const DISPLAY_ARROW_CLIMB = Int( 1 )
global const DISPLAY_ARROW_DESCEND = Int( -1 )
# CAS Coordination Capability/Type over ADS-B OSM
global const CAS_ACTIVE_TCAS = UInt8( 0 )
global const CAS_ACTIVE_NON_TCAS = UInt8( 1 )
global const CAS_ACTIVE_NON_TCAS_OCM = UInt8( 2 )
global const CASRESP_ACTIVE = UInt8( 3 )
global const CASRESP_PASSV_MODES = UInt8( 4 )
global const CASRESP_PASSV = UInt8( 5 )
# CAS Coordination Capability/Type over V2V OSM
global const CAS_V2V_NONE = UInt8( 0 )
global const CAS_V2V_SXU = UInt8( 1 )
global const CAS_V2V_XR = UInt8( 2 )
# CAS Coordination Sense in CCCB
global const CAS_SENSE_VERTICAL_ONLY = UInt8( 0 )
global const CAS_SENSE_HORIZONTAL_ONLY = UInt8( 1 )
global const CAS_SENSE_BLENDED = UInt8( 2 )
global const CAS_SENSE_PER_INTRUDER = UInt8( 3 )
# V2V priority in CCCB
global const SXU_V2V_CCCB_PRIORITY_MIDDLE = UInt8( 7 )
# V2V OSM: pilot/passengers message element
global const V2V_OSM_UNKNOWN_ONBOARD = UInt8( 0 )
global const V2V_OSM_ONLY_PASSENGERS_ONBOARD = UInt8( 1 )
global const V2V_OSM_ONLY_PILOT_ONBOARD = UInt8( 2 )
global const V2V_OSM_PILOT_AND_PASSENGERS_ONBOARD = UInt8( 3 )
global const V2V_OSM_NONE_ONBOARD = UInt8( 4 )
# DAA Coordination Capability
global const DAA_RCV_NONE = UInt8( 0 )
global const DAA_RCV_ACTIVE = UInt8( 1 )
global const DAA_RCV_PASSV = UInt8( 2 )
# Ownship-Relative-Non-Cooperative-Track Status Indicators
global const ORNCT_STATUS_HIGH_PRIORITY_TRACK = UInt8( 0x1 )
global const ORNCT_STATUS_MISSED_IN_LATEST_UPDATE = UInt8( 0x2 )
global const ORNCT_STATUS_FINAL_UPDATE = UInt8( 0x4 )
global const ORNCT_STATUS_TRACK_NEGATION = UInt8( 0x8 )
# Absolute Geodetic Track Status Indicators
global const AGT_STATUS_HIGH_PRIORITY_TRACK = UInt16( 0x0001 )
global const AGT_STATUS_MISSED_IN_LATEST_UPDATE = UInt16( 0x0002 )
global const AGT_STATUS_TO_BE_DELETED = UInt16( 0x0004 )
global const AGT_STATUS_MODE_S_VALID = UInt16( 0x0008 )
global const AGT_STATUS_MODE_S_NON_ICAO = UInt16( 0x0010 )
global const AGT_STATUS_V2V_UID_VALID = UInt16( 0x0020 )
# Representation of a invalid target id/track idx (both start at 1).
global const NO_TARGET_FOUND = UInt32( 0 )
global const NO_TRACK_FOUND = Int64( 0 )
# Protection Mode Index when no Xo is implemented
global const NO_Xo_MODE_INDEX = UInt8( 1 )
# Ground Point Obstacle Awareness Constants
global const ID_GROUND = UInt32( 4294967295 )
global const GROUND_ALERT_NONE = UInt8( 0 )
global const GROUND_ALERT_ONLY = UInt8( 1 )
global const GROUND_ALERT_MIXED = UInt8( 2 )
# Horizontal Desensitivity Mode
global const HORIZONTAL_DESENSITIVITY_NONE = UInt8( 0 )
global const HORIZONTAL_DESENSITIVITY_SENSITIZE = UInt8( 1 )
global const HORIZONTAL_DESENSITIVITY_DESENSITIZE = UInt8( 2 )

# Cost Log Mode
global const CLM_PrioritizeAndFilterIntruders = UInt8(2)
global const CLM_SelectHorizontalAdvisory = UInt8(3)
