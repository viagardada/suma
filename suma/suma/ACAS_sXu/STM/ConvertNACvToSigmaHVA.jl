function ConvertNACvToSigmaHVA(NACv::UInt32)
horiz_vel_accuracy_mps::R = 10
if (NACv == 2)
horiz_vel_accuracy_mps = 3
elseif (NACv == 3)
horiz_vel_accuracy_mps = 1
elseif (NACv == 4)
horiz_vel_accuracy_mps = 0.3
end
sigma_hva::R = horiz_vel_accuracy_mps/2.448
return sigma_hva::R
end
