# -*- coding: utf-8 -*-
"""
密集化查询表静态图集 (方案 A)
================================
读取 my_lightweight_table_dense.csv (89,853 条规则, 21 种 H×V 动作组合),
输出 6 类 PNG 决策面图至 output/dense_visuals/:

  01_action_distribution.png    动作组合分布条形图 (H:0|V:0 高亮)
  02_h_range_bearing.png        水平决策面: Range×Bearing 全景, 按 Rel_Alt 分层, 颜色=水平动作
  03_v_core_bearing.png         垂直决策面(核心区): Range×Rel_Alt, 按 Bearing 分层
  04_v_core_heading.png         垂直决策面(核心区): Range×Rel_Alt, 按 Rel_Heading 分层
  05_v_core_tau.png             τ敏感性(核心区): Range×Rel_Alt, 按 Tau 分层
  06_v_far_bearing.png          垂直决策面(远距区): Range×Rel_Alt, 按 Bearing 分层

设计说明:
- 9 维状态空间无法整体平铺, 采用"投影 2D + 固定关键维度 + 聚合次要维度"降维:
    * 投影维度: 图上两轴
    * 层维度(layer): 一图多子图, 每个子图固定一个层值
    * 固定维度: 保留明确物理语义 (如 heading=180° 对头接近、tau=5s)
    * 聚合维度: 速度/垂直率等, 对网格单元取动作众数, 并叠加"分歧点"标记
- 白点标记 = 该网格单元内动作一致性 <60% (决策分歧区)
- 核心区 = Range 100~3000 ft 且 |Rel_Alt| ≤ 1000 ft (density_lookup_table.py 的
  MAX_RANGE/MAX_ALT), 即密集化孔洞填充的成果区域
- 远距区在 ±120°~±180° (前/后向扇区) 规则密集, 侧向几乎无规则 (数据真实特性)

运行: D:\\workforce\\anaconda\\python.exe suma\\visualize_dense.py
"""

import csv
import os
from collections import Counter, defaultdict

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap, BoundaryNorm
from matplotlib.patches import Patch

plt.rcParams['font.sans-serif'] = ['SimHei', 'Microsoft YaHei', 'Arial Unicode MS']
plt.rcParams['axes.unicode_minus'] = False

BASE = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(BASE, "my_lightweight_table_dense.csv")
OUT_DIR = os.path.join(BASE, "output", "dense_visuals")

# ---- 动作命名与配色 ----
H_NAMES = {0: "NO ADVISORY(安全)", 1: "CLEAR(解除)", 2: "TURN RIGHT(右转)",
           3: "TURN LEFT(左转)", 4: "STRAIGHT(直飞)"}
V_NAMES = {0: "NO ADVISORY(安全)", 1: "CLEAR(解除)", 2: "DO NOT CLIMB(禁爬升)",
           3: "DO NOT DESCEND(禁下降)", 4: "CLIMB(爬升)", 5: "DESCEND(下降)",
           6: "XC CLIMB(交叉爬升)", 7: "XC DESCEND(交叉下降)"}
H_COLORS = ["#9E9E9E", "#66BB6A", "#EF5350", "#AB47BC", "#42A5F5"]
V_COLORS = ["#9E9E9E", "#66BB6A", "#FFEE58", "#26C6DA",
            "#EF5350", "#42A5F5", "#FFA726", "#AB47BC"]

# ---- 离散 bin (与数据实际取值一致) ----
# 核心区: Range 100~500(步长100) / 1000~2000(步长500) / 3000
CORE_RANGE_BINS = [100, 200, 300, 400, 500, 1000, 1500, 2000, 3000]
# 远距区: 4000~47000(步长1000)
FAR_RANGE_BINS = list(range(4000, 47001, 1000))
# 全景: 两者拼接, 与数据 53 个取值一一对应
FULL_RANGE_BINS = CORE_RANGE_BINS + FAR_RANGE_BINS
CORE_ALT_BINS = list(range(-1000, 1001, 100))          # -1000 ~ +1000, 21 格
FULL_ALT_BINS = list(range(-2400, 2301, 100))          # -2400 ~ +2200, 47 格
BRG_BINS = list(range(-180, 181, 30))                  # -180 ~ +180, 13 格
HDG_BINS = list(range(-180, 181, 30))                  # -180 ~ +180, 13 格

