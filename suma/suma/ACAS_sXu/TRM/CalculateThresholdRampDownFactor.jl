function CalculateThresholdRampDownFactor( value::R, threshold::R, rolloff::R )
factor::R = 0.0
if (value <= threshold)
factor = 1.0
elseif (value < (threshold + rolloff))
factor = 1.0 - ((value - threshold) / rolloff)
end
return factor::R
end
