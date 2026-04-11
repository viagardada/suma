function TrackExists(trk::Union{Vector, TrackFile, Nothing})
if typeof(trk) <: Vector
return !isempty(trk)
else
return (trk != nothing)
end
end