# 刻度索引
CORE_R_TICK_IDX = [0, 4, 5, 7, 8]                      # 100/500/1000/2000/3000
FAR_R_TICK_IDX = [0, 4, 9, 19, 29, 39, 43]             # 4000/5000/10000/20000/...
FULL_R_TICK_IDX = [0, 4, 5, 7, 8, 12, 22, 32, 42, 52]  # 100/500/1000/2000/3000/...
CORE_ALT_TICK_IDX = [0, 5, 10, 15, 20]                 # -1000/-500/0/500/1000
FULL_ALT_TICK_IDX = [0, 4, 14, 24, 34, 44, 46]
BRG_TICK_IDX = list(range(0, 13, 2))                   # 每 60°
HDG_TICK_IDX = list(range(0, 13, 2))                   # 每 60°

BRG_NAME = {-180: "尾随 -180°", -150: "左后 -150°", -120: "左后 -120°",
            -90: "左侧 -90°", -60: "左前 -60°", -30: "左前 -30°",
            0: "正前方 0°", 30: "右前 30°", 60: "右前 60°",
            90: "右侧 90°", 120: "右后 120°", 150: "右后 150°", 180: "尾随 180°"}
HDG_NAME = {-180: "对头 -180°", -90: "左交叉 -90°", 0: "同向 0°",
            90: "右交叉 90°", 180: "尾随 180°"}
TAU_NAME = {-1.0: "远离中(τ<0)", 5.0: "τ=5s 紧迫", 10.0: "τ=10s", 15.0: "τ=15s"}

# 列索引
C_R, C_A, C_B, C_H, C_IS, C_OS, C_OV, C_IV, C_T, C_HC, C_VC = range(11)


def parse_hv(s):
    try:
        h = int(s.split("|")[0].split(":")[1].strip())
        v = int(s.split("|")[1].split(":")[1].strip())
        return h, v
    except Exception:
        return 0, 0


def load_data():
    rows = []
    with open(CSV_PATH, encoding='utf-8') as f:
        for r in csv.DictReader(f):
            h, v = parse_hv(r['Recommended_Action'])
            rows.append((float(r['Range(ft)']), float(r['Rel_Altitude(ft)']),
                         float(r['Bearing(deg)']),
                         float(r['Rel_Heading(deg)']),
                         float(r['Intruder_Speed(fps)']), float(r['Own_Speed(fps)']),
                         float(r['Own_Vert_Rate(fps)']), float(r['Int_Vert_Rate(fps)']),
                         float(r['Tau(s)']), h, v))
    return np.array(rows, dtype=np.float64)


def build_grid(arr, mask, x_col, y_col, x_bins, y_bins, code_col):
    """在 (x_bins, y_bins) 网格上聚合动作众数。

    返回 (grid, frac):
      grid[iy,ix] = 该 cell 的众数动作码 (-1 表示无数据)
      frac[iy,ix] = 众数动作占比 (一致性, 0~1)
    """
    xs, ys = arr[mask, x_col], arr[mask, y_col]
    cs = arr[mask, code_col].astype(int)
    xmap = {v: i for i, v in enumerate(x_bins)}
    ymap = {v: i for i, v in enumerate(y_bins)}
    cell = defaultdict(Counter)
    for x, y, c in zip(xs, ys, cs):
        xi, yi = xmap.get(x), ymap.get(y)
        if xi is None or yi is None:
            continue
        cell[(xi, yi)][c] += 1
    grid = np.full((len(y_bins), len(x_bins)), -1, dtype=int)
    frac = np.zeros_like(grid, dtype=float)
    for (xi, yi), cnt in cell.items():
        top_code, top_n = cnt.most_common(1)[0]
        total = sum(cnt.values())
        grid[yi, xi] = top_code
        frac[yi, xi] = top_n / total
    return grid, frac


