function GetVerticalOutlierParams(this::STM, trk::Union{ADSBTrackFile, V2VTrackFile}, is_large::Bool)
vertical = this.params["surveillance"]["vertical"]
if trk.alt_src_hae
if is_large
outlier_thresh::R = vertical["hae_large_intruder"]["outlier_threshold"]
max_outliers_normal::Z = vertical["hae_large_intruder"]["max_outlier_detections"]
else
outlier_thresh = vertical["hae_small_intruder"]["outlier_threshold"]
max_outliers_normal = vertical["hae_small_intruder"]["max_outlier_detections"]
end
else
if is_large
outlier_thresh = vertical["pres_large_intruder"]["outlier_threshold"]
max_outliers_normal = vertical["pres_large_intruder"]["max_outlier_detections"]
else
outlier_thresh = vertical["pres_small_intruder"]["outlier_threshold"]
max_outliers_normal = vertical["pres_small_intruder"]["max_outlier_detections"]
end
end
max_outliers::Z = max_outliers_normal
return (outlier_thresh::R, max_outliers::Z)
end
