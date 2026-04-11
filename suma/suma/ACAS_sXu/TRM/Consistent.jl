function Consistent( dz_own::R, action::Z, action_prev::Z, word_prev::Z, crossing::Bool,
alt_inhibit::Bool, strength_prev::UInt8,
R_dz_lo::R, R_dz_hi::R, L_act::Z, L_act_prev::R,
L_word_prev::R, L_crossing::R, L_alt_inhibit::R, L_strength_prev::R )
is_consistent::Bool = true
if ( (action != L_act)
|| (!isnan( R_dz_hi ) && (R_dz_hi < dz_own))
|| (!isnan( R_dz_lo ) && (dz_own < R_dz_lo))
|| (!isnan( L_act_prev ) && (action_prev != Int( L_act_prev )))
|| (!isnan( L_word_prev ) && (word_prev != Int( L_word_prev )))
|| (!isnan( L_crossing ) && (crossing != Bool( L_crossing )))
|| (!isnan( L_alt_inhibit ) && (alt_inhibit != Bool( L_alt_inhibit )))
|| (!isnan( L_strength_prev ) && (strength_prev != UInt8( L_strength_prev ))))
is_consistent = false
end
return is_consistent::Bool
end
