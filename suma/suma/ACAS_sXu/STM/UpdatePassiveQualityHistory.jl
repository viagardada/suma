function UpdatePassiveQualityHistory(this::STM, trk::TrackFile)
if (isa(trk, ADSBTrackFile))
min_nic = this.params["surveillance"]["report_generation"]["min_adsb_quality"]["nic"]
min_nacp = this.params["surveillance"]["report_generation"]["min_adsb_quality"]["nacp"]
min_nacv = this.params["surveillance"]["report_generation"]["min_adsb_quality"]["nacv"]
min_sil = this.params["surveillance"]["report_generation"]["min_adsb_quality"]["sil"]
min_sda::UInt32 = this.params["surveillance"]["report_generation"]["min_adsb_quality"]["sda"]
min_adsb_version = this.params["surveillance"]["report_generation"]["min_adsb_quality"]["adsb_version"]
N = this.params["surveillance"]["report_generation"]["min_adsb_quality"]["N"]
update_quality = ((trk.nic >= min_nic) && (trk.nacp >= min_nacp) && (trk.nacv >= min_nacv) && (trk.sil >= min_sil) && (trk.adsb_version >= min_adsb_version) && (trk.sda >= min_sda))
elseif (isa(trk, V2VTrackFile))
min_nic = this.params["surveillance"]["report_generation"]["min_v2v_quality"]["nic"]
min_nacp = this.params["surveillance"]["report_generation"]["min_v2v_quality"]["nacp"]
min_nacv = this.params["surveillance"]["report_generation"]["min_v2v_quality"]["nacv"]
min_sil = this.params["surveillance"]["report_generation"]["min_v2v_quality"]["sil"]
min_sda = this.params["surveillance"]["report_generation"]["min_v2v_quality"]["sda"]
N = this.params["surveillance"]["report_generation"]["min_v2v_quality"]["N"]
update_quality = ((trk.nic >= min_nic) && (trk.nacp >= min_nacp) && (trk.nacv >= min_nacv) && (trk.sil >= min_sil) && (trk.sda >= min_sda))
end
if (length(trk.passive_qual_history) >= N)
pop!(trk.passive_qual_history)
end
pushfirst!(trk.passive_qual_history,update_quality)
end
