function VerticalTRMUpdatePrepDeviation( this::TRM, st_trm::TRMState, input::TRMInput, ground_int::TRMIntruderInput )
N_actions::Z = this.params["actions"]["num_actions"]
N_modes::Z = length( this.params["modes"] )
scale_factor_classifications::Array{Z} = this.params["threat_resolution"]["vertical_scaling"]["classification"]
online_cost_classifications::Array{Z} = this.params["threat_resolution"]["online_cost_classification"]
(input_int_invalid::Vector{TRMIntruderInput}, input_int_valid::Vector{TRMIntruderInput}, input_dict_int::Dict{Z,TRMIntruderInput}) =
DetermineIntruderVerticalValidity(this, input, ground_int)
num_intruders::Z = length( input_int_valid )
TRM_st_int::Dict{UInt32,TRMIntruderState} = Dict{UInt32,TRMIntruderState}()
for st_int_iter::TRMIntruderState in st_trm.st_intruder
if !haskey( input_dict_int, st_int_iter.id )
st_int_iter.status = :Dropped
else
TRM_st_int[st_int_iter.id] = st_int_iter
st_int_iter.status = :InUse
end
end
for intruder in input_int_invalid
if !haskey( TRM_st_int, intruder.id )
st_int_iter = TRMIntruderState( intruder.id, intruder.id_directory )
st_int_iter.idx_scale = GetIndexFromClassification( intruder.classification, scale_factor_classifications )
st_int_iter.idx_online_cost = GetIndexFromClassification( intruder.classification, online_cost_classifications )
push!( st_trm.st_intruder, st_int_iter )
TRM_st_int[st_int_iter.id] = st_int_iter
end
end
(z_int_ave::Vector{R}, dz_int_ave::Vector{R}) = (zeros(R, num_intruders), zeros(R, num_intruders))
(source_int::Vector{Z}, mode_int::Vector{Z}) = (zeros(Z, num_intruders), zeros(Z, num_intruders))
(code_int::Vector{UInt8}, classification_int::Vector{UInt8}, sense_int::Vector{Symbol}) = (zeros(UInt8, num_intruders), zeros(UInt8, num_intruders), fill(:None, num_intruders))
st_int::Vector{TRMIntruderState} = Vector{TRMIntruderState}( undef, num_intruders )
output_int::Vector{TRMIntruderData} = Vector{TRMIntruderData}( undef, num_intruders )
# Deviation Change for Inhibits
# create an altitude inhibit cost state for each protection mode
if (0 == length( st_trm.st_own.st_alt_inhibit ))
st_trm.st_own.st_alt_inhibit = Vector{AltitudeInhibitCState}( undef, N_modes )
for mode_idx in 1:N_modes
st_trm.st_own.st_alt_inhibit[mode_idx] = AltitudeInhibitCState( this.params, mode_idx )
end
end
for j in 1:length( input_int_valid )
intruder = input_int_valid[j]
id::UInt32 = intruder.id
if haskey( TRM_st_int, id )
st_int[j] = TRM_st_int[id]
else
st_int[j] = TRMIntruderState( id, intruder.id_directory )
st_int[j].idx_scale = GetIndexFromClassification( intruder.classification, scale_factor_classifications )
st_int[j].idx_online_cost = GetIndexFromClassification( intruder.classification, online_cost_classifications )
push!( st_trm.st_intruder, st_int[j] )
TRM_st_int[id] = st_int[j]
end
end
return (st_int::Vector{TRMIntruderState}, input_int_invalid::Vector{TRMIntruderInput},
input_int_valid::Vector{TRMIntruderInput}, num_intruders::Z, z_int_ave::Vector{R},
dz_int_ave::Vector{R}, mode_int::Vector{Z}, code_int::Vector{UInt8},
sense_int::Vector{Symbol}, output_int::Vector{TRMIntruderData}, source_int::Vector{Z}, classification_int::Vector{UInt8})
end
