function GetOwnHeight(this::TRM, h_own::R, z_own_ave::R )
H_aglalt_limit::R = this.params["threat_resolution"]["H_aglalt_limit"]
height::R = z_own_ave
if !isnan( h_own ) && (h_own <= H_aglalt_limit)
height = h_own
end
return height::R
end
