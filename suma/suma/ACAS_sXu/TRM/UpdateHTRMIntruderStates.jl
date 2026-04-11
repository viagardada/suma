function UpdateHTRMIntruderStates( st_int::Vector{HTRMIntruderState}, reset_priority::Bool, reset_state::Bool )
for i in 1:length( st_int )
UpdateHTRMIntruderState( st_int[i], reset_priority, reset_state )
end
end
