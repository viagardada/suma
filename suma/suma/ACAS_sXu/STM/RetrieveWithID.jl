function RetrieveWithID(a::Database{K,V}, k::K) where {K,V}
v = get(a, k, nothing)
return v::Target
end
