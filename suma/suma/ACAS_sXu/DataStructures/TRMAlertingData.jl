mutable struct TRMAlertingData
warning_alert::Bool # Flag denoting a warning alert is active
opmode::UInt8 # Ownship Operational Mode
ras_inhibited::Bool # Flag denoting when RAs are inhibited based on OPMODE constants
#
TRMAlertingData() =
new( false, OPMODE_STANDBY, false )
TRMAlertingData( warning_alert::Bool, opmode::UInt8, ras_inhibited::Bool ) =
new( warning_alert, opmode, ras_inhibited )
end
