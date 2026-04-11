mutable struct IntruderIDDirectory
icao24::IntruderIDEntry{UInt32}
anon24::IntruderIDEntry{UInt32}
v2v_uid::IntruderIDEntry{UInt128}
ornct_id::IntruderIDEntry{UInt32}
agt_ids::Vector{UInt32}
po_id::IntruderIDEntry{UInt32}
IntruderIDDirectory() = new(
IntruderIDEntry{UInt32}(),
IntruderIDEntry{UInt32}(),
IntruderIDEntry{UInt128}(),
IntruderIDEntry{UInt32}(),
UInt32[],
IntruderIDEntry{UInt32}()
)
IntruderIDDirectory(
icao24::IntruderIDEntry{UInt32},
anon24::IntruderIDEntry{UInt32},
v2v_uid::IntruderIDEntry{UInt128},
ornct_id::IntruderIDEntry{UInt32},
agt_ids::Vector{UInt32},
po_id::IntruderIDEntry{UInt32}
) = new(icao24,anon24,v2v_uid,ornct_id,agt_ids,po_id)
end
