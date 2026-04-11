function HorizontalAlertLookahead(this::TRM, st_own::HTRMOwnState, prioritized_intruders::Vector{HTRMIntruderState}, effective_turn_rate::R, effective_vert_rate::R )
T_dt::R = this.params["horizontal_trm"]["htrm_alert_lookahead"]["T_dt"]
T_min::R = this.params["horizontal_trm"]["htrm_alert_lookahead"]["T_min"]
T_max::R = this.params["horizontal_trm"]["htrm_alert_lookahead"]["T_max"]
T_max_coc::R = this.params["horizontal_trm"]["htrm_alert_lookahead"]["T_max_coc"]
T_threat_timeout::R = this.params["horizontal_trm"]["htrm_alert_lookahead"]["T_threat_timeout"]
t_lookahead::R = 0.0
t_coc::R = 0.0
t_threat::R = T_threat_timeout
found_reversal::Bool = false
found_maintain::Bool = false
action::Z = COC
last_action::Z = st_own.advisory_prev.action
selected_advisory::HorizontalAdvisory = HorizontalAdvisory()
selected_advisory.track_angle = 0.0
enu_beliefs_own::EnuBeliefSet = deepcopy( st_own.enu_beliefs )
enu_beliefs_int::Vector{EnuBeliefSet} = EnuBeliefSet[]
for i in 1:length( prioritized_intruders )
push!( enu_beliefs_int, deepcopy( prioritized_intruders[i].enu_beliefs ) )
end

# HON: Logging: Intruder costs.
N_actions::Z = this.params["turn_actions"]["num_actions"]
this.loggedCosts.selectHorizontalAdvisory = []

while (t_coc <= T_max_coc) && (t_lookahead <= T_max) &&
(st_own.is_advisory_prev || (t_lookahead <= T_min) || (COC != selected_advisory.action))
t_lookahead = t_lookahead + T_dt

# HON: Logging: Intruder costs.
advisoryItem::SelectHorizontalAdvisoryItem = SelectHorizontalAdvisoryItem(convert(UInt32, N_actions))
push!(this.loggedCosts.selectHorizontalAdvisory, advisoryItem)
advisoryItem.t_lookahead = t_lookahead
this.costLogMode = CLM_SelectHorizontalAdvisory

update_new_threat_list::Bool = (0 < t_threat)
update_active_threat_list::Bool = ((t_lookahead < T_min) || (COC != st_own.advisory_prev.action))
action = SelectHorizontalAlertLookaheadAction( this, enu_beliefs_own, enu_beliefs_int, st_own, prioritized_intruders, last_action, effective_turn_rate, effective_vert_rate,update_active_threat_list, update_new_threat_list, selected_advisory )
if (COC != action) && update_new_threat_list
t_threat = t_threat - T_dt
end
turn_rate::R = HorizontalActionToRate( this, action )
sense_action::Symbol = HorizontalRateToSense( this, turn_rate )
sense_advisory::Symbol = HorizontalRateToSense( this, selected_advisory.turn_rate )
if IsHorizontalCOC( turn_rate )
t_coc = t_coc + T_dt
last_action = action
elseif IsHorizontalMaintain( this, turn_rate )
t_coc = 0.0
last_action = action
found_maintain = true
if IsHorizontalCOC( selected_advisory.turn_rate )
selected_advisory.turn_rate = turn_rate
selected_advisory.action = action
end
elseif IsHorizontalReversal( sense_advisory, sense_action )
t_coc = 0.0
last_action = selected_advisory.action
found_reversal = true
else
t_coc = 0.0
last_action = action
if !(found_reversal || found_maintain)
selected_advisory.track_angle = WrapToPi( selected_advisory.track_angle + (turn_rate * T_dt) )
end
if IsHorizontalCOC( selected_advisory.turn_rate )
selected_advisory.turn_rate = turn_rate
selected_advisory.action = action
end
end
UpdateEnuBeliefs( this, turn_rate, enu_beliefs_own, enu_beliefs_int )
end
return selected_advisory::HorizontalAdvisory
end
