function ReceiveModeStatusReport(this::STM, adsb_version::UInt32, nacp::UInt32, nacv::UInt32, gva::UInt32, sil::UInt32,sda::UInt32, mode_s::UInt32, is_uat::Bool, non_icao::Bool)
id = AssociateADSBReportToTarget(this, mode_s, non_icao)
if (id != NO_TARGET_FOUND)
tgt = RetrieveWithID(this.target_db, id)
trk = tgt.adsb_track
if (trk.uat == is_uat)
trk.adsb_version = adsb_version
trk.nacp = nacp
trk.nacv = nacv
trk.gva = gva
trk.sil = sil
trk.sda = sda
UpdatePassiveQualityHistory(this, trk)
end
end
end
