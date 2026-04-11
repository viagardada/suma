function SetDualADSBOutWithV2VUID(this::STM, target_id::UInt32, track::TrackFile)
target::Target = this.target_db[target_id]
if isa(track, V2VTrackFile) || (isa(track, AGTTrackFile) && track.v2v_uid_valid)
dual_ADSB_OUT = (EQUIPMENT_ADSB_1090ES_OUT | EQUIPMENT_ADSB_UAT_OUT)
dual_adsb_out_with_v2v_uid = ((target.v2v_osm.equipment & dual_ADSB_OUT) == dual_ADSB_OUT)
else
dual_adsb_out_with_v2v_uid = false
end
track.trk_summary.dual_adsb_out_with_v2v_uid = dual_adsb_out_with_v2v_uid
end
