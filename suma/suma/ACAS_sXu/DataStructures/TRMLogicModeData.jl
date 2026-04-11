mutable struct TRMLogicModeData
# Deviation potential: Refer to ACAS sXu MOPS Vol. II Appendix L
processing::UInt8 # TRM logic processing mode (See RA_PROCESSING_)
dna::Bool # Whether Designated No Alerts (DNA) is active
protection_mode::UInt8 # Active protection mode (See PROTECTION_MODE_)
#
TRMLogicModeData() =
new( RA_PROCESSING_NONE, false, PROTECTION_MODE_sXu )
end
