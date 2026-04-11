function GetIndexFromClassification( int_classification::UInt8, classification_array::Array{Z} )
idx_class::Z = 0
int_class_manned_idx::Z = 0
counter::Z = 0
found_idx::Bool = false
# Search for the desired intruder classification index
for class::UInt8 in classification_array
counter += 1
if int_classification==class
found_idx = true
idx_class = counter
elseif class == CLASSIFICATION_MANNED
int_class_manned_idx = counter
end
end
if !found_idx
idx_class = int_class_manned_idx
end
return idx_class::Z
end
