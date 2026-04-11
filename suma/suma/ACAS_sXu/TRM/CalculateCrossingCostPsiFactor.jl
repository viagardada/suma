function CalculateCrossingCostPsiFactor(this::TRM, psi::R)
X_crossing_psi_min::R = this.params["horizontal_trm"]["horizontal_online"]["h_crossing"]["X_crossing_psi_min"]
psi_factor::R = 0.0
psi_f_zero::R = abs(AngleDifference( 0.0, abs(psi) ))
psi_f_pi::R = abs(AngleDifference( float(pi), abs(psi) ))
if (psi_f_pi < X_crossing_psi_min)
psi_f_pi = 0.0
end
if (psi_f_zero < X_crossing_psi_min)
psi_f_zero = 0.0
end
if (psi_f_pi < psi_f_zero)
psi_factor = psi_f_pi / (pi/2.0)
else
psi_factor = psi_f_zero / (pi/2.0)
end
if (1.0 < psi_factor)
psi_factor = 1.0
elseif (psi_factor < 0.0)
psi_factor = 0.0
end
return psi_factor::R
end
