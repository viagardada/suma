function DetermineConflictingSenses( senses_own_indiv::Vector{Symbol}, exclude_int::Vector{Bool} )
up_sense_issued::Bool = false
down_sense_issued::Bool = false
for i = 1:length( senses_own_indiv )
if !exclude_int[i]
if (senses_own_indiv[i] == :Up)
up_sense_issued = true
elseif (senses_own_indiv[i] == :Down)
down_sense_issued = true
end
end
end
conflicting_senses::Bool = up_sense_issued && down_sense_issued
return conflicting_senses::Bool
end