def draw_heat(ax, grid, frac, x_bins, y_bins, x_tick_idx, y_tick_idx,
              cmap, norm, title, ylabel, xlabel="Range (ft)"):
    masked = np.ma.masked_where(grid < 0, grid)
    ax.set_facecolor("#F5F5F5")  # 无数据格浅灰
    ax.imshow(masked, cmap=cmap, norm=norm, origin='lower', aspect='auto',
              extent=[-0.5, len(x_bins) - 0.5, -0.5, len(y_bins) - 0.5],
              interpolation='nearest')
    # 分歧点: 该格众数占比 < 60%
    yi, xi = np.where((grid >= 0) & (frac < 0.60))
    if len(xi):
        ax.scatter(xi, yi, marker='o', s=7, c='white', edgecolors='black',
                   linewidths=0.4, zorder=5)
    ax.set_xticks(x_tick_idx)
    ax.set_xticklabels([str(x_bins[i]) for i in x_tick_idx], fontsize=8)
    ax.set_yticks(y_tick_idx)
    ax.set_yticklabels([str(y_bins[i]) for i in y_tick_idx], fontsize=8)
    ax.set_xlabel(xlabel, fontsize=10)
    ax.set_ylabel(ylabel, fontsize=10)
    ax.set_title(title, fontsize=11, fontweight='bold')


def add_legend(ax, codes_present, names, colors, loc='upper right'):
    handles = [Patch(facecolor=colors[c], edgecolor='gray', linewidth=0.5,
                     label=f"{c}: {names[c]}") for c in sorted(codes_present)]
    ax.legend(handles=handles, loc=loc, fontsize=7, framealpha=0.92,
              handlelength=1.2, borderaxespad=0.3)


def add_footnote(fig, text, y=0.005, size=8):
    fig.text(0.5, y, text, ha='center', va='bottom', fontsize=size,
             color='#555555')


# ---------------- 01 动作分布 ----------------
def plot_distribution(arr):
    cnt = Counter(zip(arr[:, C_HC].astype(int), arr[:, C_VC].astype(int)))
    items = sorted(cnt.items(), key=lambda kv: -kv[1])
    total = len(arr)
    labels = []
    for (h, v), _ in items:
        labels.append(f"H:{h}|V:{v}   {H_NAMES[h]} / {V_NAMES[v]}")
    vals = [c for _, c in items]
    ypos = np.arange(len(items))
    colors = ['#FF9800' if (h == 0 and v == 0) else '#42A5F5' for (h, v), _ in items]

    fig, ax = plt.subplots(figsize=(10, 8.5))
    ax.barh(ypos, vals, color=colors, edgecolor='white')
    ax.set_yticks(ypos)
    ax.set_yticklabels(labels, fontsize=8.5)
    ax.invert_yaxis()
    for i, v in enumerate(vals):
        ax.text(v + total * 0.012, i, f"{v:,}  ({v / total * 100:.1f}%)",
                va='center', fontsize=8.5)
    ax.set_xlabel("规则条数", fontsize=11)
    ax.set_title(f"密集化查询表动作组合分布 — 共 {total:,} 条规则 / {len(items)} 种组合",
                 fontsize=13, fontweight='bold')
    ax.grid(axis='x', linestyle='--', alpha=.4)
    ax.legend(handles=[Patch(facecolor='#FF9800', label='安全态 H:0|V:0 (居多数)'),
                       Patch(facecolor='#42A5F5', label='含机动建议')],
              loc='lower right', fontsize=9)
    fig.tight_layout()
    fig.savefig(os.path.join(OUT_DIR, '01_action_distribution.png'), dpi=150)
    plt.close(fig)
    print("  01_action_distribution.png")


