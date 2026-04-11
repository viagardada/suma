mutable struct ActionArbitrationGlobalCState
mtlo_prohibited_prev::Bool # MTLO was prohibited on the previous cycle
worst_case_cost_prev::R # Value of worst case cost on previous cycle
worst_case_action_prev::Z # Worst case action selected on previous cycle
#
ActionArbitrationGlobalCState() = new( false, -Inf, COC )
end
