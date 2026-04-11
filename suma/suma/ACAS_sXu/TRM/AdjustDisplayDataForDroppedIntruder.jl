function AdjustDisplayDataForDroppedIntruder( cc::UInt8, st_own::Union{TRMOwnState,HTRMOwnState},st_int::Union{Vector{TRMIntruderState},Vector{HTRMIntruderState}} )
adjustDisplay::Bool = false
if (cc == 1)
for intruder in st_int
if (isa(st_int,Vector{TRMIntruderState}) && intruder.a_prev.ra_prev && intruder.status == :Dropped)
adjustDisplay = true
break
elseif (isa(st_int,Vector{HTRMIntruderState}) && in(intruder.id, st_own.advisory_prev.threat_list) && intruder.status == :Dropped)
adjustDisplay = true
break
end
end
if adjustDisplay
cc = UInt8(0)
end
end
return (cc::UInt8)
end
