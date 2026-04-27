# 引入必要的模块
using JSON

# 加载 ACAS sXu 所需的基础别名和结构库
include("ACAS_sXu/Aliases.jl")
include("ACAS_sXu/DataStructures/RDataTable.jl")
include("ACAS_sXu/DataTableFormatSpecification/LoadDataTables.jl")

# 指定你要查看的 .dat 文件路径 (请替换成你想看的具体的 .dat 文件名)
dat_file_path = "ACAS_sXu/LookupTables/DO-396_entry_sxuvtrm_compressed.dat"

# 1. 调用解析器加载数据
tables = LoadDataTables(dat_file_path)

# 表通常被读取为一个数组，取第一个表
my_table = tables[1]

# 2. 打印表的基本结构和物理含义，看看这个表到底存了什么
println("该表的维度名称: ", my_table.cut_names)
println("每个维度的网格数量: ", my_table.cut_counts)

# 打印出前几个维度的网格切分点（相当于坐标轴上的刻度）
# 注意：my_table.cuts 存了一维化的所有坐标轴刻度，切分要靠 cut_counts
println("坐标点数组总长度: ", length(my_table.cuts))

# 数据体大小
println("压缩数据总量 (Float16): ", length(my_table.data))