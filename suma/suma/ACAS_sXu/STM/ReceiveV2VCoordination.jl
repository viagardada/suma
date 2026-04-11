function ReceiveV2VCoordination(this::STM, v2v_uid::UInt128, cvc::UInt32, vrc::UInt32, vsb::UInt32, chc::UInt32, hrc::UInt32, hsb::UInt32, toa::R)
parity_table_vert::Vector{Z} = this.params["coordination"]["parity_table_vert"]
parity_table_hor::Vector{Z} = this.params["coordination"]["parity_table_hor"]
vert_intent::Vector{Z} = this.params["coordination"]["vert_intent"]
hor_intent::Vector{Z} = this.params["coordination"]["hor_intent"]
associated_ids::Vector{UInt32} = AssociateV2VToV2VAndAGTTargets(this, v2v_uid)
for id in associated_ids
tgt = RetrieveWithID(this.target_db, id)
parity_index::Z = (((cvc << 2) | vrc) + 1)
parity::Z = parity_table_vert[parity_index]
tgt.bad_v2vcoordination_vert = false
vertically_coordinating::Bool = !((cvc == 0) && (vrc == 0) && (vsb == 0))
if vertically_coordinating
if (parity != vsb)
tgt.bad_v2vcoordination_vert = true
elseif (cvc == 3) || (vrc == 3) || (cvc == vrc)
tgt.bad_v2vcoordination_vert = true
else
tgt.coord_data.toa_vert = toa
if (cvc != 0) && (tgt.coord_data.vrc != 0) && (vert_intent[cvc] == vert_intent[tgt.coord_data.vrc])
tgt.coord_data.vrc = 0
DeleteIntent(this, vert_intent[cvc], true)
end
if (vrc != 0) && (tgt.coord_data.vrc != vrc)
inferred_cvc = tgt.coord_data.vrc
tgt.coord_data.vrc = vrc
this.own.received_vrcs[vert_intent[vrc]] = true
if inferred_cvc != 0
DeleteIntent(this, vert_intent[inferred_cvc], true)
end
end
end
end
tgt.bad_v2vcoordination_horz = false
horizontally_coordinating::Bool = !((chc == 0) && (hrc == 0) && (hsb== 0))
if horizontally_coordinating
parity_index_hor::Z = (chc << 3 | hrc) + 1
parity_hor::Z = parity_table_hor[parity_index_hor]
parity_hor_valid::Bool = (parity_hor == hsb)
valid_hor = (chc != hrc) && (chc < 3) && (hrc != 3) && (hrc != 4) && (hrc != 7)
tgt.bad_v2vcoordination_horz = (parity_hor_valid == false || valid_hor == false)
if (!tgt.bad_v2vcoordination_horz)
tgt.coord_data.toa_hor = toa
if (chc != 0) && (tgt.coord_data.hrc != 0) && (hor_intent[chc] == hor_intent[tgt.coord_data.hrc])
tgt.coord_data.hrc = 0
DeleteIntent(this, hor_intent[chc], false)
end
if (hrc != 0) && (tgt.coord_data.hrc != hrc)
inferred_chc = tgt.coord_data.hrc
tgt.coord_data.hrc = hrc
this.own.received_hrcs[hor_intent[hrc]] = true
if inferred_chc != 0
DeleteIntent(this, hor_intent[inferred_chc], false)
end
end
end
end
end
end
