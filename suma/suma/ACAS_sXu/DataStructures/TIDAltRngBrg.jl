mutable struct TIDAltRngBrg
tida::UInt16 # Threat ID encoded altitude (ft) (11 bits)
tidr::UInt8 # Threat ID encoded range (ft) ( 7 bits)
tidb::UInt8 # Threat ID encoded bearing (deg) ( 6 bits)
#
TIDAltRngBrg() =
new( UInt16(0), UInt8(0), UInt8(0) )
TIDAltRngBrg( tida::UInt16, tidr::UInt8, tidb::UInt8 ) =
new( tida, tidr, tidb )
end
