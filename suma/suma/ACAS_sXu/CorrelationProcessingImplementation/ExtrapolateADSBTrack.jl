function ExtrapolateADSBTrack(this::STM, trk::ADSBTrackFile, T::R)
m2ft::R = geoutils.meters_to_feet
I_rng_az::Vector{Z} = [1, 3]
TS::TrackSummary = trk.trk_summary
mu_vert::Vector{R} = copy(trk.mu_vert)
Sigma_vert::Matrix{R} = copy(trk.Sigma_vert)
mu_ra::Vector{R} = zeros(4)
Sigma_ra::Matrix{R} = zeros(4,4)
dt_vert = T - trk.toa_vert
dt_hor = T - trk.toa_hor
(TS.mu_vert, TS.Sigma_vert) = PredictVerticalTracker(this, mu_vert, Sigma_vert, dt_vert, trk.alt_src_hae,false, true)
TS.alt_src_hae = trk.alt_src_hae
trk_temp = deepcopy(trk)
(trk_temp.mu_hor, trk_temp.Sigma_hor) = PredictPassiveTracker(this, trk_temp.mu_hor, trk_temp.Sigma_hor,dt_hor, false)
ReCenterHorizontalTrackLocation(trk_temp, T)
(mu_xy_meters, Sigma_xy_meters) = AbsoluteGeodeticToOwnshipRelative(this, trk_temp)
mu_xy = mu_xy_meters * m2ft
Sigma_xy = Sigma_xy_meters * (m2ft^2)
(mu_ra, Sigma_ra) = ConvertCartesianToPolar2D(this, mu_xy, Sigma_xy)
TS.mu_rng_az = mu_ra[I_rng_az]
TS.Sigma_rng_az = Sigma_ra[I_rng_az,I_rng_az]
TS.mu_range = mu_ra[1:2]
TS.Sigma_range = Sigma_ra[1:2,1:2]
TS.valid_rng = true
TS.valid_vert = trk.valid_vert
end
