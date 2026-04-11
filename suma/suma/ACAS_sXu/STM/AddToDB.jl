function AddToDB(db::Database{K,V}, v::V) where {K,V}
db.increment += 1
while haskey(db, db.increment)
db.increment += 1
end
db[db.increment] = v
return db::Database{K,V}
end
