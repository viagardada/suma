function WrapToPi(phi::R)
phi_out = phi
while ( phi_out > pi )
phi_out = phi_out - 2 * pi
end
while ( phi_out <= -pi )
phi_out = phi_out + 2 * pi
end
return phi_out::R
end
