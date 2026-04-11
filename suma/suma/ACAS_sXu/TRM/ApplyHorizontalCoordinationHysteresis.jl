function ApplyHorizontalCoordinationHysteresis(this::TRM, match_thresh::R, prev_sent_hrc::UInt32, prev_turn_rate::R,turn_rate::R)
hcoord_hysteresis::R = this.params["horizontal_trm"]["horizontal_offline"]["hcoord_policy"]["C_hcoord_hysteresis"]
if (prev_sent_hrc != 0)
sense_prev::Symbol = HorizontalRateToSense( this, prev_turn_rate )
sense_curr::Symbol = HorizontalRateToSense( this, turn_rate )
if !IsHorizontalReversal(sense_prev, sense_curr)
prev_sent_hcoord_msg::Symbol = HRCToAdvisory( prev_sent_hrc )
curr_hcoord_msg::Symbol = HorizontalRateToAdvisory( this, turn_rate )
if ( (curr_hcoord_msg == :DontTurnRight) && (prev_sent_hcoord_msg == :DontTurnRight) ) ||
( (curr_hcoord_msg == :DontTurnLeft) && (prev_sent_hcoord_msg == :DontTurnLeft) )
if (match_thresh > -1 * hcoord_hysteresis)
match_thresh = 1.0
end
elseif ( (curr_hcoord_msg == :DontTurnLeft) && (prev_sent_hcoord_msg == :DontTurnRight) ) ||
( (curr_hcoord_msg == :DontTurnRight) && (prev_sent_hcoord_msg == :DontTurnLeft) )
if (match_thresh < 1 * hcoord_hysteresis)
match_thresh = -1.0
end
end
end
end
return match_thresh::R
end
