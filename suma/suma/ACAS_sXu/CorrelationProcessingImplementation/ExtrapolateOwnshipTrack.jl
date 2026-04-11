function ExtrapolateOwnshipTrack(this::STM, T::R)
m2ft::R = geoutils.meters_to_feet
I_rng_az::Vector{Z} = [1, 3]
TS::TrackSummary = this.own.trk_summary
mu_xy_meters::Vector{R} = zeros(4)
Sigma_xy_meters::Matrix{R} = copy(this.own.wgs84_Sigma_hor)
mu_ra::Vector{R} = zeros(4)
Sigma_ra::Matrix{R} = zeros(4,4)
valid_alt_pres::Bool = !isnan(this.own.toa_vert)
valid_alt_hae::Bool = !isnan(this.own.wgs84_toa_vert)
if valid_alt_pres
dt_vert = T - this.own.toa_vert
(TS.mu_vert, TS.Sigma_vert) = PredictVerticalTracker(this, this.own.mu_vert, this.own.Sigma_vert, dt_vert, false,true, false)
TS.alt_src_hae = false
TS.valid_vert = true
elseif valid_alt_hae
dt_vert = T - this.own.wgs84_toa_vert
(TS.mu_vert, TS.Sigma_vert) = PredictVerticalTracker(this, this.own.wgs84_mu_vert, this.own.wgs84_Sigma_vert,dt_vert, true, true, false)
TS.alt_src_hae = true
TS.valid_vert = true
else
TS.mu_vert = zeros(2)
TS.Sigma_vert = zeros(2, 2)
TS.valid_vert = false
end
mu_xy = mu_xy_meters * m2ft
Sigma_xy = Sigma_xy_meters * (m2ft^2)
(mu_ra, Sigma_ra) = ConvertCartesianToPolar2D(this, mu_xy, Sigma_xy)
TS.mu_rng_az = mu_ra[I_rng_az]
TS.Sigma_rng_az = Sigma_ra[I_rng_az,I_rng_az]
TS.mu_range = mu_ra[1:2]
TS.Sigma_range = Sigma_ra[1:2,1:2]
TS.valid_rng = true
TS.toa = T
TS.type = CORRELATION_TRKTYPE_INVALID
end
