mutable struct CCCB
sense::UInt8 # Sense - two bits field for Vertical and Horizontal
# 0 = Vertical only
# 1 = Horizontal only
# 2 = Blended
# 3 = Vertical-only or Horizontal-only per intruder
type_capability::UInt8 # Aircraft CAS Type/Capability
# Note: different enumerations of type capability are
# used in the ADS-B CCCB and V2V CCCB
priority::UInt8 # Priority - two bits field envisioned for UAS use, to serve as a priority
# field to distinguish among users with different levels of capability
# or as directed by regulatory authorities
# Note: diffrent enumerations of priority are
# used in the ADS-B CCCB and V2V CCCB
CCCB( sense::UInt8, type_capability::UInt8, priority::UInt8 ) = new(sense, type_capability, priority)
end
