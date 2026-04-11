function DetermineHorizontalDesensitivity( this::TRM, effective_turn_rate::R, effective_vert_rate::R )
(C_direct_sensitivity_factor::R, C_desensitivity::R) = GetPerformanceBasedParams( this, effective_vert_rate, effective_turn_rate )
horizontal_desensitivity_mode::UInt8 = HORIZONTAL_DESENSITIVITY_NONE
if (C_direct_sensitivity_factor > 1.0) && (C_desensitivity == 0.0)
horizontal_desensitivity_mode = HORIZONTAL_DESENSITIVITY_SENSITIZE
elseif (C_direct_sensitivity_factor == 1.0) && (C_desensitivity < 0.0)
horizontal_desensitivity_mode = HORIZONTAL_DESENSITIVITY_DESENSITIZE
end
return horizontal_desensitivity_mode::UInt8
end
