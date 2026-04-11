function WrapTo2Pi( phi::R )
phi_out::R = WrapToPi( phi )
if ( phi_out < 0.0)
phi_out = phi_out + 2pi
end
phi_out = max( 0.0, phi_out )
phi_out = min( 2pi, phi_out )
return phi_out::R
end
