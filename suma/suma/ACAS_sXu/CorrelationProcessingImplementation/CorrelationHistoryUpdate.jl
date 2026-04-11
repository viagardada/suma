function CorrelationHistoryUpdate(lead_track_id::Union{UInt32, String}, track_id::Union{UInt32, String},history::CorrelationHistory, T::R)
h1 = history.id_pairs
h2 = history.timing
v = [lead_track_id, track_id]
if (!isempty(h2))
while T - h2[end] >= history.N
pop!(h2)
pop!(h1)
if (isempty(h2))
break
end
end
end
pushfirst!(h1, v)
pushfirst!(h2, T)
end
