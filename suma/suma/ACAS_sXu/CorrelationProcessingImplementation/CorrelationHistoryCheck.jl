function CorrelationHistoryCheck(lead_track_id::Union{UInt32, String}, track_id::Union{UInt32, String}, history::CorrelationHistory)
count::Z = 0
h1 = history.id_pairs
v = [lead_track_id, track_id]
for k in 1:length(h1)
if (v == h1[k])
count += 1
end
end
return (count >= history.M)::Bool
end
