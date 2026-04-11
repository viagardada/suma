function CalculateThresholdRampUpFactor( value::R, threshold::R, rolloff::R )
factor::R = 1.0
if (value <= threshold)
factor = 0.0
elseif (value < (threshold + rolloff))
factor = (value - threshold) / rolloff
end
return factor::R
end
