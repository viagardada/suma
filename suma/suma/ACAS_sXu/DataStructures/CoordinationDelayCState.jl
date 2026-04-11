mutable struct CoordinationDelayCState
t_count::Z # CoordinationDelay counter (s)
is_count_enabled::Bool # Whether the CoordinationDelay counter should be used
#
CoordinationDelayCState( is_count_enabled::Bool ) = new( 0, is_count_enabled )
end
