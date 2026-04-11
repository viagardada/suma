mutable struct MultithreatCostBalancingCState
costs_allow_mtlo_prev::Bool # MTLO allowed based on costs on previous cycle
above_abs_threshold_prev::Bool # Whether to apply hysteresis for cost threshold
#
MultithreatCostBalancingCState() = new( true, false )
end
