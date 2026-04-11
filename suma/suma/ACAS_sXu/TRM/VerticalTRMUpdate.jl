function VerticalTRMUpdate( this::TRM, input::TRMInput, sxu_trm_state::sXuTRMState )

# HON: Logging: Intruder costs.
this.loggedCurrentIntruderIdx = 0
this.loggedCurrentAction = 0

input_own::TRMOwnInput = input.own
st_own::TRMOwnState = sxu_trm_state.st_vert.st_own
action::Z = 0
dz_min::R = 0.0
dz_max::R = 0.0
ddz::R = 0.0
multithreat::Bool = false
received_vrcs::Vector{Bool} = zeros( Bool, 4 )
ground_int::TRMIntruderInput = CreateGroundIntruder(input_own.belief_vert[1].z, input_own.h)
(st_int::Vector{TRMIntruderState}, input_int_invalid::Vector{TRMIntruderInput},
input_int_valid::Vector{TRMIntruderInput}, num_intruders::Z, z_int_ave::Vector{R},
dz_int_ave::Vector{R}, mode_int::Vector{Z}, code_int::Vector{UInt8}, sense_int::Vector{Symbol},
output_int::Vector{TRMIntruderData}, source_int::Vector{Z}, classification_int::Vector{UInt8}) =
VerticalTRMUpdatePrep( this, sxu_trm_state.st_vert, input, ground_int )

# HON: Logging: Intruder costs.
# Allocate logged costs for all processed intruders.
N_actions::Z = this.params["actions"]["num_actions"]
for j in 1:length(st_int)
    # Fetch the current id_directory from STM.
    id_directory::IntruderIDDirectory = st_int[j].id_directory
    for intruder in input.intruder
        if (intruder.id == st_int[j].id)
            id_directory = intruder.id_directory
            break
        end
    end
    push!(this.loggedCosts.individual, IntruderCostsLogData(st_int[j].id, id_directory, convert(UInt32, N_actions)))
end

(z_own_ave::R, dz_own_ave::R, height_own::R) = GetVTRMOwnData( this, input_own::TRMOwnInput,st_own::TRMOwnState )
if (input_own.opmode == OPMODE_SURV_ONLY) && (input_own.trm_altmode != TRM_ALTMODE_NONE)
(received_vrcs, action, dz_min, dz_max, ddz, multithreat) =
SetVerticalTRMSurvOnlyMode(this, height_own, z_own_ave, dz_own_ave, input_own, input_int_valid,
output_int, mode_int, z_int_ave, dz_int_ave, st_own, st_int)

# HON: Logging: Intruder costs.
# Clean intruders
this.loggedCosts.individual = []
	
elseif (0 < num_intruders)
(equip_int::Vector{Bool}, exclude_int::Vector{Bool}, tau_int::Vector{R}, cost_ra::Matrix{R},received_vrcs) =
StateAndCostEstimation( this, height_own, z_own_ave, dz_own_ave, input_own,
input_int_valid, mode_int, z_int_ave, dz_int_ave, st_own, st_int )
(action, dz_min, dz_max, ddz, action_indiv::Vector{Z}, st_own.dz_ave_prev, multithreat) =
ActionSelection( this, mode_int, cost_ra, z_int_ave, dz_int_ave, tau_int, z_own_ave, dz_own_ave,
equip_int, exclude_int, st_own, st_int )
for j in 1:num_intruders
(cvc::UInt32, vrc::UInt32, vsb::UInt32, sense_indiv::Symbol) =
CoordinationSelection( this, action_indiv[j], action, dz_min, dz_max, ddz, dz_own_ave,
st_own.a_prev, st_int[j].a_prev, input_int_valid[j].equipage )
code_int[j]::UInt8 = DetermineCode( sense_indiv )
output_int[j] = TRMIntruderData( input_int_valid[j].id, sense_indiv, input_own.v2v_uid,input_own.v2v_uid_valid,
input_int_valid[j].id_directory, cvc, vrc, vsb, multithreat,
input_int_valid[j].coordination_msg, 0.0, code_int[j],
input_int_valid[j].classification )
output_int[j].display.source = input_int_valid[j].source
sense_int[j] = sense_indiv
source_int[j] = input_int_valid[j].source
classification_int[j] = input_int_valid[j].classification
end
else
received_vrcs = UpdateIntruderVRC( this.stm, input_int_valid )
(action, dz_min, dz_max, ddz, multithreat) = NoIntrudersAction( this, dz_own_ave, st_own )

# HON: Logging: Intruder costs.
# Clean intruders
this.loggedCosts.individual = []
end
ground_alert::UInt8 = DetermineGroundAlert( output_int )
display::DisplayLogic =
DisplayLogicDetermination( this, input_own.h, z_own_ave, dz_own_ave, z_int_ave, action, dz_min, dz_max,
ddz, sense_int, code_int, st_own, source_int, classification_int, sxu_trm_state.st_vert.st_intruder, ground_alert, input_own.trm_altmode )
SetIntruderVerticalScores( this, st_int, input_int_valid, input_own.opmode, output_int )
report_vert::VTRMReport =
GenerateVTRMOutput( this, input_own, display, multithreat, action, dz_min, dz_max, ddz, z_own_ave,
input_int_invalid, input_int_valid, output_int, received_vrcs, sxu_trm_state )
return (report_vert::VTRMReport)
end
