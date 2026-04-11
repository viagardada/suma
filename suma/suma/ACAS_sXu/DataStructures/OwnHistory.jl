mutable struct OwnHistory
heading::ValueTime # own heading observation ([radians], [seconds])
pres_alt::ValueTime # own Pressure Altitude observation ([ft], [ft/seconds])
hae_alt::ValueTime # own geodetic HAE observation ([ft], [ft/seconds])
OwnHistory() = new(
ValueTime(),
ValueTime(),
ValueTime()
)
end
