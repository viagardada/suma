function eye(N::Number)
identity::Matrix{R} = diagm(0=>ones(N))
return identity::Matrix{R}
end
