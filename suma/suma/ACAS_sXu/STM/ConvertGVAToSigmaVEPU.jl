function ConvertGVAToSigmaVEPU(trk::ADSBTrackFile)
vfom_m::R = NaN
if (trk.gva == 1)
vfom_m = 150
elseif (trk.gva == 2)
vfom_m = 45
elseif (trk.adsb_version >= 3) && (trk.gva == 3)
vfom_m = 10
end
return ConvertVFOMToSigmaVEPU(vfom_m)::R
end
