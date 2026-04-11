function SetBlendedCoordinationData(report::sXuTRMReport, report_horiz::HTRMReport,multidim_multithreat::Bool)
coord_dict::Dict{UInt32,TRMCoordinationData} = Dict{UInt32,TRMCoordinationData}()
for intruder in report_horiz.coordination
coord_dict[intruder.id] = intruder
end
for intruder in report.coordination
if haskey( coord_dict, intruder.id )
intruder.chc = coord_dict[intruder.id].chc
intruder.hrc = coord_dict[intruder.id].hrc
intruder.hsb = coord_dict[intruder.id].hsb
intruder.mtb = (intruder.mtb || coord_dict[intruder.id].mtb || multidim_multithreat)
else
intruder.chc = 0
intruder.hrc = 0
intruder.hsb = 0
end
end
return
end