# ---------------- 通用决策面子图绘制 ----------------
def plot_heat_layers(arr, fname, x_col, y_col, x_bins, y_bins, code_col,
                     layers, layer_col, layer_names, cmap, norm, names, colors,
                     fixed_txt, x_tick_idx, y_tick_idx, ylabel, fig_cols=3,
                     per_title=None, figsize=None, subplot_w=4.4, subplot_h=4.2,
                     footnote=None):
    n = len(layers)
    cols = min(fig_cols, n)
    rows = int(np.ceil(n / cols))
    if figsize is None:
        figsize = (subplot_w * cols + 3.5, subplot_h * rows + 1.5)
    fig, axes = plt.subplots(rows, cols, figsize=figsize)
    axes = np.atleast_1d(axes).ravel()
    for idx, lv in enumerate(layers):
        ax = axes[idx]
        mask = arr[:, layer_col] == lv
        grid, frac = build_grid(arr, mask, x_col, y_col, x_bins, y_bins, code_col)
        title = per_title(lv) if per_title else f"{layer_names.get(lv, lv)}"
        draw_heat(ax, grid, frac, x_bins, y_bins, x_tick_idx, y_tick_idx,
                  cmap, norm, title, ylabel)
        codes_present = set(grid[grid >= 0].tolist())
        add_legend(ax, codes_present, names, colors)
        total, n_occ = grid.size, int((grid >= 0).sum())
        print(f"    {fname} 层={lv}: 有效格 {n_occ}/{total} ({n_occ / total * 100:.0f}%)")
    for ax in axes[n:]:
        ax.axis('off')
    fig.suptitle(fixed_txt, fontsize=12, fontweight='bold', y=0.995)
    note = footnote or "白点 = 该网格单元动作一致性<60% (决策分歧区) | 灰色 = 无数据"
    add_footnote(fig, note)
    fig.subplots_adjust(top=0.88, bottom=0.07, left=0.075, right=0.985,
                        hspace=0.55, wspace=0.55)
    fig.savefig(os.path.join(OUT_DIR, fname), dpi=150)
    plt.close(fig)
    print(f"  {fname}")


# ---------------- 02 水平决策面 (全景) ----------------
def plot_h_range_bearing(arr):
    cmap = ListedColormap(H_COLORS)
    norm = BoundaryNorm([-0.5 + i for i in range(5)], cmap.N)
    layers = [-300.0, 0.0, 300.0]

    def per_title(alt):
        return f"水平决策面  Rel_Alt={alt:+.0f} ft"

    plot_heat_layers(
        arr, '02_h_range_bearing.png', C_R, C_B, FULL_RANGE_BINS, BRG_BINS, C_HC,
        layers, C_A, {}, cmap, norm, H_NAMES, H_COLORS,
        "水平决策面: Range × Bearing 全景 (颜色 = 水平动作)\n"
        "固定: 对头接近(Rel_Heading=180°) | τ=5s | 聚合: 双机速度/垂直率取众数",
        FULL_R_TICK_IDX, BRG_TICK_IDX, "Bearing (°, 前方=0, 左负右正) 每格30°",
        per_title=per_title, figsize=(16.5, 9.5))


# ---------------- 03 垂直决策面 (核心区, 按方位) ----------------
def plot_v_core_bearing(arr):
    cmap = ListedColormap(V_COLORS)
    norm = BoundaryNorm([-0.5 + i for i in range(8)], cmap.N)
    layers = [-180.0, -90.0, 0.0, 90.0, 180.0]

    def per_title(b):
        return f"垂直决策面  Bearing={BRG_NAME[b]}"

    plot_heat_layers(
        arr, '03_v_core_bearing.png', C_R, C_A, CORE_RANGE_BINS, CORE_ALT_BINS, C_VC,
        layers, C_B, BRG_NAME, cmap, norm, V_NAMES, V_COLORS,
        "垂直决策面(核心区 Range≤3000ft, |Alt|≤1000ft): Range × Rel_Alt (颜色 = 垂直动作) — 入侵机方位对比\n"
        "固定: 对头接近(Rel_Heading=180°) | τ=5s | 聚合: 双机速度/垂直率取众数",
        CORE_R_TICK_IDX, CORE_ALT_TICK_IDX, "Rel_Alt (ft) 每格100ft",
        per_title=per_title, figsize=(16.5, 10.5), fig_cols=3)


