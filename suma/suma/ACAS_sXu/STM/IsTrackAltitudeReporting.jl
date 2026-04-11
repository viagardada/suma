function IsTrackAltitudeReporting(this::STM, trk::Union{TrackFile, Nothing})
return (trk != nothing) && (
((typeof(trk) == ADSBTrackFile) && AssessVerticalValidity(this, trk)) ||
((typeof(trk) == V2VTrackFile) && AssessVerticalValidity(this, trk)) ||
((typeof(trk) == AGTTrackFile) && AssessVerticalValidity(this, trk)) ||
((typeof(trk) == ORNCTTrackFile) && AssessVerticalValidity(this, trk)) )
end
