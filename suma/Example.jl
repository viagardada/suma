# Short ACAS sXu Julia example. Not all entry points might be used.

push!(LOAD_PATH, "ACAS_sXu")
import ACAS_sXu

# LookupTables are expected to be present in the same directory as this Example
stm = ACAS_sXu.STM("LookupTables/DO-396_paramsfile_acassxu_origami_20220908.txt")
stmReport = nothing
# Enables TRM table cache. Tables are kept in memory and reused for other ACAS_sXu.TRM instances.
ACAS_sXu.SetsXuTableCacheEnabled(true)
trm = ACAS_sXu.TRM("LookupTables/DO-396_paramsfile_acassxu_origami_20220908.txt", stm)
trmState = ACAS_sXu.sXuTRMState()
trmReport = nothing

# Input entry points.
ACAS_sXu.ReceivePresAltObservation(stm, 600.0, 0.06670783902518451)
ACAS_sXu.ReceiveWgs84Observation(stm, 42.34179598957386, -71.09783291452761, 0.0, 29.624190064848616, 589.0, 0.0, convert(UInt32, 10), convert(UInt32, 3), 8.0, 0.06670783902518451)
ACAS_sXu.ReceiveStateVectorPositionReport(stm, 42.35313286215572, -71.0984695789426, 800.0, false, convert(UInt32, 2), convert(UInt32, 6), convert(UInt32, 25), false, 0.06670783902518451)
ACAS_sXu.ReceiveStateVectorVelocityReport(stm, -7.536547660827637, -1.0403733253479004, convert(UInt32, 2), convert(UInt32, 6), false, 0.4105301153380425)
ACAS_sXu.ReceiveStateVectorPositionReport(stm, 42.35313286215572, -71.0984695789426, 800.0, false, convert(UInt32, 2), convert(UInt32, 6), convert(UInt32, 25), false, 0.5472401216160505)
ACAS_sXu.ReceiveStateVectorPositionReport(stm, 42.3530863099179, -71.0984695789426, 800.0, false, convert(UInt32, 2), convert(UInt32, 6), convert(UInt32, 25), false, 0.9897873431909829)
ACAS_sXu.ReceiveHeadingObservation(stm, 0.0, 1.0, false)
ACAS_sXu.ReceiveHeightAglObservation(stm, 150.0)
ACAS_sXu.ReceivePresAltObservation(stm, 600.0, 1.0)
ACAS_sXu.ReceiveDiscretes(stm, convert(UInt128, 1), true, convert(UInt8, 3), 0.0524, 8.33333333333333, false, true, false, convert(UInt8, 0))
ACAS_sXu.ReceiveWgs84Observation(stm, 42.341877583964255, -71.097777, 0.0, 29.624190064848616, 589.0, 0.0, convert(UInt32, 10), convert(UInt32, 3), 8.0, 1.0)
ACAS_sXu.ReceivePointObstacleReport(stm, convert(UInt32, 1), 42.3831, -71.1059, 1.8725, false)
ACAS_sXu.ReceivePointObstacleReport(stm, convert(UInt32, 2), 42.3162, -71.0764, 239.1604, false)
ACAS_sXu.ReceiveModeStatusReport(stm, convert(UInt32, 2), convert(UInt32, 10), convert(UInt32, 3), convert(UInt32, 2), convert(UInt32, 3), convert(UInt32, 1), convert(UInt32, 2), false, false)
ACAS_sXu.ReceiveExternallyValidatedADSB(stm, true, convert(UInt32, 2), false)
ACAS_sXu.ReceiveStateVectorUatReport(stm, 42.25631825062742, -71.08393484736231, 3800.0, false, -5.009778022766113, 202.38729858398438, convert(UInt32, 2), convert(UInt32, 6), convert(UInt32, 25), false, 0.4892064342275262)
ACAS_sXu.ReceiveADSBOperationalStatusMessage(stm, convert(UInt8, 0), convert(UInt8, 0), convert(UInt8, 0), convert(UInt8, 0), convert(UInt8, 0), convert(UInt32, 2), false)
ACAS_sXu.ReceiveOwnRelNonCoopTrack(stm, convert(UInt32, 2), convert(UInt8, 1), convert(UInt8, 0), 1.0, 27275.97224317992, -2.1307068715130693, -110.1798277650468, 119.41519370187088, ACAS_sXu.Matrix{ACAS_sXu.R}(undef, 4, 4), -3568.354469638009, 255.93648105438402, ACAS_sXu.Matrix{ACAS_sXu.R}(undef, 2, 2))
ACAS_sXu.ReceiveAbsoluteGeodeticTrack(stm, convert(UInt32, 2), convert(UInt32, 2), convert(UInt128, 2), convert(UInt16, 0), true, convert(UInt8, 0), 42.30468787586399, -71.16674406553078, 109.58960791648562, 83.52331785180502, ACAS_sXu.Matrix{ACAS_sXu.R}(undef, 4, 4), 1842.8027780214445, -22.737371357670597, ACAS_sXu.Matrix{ACAS_sXu.R}(undef, 2, 2), 1842.8027780214445, -22.737371357670597, ACAS_sXu.Matrix{ACAS_sXu.R}(undef, 2, 2), 1.0 )
ACAS_sXu.ReceiveStateVectorV2VReport(stm, 42.33890721577529, -71.08739684310122, 650.0, NaN, -69.55757141113281, 46.556640625, convert(UInt32, 7), convert(UInt32, 10), convert(UInt32, 3), 0.896112000000853, convert(UInt32, 4), convert(UInt32, 1), convert(UInt128, 2), convert(UInt32, 0), false, false, convert(UInt8, 3), convert(UInt32, 1), 0.5829780015628785)
ACAS_sXu.ReceiveExternallyValidatedV2V(stm, true, convert(UInt128, 2))
ACAS_sXu.ReceiveTrueAirspeedObservation(stm, 35.39098592946545)
ACAS_sXu.ReceiveV2VOperationalStatusMessage(stm, convert(UInt8, 0), convert(UInt8, 0), convert(UInt8, 0), convert(UInt8, 7), convert(UInt8, 15), convert(UInt8, 0), convert(UInt128, 2))
ACAS_sXu.ReceiveV2VCoordination(stm, convert(UInt128, 222), convert(UInt32, 0), convert(UInt32, 1), convert(UInt32, 14), convert(UInt32, 0), convert(UInt32, 0), convert(UInt32, 0), 1.0)
ACAS_sXu.ReceiveDescentInhibitThresholds(stm, 0.1, 0.5)
ACAS_sXu.ReceiveTargetDesignation(convert(UInt32, 1), false, false, convert(UInt128, 222), true, convert(UInt32, 11))

# Generation of the output reports
stmReport = ACAS_sXu.GenerateStmReport(stm, 1.0)
trmReport = ACAS_sXu.sXuTRMUpdate(trm, trmState, stmReport.trm_input)
ACAS_sXu.StmHousekeeping(stm, trmReport)
