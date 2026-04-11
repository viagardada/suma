mutable struct Database{K,V}
increment::K
dictionary::Dict{K,V}
Database{K,V}(i::K) where {K,V} = new(i, Dict{K,V}())
end
Base.delete!(db::Database, k) = Base.delete!(db.dictionary, k)
Base.get(db::Database, k, default) = Base.get(db.dictionary, k, default)
Base.getindex(db::Database, k) = Base.getindex(db.dictionary, k)
Base.haskey(db::Database, k) = Base.haskey(db.dictionary, k)
Base.keys(db::Database) = Base.sort(Base.collect(Base.keys(db.dictionary)))
Base.setindex!(db::Database, v, k) = Base.setindex!(db.dictionary, v, k)
