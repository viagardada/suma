function ExtrapolateAGTTrack(this::STM, trk::AGTTrackFile, T::R)
m2ft::R = geoutils.meters_to_feet
lag_uncertainty::R = this.params["surveillance"]["agt"]["lag_uncertainty_minimum"]
avg_range_window::Z = this.params["surveillance"]["correlation"]["ownship_correlation"]["average_range"]["window"]
I_rng_az::Vector{Z} = [1, 3]
I_xy::Vector{Z} = [1, 3]
TS::TrackSummary = trk.trk_summary
mu_vert::Vector{R} = copy(trk.mu_vert)
Sigma_vert::Matrix{R} = copy(trk.Sigma_vert)
mu_ra::Vector{R} = zeros(4)
Sigma_ra::Matrix{R} = zeros(4,4)
dt::R = T - trk.toa
is_large::Bool = (trk.classification != CLASSIFICATION_SMALL_UNMANNED)
(TS.mu_vert, TS.Sigma_vert) = PredictVerticalTracker(this, mu_vert, Sigma_vert, dt, trk.alt_src_hae, false,is_large)
TS.alt_src_hae = trk.alt_src_hae
trk_temp = deepcopy(trk)
(trk_temp.mu_hor, trk_temp.Sigma_hor) = PredictPassiveTracker(this, trk_temp.mu_hor, trk_temp.Sigma_hor, dt,false)
ReCenterHorizontalTrackLocation(trk_temp, T)
(mu_xy_meters, Sigma_xy_meters) = AbsoluteGeodeticToOwnshipRelative(this, trk_temp)
Sigma_xy_meters[1,1] = max(Sigma_xy_meters[1,1], lag_uncertainty^2)
Sigma_xy_meters[3,3] = max(Sigma_xy_meters[3,3], lag_uncertainty^2)
mu_xy = mu_xy_meters * m2ft
Sigma_xy = Sigma_xy_meters * (m2ft^2)
(mu_ra, Sigma_ra) = ConvertCartesianToPolar2D(this, mu_xy, Sigma_xy)
TS.mu_rng_az = mu_ra[I_rng_az]
TS.Sigma_rng_az = Sigma_ra[I_rng_az,I_rng_az]
TS.mu_range = mu_ra[1:2]
TS.Sigma_range = Sigma_ra[1:2,1:2]
TS.valid_rng = true
TS.valid_vert = trk.valid_vert
if (this.own.wgs84_state != OWN_WGS84_INVALID)
z_rel = GetRelativeAltitude(this, TS.mu_vert[1], TS.alt_src_hae)
xyz_rel = [mu_xy[I_xy]; z_rel]
N_avg = trk.avg_counts
trk.avg_xyz_rel = (trk.avg_xyz_rel * N_avg + xyz_rel) / (N_avg + 1)
if (N_avg < avg_range_window)
trk.avg_counts += 1
end
end
end
