function PredictedAltitude(this::STM, z::R, mu_s::Vector{R}, S::R, q::UInt32)
stability_exponent::Z = this.params["surveillance"]["vertical"]["stability_exponent"]
L::Z = this.params["surveillance"]["vertical"]["L"]
stability::R = 10.0^stability_exponent
g = zeros(L)
for i in 0:L-1
g[i+1] = (1/(2*L))*(((2*i+1)*(z+q/2))+((2*L-2*i-1)*(z-q/2)))
end
d::R = 0.0
for k in 1:L
d += exp(-0.5 * (g[k] - mu_s[1]) * inv(S) * (g[k] - mu_s[1]))
end
p = zeros(L)
if (d > stability)
for i = 1:L
p[i] = (1/d)*exp(-0.5*(g[i]-mu_s[1])*inv(S)*(g[i]-mu_s[1]))
end
mu::R = 0.0
for k in 1:L
mu += (p[k] * (g[k] - mu_s[1]))
end
Sigma::R = 0.0
for k in 1:L
Sigma += (p[k] * (g[k] - mu_s[1])^2)
end
Sigma = Sigma - mu^2
mu = mu + mu_s[1]
else
if (abs(q*round(mu_s[1]/q) - (z-q/2)) < abs(q*round(mu_s[1]/q) - (z+q/2)))
mu = z - q/2
else
mu = z + q/2
end
Sigma = 0.0
end
return (mu::R, Sigma::R)
end
