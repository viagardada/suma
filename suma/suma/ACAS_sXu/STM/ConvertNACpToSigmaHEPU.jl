function ConvertNACpToSigmaHEPU(NACp::UInt32)
epu::R = 18520
if (NACp == 2)
epu = 7408
elseif (NACp == 3)
epu = 3704
elseif (NACp == 4)
epu = 1852
elseif (NACp == 5)
epu = 926
elseif (NACp == 6)
epu = 555.6
elseif (NACp == 7)
epu = 185.2
elseif (NACp == 8)
epu = 92.6
elseif (NACp == 9)
epu = 30
elseif (NACp == 10)
epu = 10
elseif (NACp == 11)
epu = 3
end
sigma_hepu = epu/2.448
return sigma_hepu::R
end
