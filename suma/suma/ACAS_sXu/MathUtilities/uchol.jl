function uchol(this::STM, A::Matrix{R})
psd_stability_factor::R = this.params["surveillance"]["psd_stability_factor"]
n = size(A,1)
AA = copy(A)
U = zeros(size(A))
for j in n:-1:1
if AA[j,j] < psd_stability_factor
AA[j,j] = psd_stability_factor
end
U[j,j] = sqrt(AA[j,j])
d = 1 / U[j,j]
if (j > 1)
for k in 1:j
U[j,k] = d * AA[j,k]
end
for k in 1:j
for i in 1:k
AA[k,i] -= U[j,k] * U[j,i]
end
end
end
end
return Matrix{R}(U')
end
