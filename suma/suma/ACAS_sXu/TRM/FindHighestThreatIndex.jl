function FindHighestThreatIndex( highest_threat::UInt32, prioritized_intruders::Vector{HTRMIntruderState})
threat_index::Z = -1
for i::Z in 1:length( prioritized_intruders )
if (prioritized_intruders[i].id == highest_threat)
threat_index = i
break
end
end
return threat_index::Z
end
