function UpdateHistory(vt::ValueTime, value::R, time::R, window::R)
push!(vt.time,time)
push!(vt.value,value)
for i in reverse(1:length(vt.time))
if (vt.time[i] < time - window)
popfirst!(vt.time)
popfirst!(vt.value)
end
end
end