# ---------------- 04 垂直决策面 (核心区, 按接近几何) ----------------
def plot_v_core_heading(arr):
    cmap = ListedColormap(V_COLORS)
    norm = BoundaryNorm([-0.5 + i for i in range(8)], cmap.N)
    layers = [-180.0, -90.0, 0.0, 90.0, 180.0]

    def per_title(h):
        return f"垂直决策面  Rel_Heading={HDG_NAME[h]}"

    plot_heat_layers(
        arr, '04_v_core_heading.png', C_R, C_A, CORE_RANGE_BINS, CORE_ALT_BINS, C_VC,
        layers, C_H, HDG_NAME, cmap, norm, V_NAMES, V_COLORS,
        "垂直决策面(核心区 Range≤3000ft, |Alt|≤1000ft): Range × Rel_Alt (颜色 = 垂直动作) — 接近几何对比\n"
        "固定: 正前方(Bearing=0°) | τ=5s | 聚合: 双机速度/垂直率取众数",
        CORE_R_TICK_IDX, CORE_ALT_TICK_IDX, "Rel_Alt (ft) 每格100ft",
        per_title=per_title, figsize=(16.5, 10.5), fig_cols=3)


# ---------------- 05 τ 敏感性 (核心区) ----------------
def plot_v_core_tau(arr):
    cmap = ListedColormap(V_COLORS)
    norm = BoundaryNorm([-0.5 + i for i in range(8)], cmap.N)
    layers = [-1.0, 5.0, 10.0, 15.0]

    def per_title(t):
        return f"垂直决策面  {TAU_NAME[t]}"

    plot_heat_layers(
        arr, '05_v_core_tau.png', C_R, C_A, CORE_RANGE_BINS, CORE_ALT_BINS, C_VC,
        layers, C_T, TAU_NAME, cmap, norm, V_NAMES, V_COLORS,
        "τ 敏感性(核心区 Range≤3000ft, |Alt|≤1000ft): Range × Rel_Alt (颜色 = 垂直动作)\n"
        "固定: 正前方(Bearing=0°) | 对头(Rel_Heading=180°) | 聚合: 双机速度/垂直率取众数",
        CORE_R_TICK_IDX, CORE_ALT_TICK_IDX, "Rel_Alt (ft) 每格100ft",
        per_title=per_title, figsize=(16.5, 10.5), fig_cols=2)


# ---------------- 06 远距区垂直决策面 (按方位) ----------------
def plot_v_far_bearing(arr):
    cmap = ListedColormap(V_COLORS)
    norm = BoundaryNorm([-0.5 + i for i in range(8)], cmap.N)
    # 远距规则集中在 ±120°~±180° (前/后向扇区), 侧向几乎无规则
    layers = [-180.0, -150.0, -120.0, 120.0, 150.0, 180.0]

    def per_title(b):
        return f"远距垂直决策面  Bearing={BRG_NAME[b]}"

    plot_heat_layers(
        arr, '06_v_far_bearing.png', C_R, C_A, FAR_RANGE_BINS, FULL_ALT_BINS, C_VC,
        layers, C_B, BRG_NAME, cmap, norm, V_NAMES, V_COLORS,
        "远距区垂直决策面 (Range 4000~47000ft): Range × Rel_Alt (颜色 = 垂直动作)\n"
        "固定: 对头接近(Rel_Heading=180°) | τ=5s | 聚合: 双机速度/垂直率取众数\n"
        "注: 远距规则仅存在于前/后向扇区(±120°~±180°), 侧向视野(±30°~±90°)在远距无规则=默认安全",
        FAR_R_TICK_IDX, FULL_ALT_TICK_IDX, "Rel_Alt (ft) 每格100ft",
        per_title=per_title, figsize=(16.5, 10.5), fig_cols=3)


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    print(f"加载 {CSV_PATH} ...")
    arr = load_data()
    print(f"共 {len(arr)} 条规则")
    plot_distribution(arr)
    plot_h_range_bearing(arr)
    plot_v_core_bearing(arr)
    plot_v_core_heading(arr)
    plot_v_core_tau(arr)
    plot_v_far_bearing(arr)
    print(f"\n全部图集已输出至: {OUT_DIR}")


if __name__ == "__main__":
    main()