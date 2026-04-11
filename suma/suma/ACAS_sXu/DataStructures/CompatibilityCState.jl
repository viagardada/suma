mutable struct CompatibilityCState
t_since_first_vrc::Z # Time since the first VRC was received (s)
c_slave_init::R # Cost of initiating an RA
c_slave_init_crossing::R # Cost of initiating an RA when there is a crossing
c_slave_sub::R # Cost for a subsequent RA
c_slave_sub_noncrossing::R # Cost for a subsequent RA when there is no crossing
c_slave_sub_no_response::R # Cost for any RA against a non-responsive intruder
#
CompatibilityCState() = new( 0, 0.0, 0.0, 0.0, 0.0, 0.0 )
end
