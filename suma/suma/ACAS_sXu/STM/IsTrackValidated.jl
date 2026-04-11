function IsTrackValidated(trk::Union{TrackFile, Nothing})
return (trk != nothing) && (
((typeof(trk) == ADSBTrackFile) && ValidationCheck(trk)) ||
((typeof(trk) == V2VTrackFile) && ValidationCheck(trk)) ||
((typeof(trk) == AGTTrackFile) && ValidationCheck(trk)) ||
(typeof(trk) == ORNCTTrackFile) )
end
