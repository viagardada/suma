# 原生 sUMA 状态表扩充

`expand_native_table.py` 与 `native_grid_sampler.jl` 使用仓库原生 STM/TRM 和
DO-396 查找表采样；不使用近邻动作代替算法结果。Python 只负责场景网格和统计。

## 场景与采样

八维初始条件独立遍历：距离、相对高度、相对方位、相对航向、入侵机速度、
本机速度、本机垂直速度、入侵机垂直速度。沿用原表档位，角度统一为
`-180:30:150`。原始网格有 1,107,319,248 个组合，不能把首批采样视为穷尽覆盖。
确定性置换把分批采样分散到整个网格，支持按 start/count 最终遍历所有组合。

每个场景使用新的 STM 跟踪数据库和 TRM 状态，复用只读算法参数和大查找表。
本机向北，基准高度 10,000 ft，双方按恒速度飞行，不执行建议；这用于采集策略，
不构成避让执行后安全性的验证。目标是无协同意图的已验证 V2V 入侵机。
本机性能参数固定为转弯率 0.053 rad/s、垂直性能 16.667 ft/s。
这些上下文未进入九维键，因此表格不是任意机型/传感器/历史条件下的通用策略。

初始状态定义在预热结束时刻；向前回推 10 秒构造跟踪历史，随后每秒完整输入所有
传感器消息，再生成 STM 报告和 TRM 建议。记录 t=0 至 20 秒的每个真实跟踪状态和
同一时刻的联合动作（包括无建议）。所有场景都经过相同预热长度，没有随机测量噪声。

τ 使用相对水平速度沿视线的投影计算：`-range / radial_velocity`；
不接近时为 -1，不单独遍历。本机实际垂直速度读取 `own.belief_vert[].dz`，
不能用表示机动性能的 `effective_vert_rate` 代替。旧 `probe_table.jl` 这两处
提取存在问题，因此旧样本不应等同于经过新采样器验证的样本。

经纬度通过赤道附近 WGS84 局部切平面近似生成；状态键使用 STM 实际估计结果，
不强行把结果写成预设初始状态。远距离及离散边界附近可能落入相邻档位。

## 运行

在仓库根目录执行（Windows 上使用实际 Python/Julia 解释器路径）：

```powershell
python suma/expand_native_table.py prepare --work suma/output/native_expansion_v2 --count 1024 --focus
python suma/expand_native_table.py run --work suma/output/native_expansion_v2 --julia D:/workforce/Julia/bin/julia.exe
python suma/expand_native_table.py validate --work suma/output/native_expansion_v2
python suma/expand_native_table.py merge --work suma/output/native_expansion_v2
```

`--focus` 额外添加 540 个场景：近距离九个档位、五个对比高度、十二个方位，
相对航向 -180°、两机速度 200 fps、两机垂直速度 0。它是全八维采样的补充。

继续下一批：

```powershell
python suma/expand_native_table.py prepare --work suma/output/native_expansion_v2 --start 1024 --count 4096
python suma/expand_native_table.py run --work suma/output/native_expansion_v2 --julia D:/workforce/Julia/bin/julia.exe
python suma/expand_native_table.py validate --work suma/output/native_expansion_v2
python suma/expand_native_table.py merge --work suma/output/native_expansion_v2 --install
```

每完成一个场景即追加并 flush 到 JSONL。重跑自动跳过已完成场景。
合并使用 SQLite 事务和场景 ID 去重，重复 merge 不会重复计票。
若掉电产生末行不完整的 JSONL，应先保留损坏文件再修复末行，解析失败不会静默跳过。

## 文件与合并约定

- `manifest.json`：网格、置换、时长、预热和固定上下文。
- `cases.jsonl`：所有已安排的八维初始状态。
- `native_samples.jsonl`：逐场景的连续状态和原生 H/V 输出，审计依据。
- `counts.sqlite`：每个状态的联合动作累计次数和已合并场景 ID。
- `native_joint_actions.csv`：全部原生动作计数、占比和并列众数标志。
- `expanded_table.csv`：与原表格式兼容的候选结果。
- `coverage_report.json`：新增/更新状态数、冲突、覆盖指标和采样器哈希。
- `validation_report.json`：逐帧时刻/动作编码、τ 独立复算、各轴档位覆盖和重复场景校验。

原生联合动作众数覆盖旧表的同键动作，保留未采样到的旧键；旧数据来源未知，
不声称全部是原生或全部是近邻数据。并列时按 H/V 数字顺序确定输出，并在审计表
明确标注；高冲突状态应复查跟踪历史，不能认为九维键能表达全部内部记忆。
命令 `merge --install` 先按旧文件哈希备份，再原子替换默认 CSV。
±180° 的方位/航向视为同一物理方向，旧表的角度别名重复行按联合动作众数归并；
报告同时给出原始行数、归并后的状态数及别名动作冲突数。

