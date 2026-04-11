mutable struct IntruderPublishedRaState
id::UInt32 # Unique target identifier
has_been_published::Bool # Indication of RA report publish state
included_in_prev_tid1::Bool # Used to signal that this intruder was included in
# RA TIDAltRngBrg field One in the prevvious cycles report
included_in_prev_tid2::Bool # Used to signal that this intruder was included in
# RA TIDAltRngBrg field two in the prevvious cycles report
#
IntruderPublishedRaState(id::UInt32) = new( id, false, false, false)
end
