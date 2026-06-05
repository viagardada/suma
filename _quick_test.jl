println("Julia version: ", VERSION)
println("Step 1: Loading ACAS_sXu...")
include("suma/suma/ACAS_sXu/ACAS_sXu.jl")
println("Step 2: Using ACAS_sXu...")
using .ACAS_sXu
println("Step 3: Loading params...")
params_file = "D:/workforce/project/suma/suma/suma/LookupTables/DO-396_paramsfile_acassxu_origami_20220908.txt"
println("Step 4: Creating STM...")
stm = ACAS_sXu.STM(params_file)
println("Step 5: STM created successfully!")