图面完整性应在纳入无建议记录时评估。选择隐藏 H:0|V:0 会使已有样本的格子仍为空白；当前绘图默认纳入这些记录。
报告中的默认切片覆盖统计包括安全记录，并按距离/高度/方位去重，不等于九维全覆盖。

验证：`python suma/test_expand_native_table.py -v`。

## 优先补近距离冲突与覆盖缺口

`priority_native_cases.py` 在原始网格中限定距离不超过 3,000 ft、相对高度绝对值
不超过 1,000 ft。对随机候选做恒速相对运动 CPA 外推，仅选未来 20 秒内接近的组合。
约 90% 为水平 CPA≤500 ft 且同一时刻高度差≤200 ft 的潜在冲突，另外约 10%
为水平 CPA≤1,200 ft、高度差≤600 ft 的边界样本。这些是场景筛选启发值，
不是原生 ACAS 告警阈值，也不表示一定会发生实际碰撞。

筛选同时跳过已有初始场景，优先表格尚未覆盖的位置/航向/速度比投影以及未被原生采样
的八维状态，并轮流从不同方位/航向组中取样。入侵者机头方向依然是独立维度。
CPA 只负责选择场景，标签仍由原生 STM/TRM 逐时刻计算。

```powershell
python suma/priority_native_cases.py plan --count 1536 --pool 100000
python suma/expand_native_table.py run --work suma/output/native_expansion_v2 --julia D:/workforce/Julia/bin/julia.exe
python suma/expand_native_table.py validate --work suma/output/native_expansion_v2
python suma/expand_native_table.py merge --work suma/output/native_expansion_v2 --install
python suma/priority_native_cases.py assess
```

场景追加到同一工作目录，原生动作计数跨批次累计，已完成场景不会重复运行。
`priority_*_baseline.csv` 保留本批次开始前的表格；`priority_*_plan.json` 保存
候选种子、所选场景 ID、筛选条件；`priority_*_result.json` 比较扩充前后的覆盖。
覆盖统计同时给出整个近距离高度范围，以及五个对比高度在所有航向/速度比下的位置格。
若候选不足，可增加 `--pool` 或调整 `--seed`，不会退回近邻补动作。

大批量时，选择器优先让不同场景补充不同的位置/高度/航向/速度比格子；只有不同格子
不足时，才增加同一格子的绝对速度及垂直率组合。运行多个隔离的 Julia 进程可加速：

```powershell
python suma/priority_native_cases.py plan --count 10000 --pool 1000000 --seed 20261018
python suma/run_native_workers.py --workers 3 --julia D:/workforce/Julia/bin/julia.exe
python suma/expand_native_table.py validate
python suma/expand_native_table.py merge --install
python suma/priority_native_cases.py assess
```

每个进程有独立的状态、样本文件和日志，只共享读取算法代码与查找表。`workers_3/`
保存分片检查点；重启相同命令会跳过已完成场景。协调器在检查所有预期场景完成后，
按 ID 去重追加到累计样本。合并统计仍由主流程串行执行，避免 SQLite/CSV 并发写入。
每个 Julia 进程约需数 GB 内存，应根据机器资源选择进程数。

## 定点补齐 1000 ft 内圈

`fill_inner_ring.py` 检查六个距离档位（100/200/300/400/500/1000 ft）、五个显示高度、
全部方位/航向及 35 种速度比，共 151,200 个图格、2,100 个高度/航向/速度比切片。
只给缺失图格生成场景；不区分是否接近，因此能补上合理的无建议记录。
每个速度比选择表中一组真实绝对速度，两机垂直率取 0，保留独立的 `ring_1000/`
工作目录和原表快照。它补齐显示投影，不声称补齐每个绝对速度/垂直率/τ 组合。

仍完整运行 10 秒原生 STM/TRM 预热，只采集 t=0 目标状态，不继续执行后面 20 秒。
短查询与之前长轨迹在 t=0 的状态和动作必须一致；额外检查估计状态离散化后确实
落在指定图格，而不直接用初始设定值充当算法观测。

```powershell
python suma/fill_inner_ring.py plan
python suma/run_native_workers.py --work suma/output/ring_1000 --workers 4 --julia D:/workforce/Julia/bin/julia.exe
python suma/expand_native_table.py validate --work suma/output/ring_1000
python suma/fill_inner_ring.py verify_targets
python suma/expand_native_table.py merge --work suma/output/ring_1000 --install
python suma/fill_inner_ring.py audit
```

完成后仍有缺口时，重新 plan 仅追加未安排的缺口；`target_verification.json`
保留估计值落入相邻格的异常，以供针对性修复。最终按真实 CSV 而非计划数验收。
图形默认包含无建议记录，按 A 或 `--avoid-only` 可隐藏；隐藏后的空白不能作为
采样覆盖率。最小 100-ft 档的扇环延伸至圆心，与离散器最小距离夹持规则一致。

绘图的 H/V 输出使用联合动作众数，不再把两个方向的独立众数拼成未出现过的动作组合。
内圈工作目录从前序 counts.sqlite 复制原生动作计数，保留累计投票及其来源快照元数据。
