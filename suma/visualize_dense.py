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

# 刻度索引 (横轴为真实数值线性比例, 刻度位置=bin数值, 间距与数值差成正比)
CORE_R_TICK_IDX = [0, 4, 5, 7, 8]                      # 100/500/1000/2000/3000
FAR_R_TICK_IDX = [0, 4, 9, 19, 29, 39, 43]             # 4000/5000/10000/20000/30000/40000/47000
FULL_R_TICK_IDX = [0, 4, 5, 7, 8, 12, 22, 32, 42, 52]  # 100/500/1000/2000/3000/...
# 02 图专用: 横轴 0~17000 ft
H_RANGE_BINS = [0] + CORE_RANGE_BINS + list(range(4000, 17001, 1000))  # 0/100~3000/4000~17000
H_R_TICK_IDX = [0, 1, 5, 6, 8, 9, 11, 16, 23]  # 0/100/500/1000/2000/3000/5000/10000/17000
CORE_ALT_TICK_IDX = [0, 5, 10, 15, 20]                 # -1000/-500/0/500/1000
FULL_ALT_TICK_IDX = [0, 4, 14, 24, 34, 44, 46]
BRG_TICK_IDX = list(range(0, 13, 2))                   # 每 60°
HDG_TICK_IDX = list(range(0, 13, 2))                   # 每 60°

# 全部 Tau 离散取值 (数据实际取值, 21 个), 用于 Range×Tau 联合热力图纵轴
TAU_BINS = [-1.0, 5.0, 10.0, 15.0, 20.0, 25.0, 30.0, 35.0, 40.0,
            45.0, 50.0, 55.0, 60.0, 65.0, 70.0, 75.0, 80.0, 85.0,
            90.0, 95.0, 100.0]
# 纵轴刻度索引 (代表性 τ 取值)
TAU_TICK_IDX = [0, 1, 3, 6, 10, 14, 17]  # -1/5/15/30/50/70/85

# |Alt| 绝对高度差分箱 (数据实际取值 0~2400, 步长 100), 用于 08 号危险热力图纵轴
ALT_ABS_BINS = list(range(0, 2401, 100))  # 0~2400, 25 格
# 纵轴刻度索引 (0/500/1000/1500/2000/2400)
ALT_ABS_TICK_IDX = [0, 5, 10, 15, 20, 24]

BRG_NAME = {-180: "后方 -180°", -150: "左后 -150°", -120: "左后 -120°",
            -90: "左侧 -90°", -60: "左前 -60°", -30: "左前 -30°",
            0: "正前方 0°", 30: "右前 30°", 60: "右前 60°",
            90: "右侧 90°", 120: "右后 120°", 150: "右后 150°", 180: "后方 180°"}
HDG_NAME = {-180: "对头 -180°", -90: "左交叉 -90°", 0: "同向 0°",
            90: "右交叉 90°", 180: "同向 180°"}
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
            # 将交叉爬升(6)归并为爬升(4), 交叉下降(7)归并为下降(5)
            if v == 6:
                v = 4
            elif v == 7:
                v = 5
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


def build_ratio_grid(arr, mask, x_col, y_col, x_bins, y_bins, code_col):
    """在 (x_bins, y_bins) 网格上聚合"非安全建议占比"。

    ratio[iy,ix] = 该 cell 内动作码 != 0 的规则占比 (0~1), -1 表示无数据。
    用于 τ 敏感性分析: τ 越小 → 系统越倾向于给出机动建议 (占比越高)。
    """
    xs, ys = arr[mask, x_col], arr[mask, y_col]
    cs = arr[mask, code_col].astype(int)
    xmap = {v: i for i, v in enumerate(x_bins)}
    ymap = {v: i for i, v in enumerate(y_bins)}
    cell = defaultdict(list)
    for x, y, c in zip(xs, ys, cs):
        xi, yi = xmap.get(x), ymap.get(y)
        if xi is None or yi is None:
            continue
        cell[(xi, yi)].append(c)
    grid = np.full((len(y_bins), len(x_bins)), -1.0, dtype=float)
    for (xi, yi), codes in cell.items():
        n_adv = sum(1 for c in codes if c != 0)
        grid[yi, xi] = n_adv / len(codes)
    return grid


def build_ratio_grid_from_abs(arr, mask, x_col, y_col, x_bins, y_abs_bins, code_col):
    """在 (x_bins, y_abs_bins) 网格上聚合"非安全建议占比", 纵轴取 |y| 绝对值。

    用于 Range × |Rel_Alt| 危险热力图: 对同一高度差的正负两侧合并统计。
    """
    xs = arr[mask, x_col]
    ys = np.abs(arr[mask, y_col])
    cs = arr[mask, code_col].astype(int)
    xmap = {v: i for i, v in enumerate(x_bins)}
    ymap = {v: i for i, v in enumerate(y_abs_bins)}
    cell = defaultdict(list)
    for x, y, c in zip(xs, ys, cs):
        xi, yi = xmap.get(x), ymap.get(y)
        if xi is None or yi is None:
            continue
        cell[(xi, yi)].append(c)
    grid = np.full((len(y_abs_bins), len(x_bins)), -1.0, dtype=float)
    for (xi, yi), codes in cell.items():
        n_adv = sum(1 for c in codes if c != 0)
        grid[yi, xi] = n_adv / len(codes)
    return grid


def cell_edges(centers):
    """根据 bin 中心值生成 pcolormesh 所需的单元格边界(中点分割)。

    边界位于相邻中心的中点, 因此每个格子的宽度与离散步长成正比
    (如 0-100 与 100-500 的长度比为 1:4), 恢复真实数值线性比例。
    """
    centers = np.asarray(centers, dtype=float)
    diffs = np.diff(centers)
    edges = np.empty(len(centers) + 1)
    edges[0] = centers[0] - diffs[0] / 2.0
    edges[-1] = centers[-1] + diffs[-1] / 2.0
    edges[1:-1] = (centers[:-1] + centers[1:]) / 2.0
    return edges


def draw_heat(ax, grid, frac, x_bins, y_bins, x_tick_idx, y_tick_idx,
              cmap, norm, title, ylabel, xlabel="Range (ft)",
              show_disagreement=True):
    masked = np.ma.masked_where(grid < 0, grid)
    ax.set_facecolor("#F5F5F5")  # 无数据格浅灰
    # 按真实数值坐标绘制网格: 格子宽度与步长成正比, 未被索引等宽压缩
    x_edges = cell_edges(x_bins)
    y_edges = cell_edges(y_bins)
    ax.pcolormesh(x_edges, y_edges, masked, cmap=cmap, norm=norm,
                  shading='flat')
    ax.set_aspect('auto')
    # 分歧点: 该格众数占比 < 60% (可通过 show_disagreement=False 关闭)
    yi, xi = np.where((grid >= 0) & (frac < 0.60))
    if show_disagreement and len(xi):
        ax.scatter(np.asarray(x_bins)[xi], np.asarray(y_bins)[yi],
                   marker='o', s=7, c='white', edgecolors='black',
                   linewidths=0.4, zorder=5)
    ax.set_xticks([x_bins[i] for i in x_tick_idx])
    ax.set_xticklabels([str(x_bins[i]) for i in x_tick_idx], fontsize=8)
    ax.set_yticks([y_bins[i] for i in y_tick_idx])
    ax.set_yticklabels([str(y_bins[i]) for i in y_tick_idx], fontsize=8)
    ax.set_xlabel(xlabel, fontsize=10)
    ax.set_ylabel(ylabel, fontsize=10)
    ax.set_title(title, fontsize=11, fontweight='bold')


def draw_ratio_heat(ax, ratio_grid, x_bins, y_bins, x_tick_idx, y_tick_idx,
                    title, ylabel, xlabel="Range (ft)", note_avg=None):
    """绘制"非安全建议占比"热力图 (白→黄→红)。

    ratio_grid[iy,ix] ∈ [0,1] 为建议占比, -1 表示无数据。
    """
    masked = np.ma.masked_where(ratio_grid < 0, ratio_grid)
    ax.set_facecolor("#F5F5F5")  # 无数据格浅灰
    x_edges = cell_edges(x_bins)
    y_edges = cell_edges(y_bins)
    mesh = ax.pcolormesh(x_edges, y_edges, masked, cmap='YlOrRd',
                         vmin=0.0, vmax=1.0, shading='flat')
    ax.set_aspect('auto')
    ax.set_xticks([x_bins[i] for i in x_tick_idx])
    ax.set_xticklabels([str(x_bins[i]) for i in x_tick_idx], fontsize=8)
    ax.set_yticks([y_bins[i] for i in y_tick_idx])
    ax.set_yticklabels([str(y_bins[i]) for i in y_tick_idx], fontsize=8)
    ax.set_xlabel(xlabel, fontsize=10)
    ax.set_ylabel(ylabel, fontsize=10)
    if note_avg is not None:
        title = f"{title}\n建议占比均值: {note_avg:.0f}%"
    ax.set_title(title, fontsize=11, fontweight='bold')
    return mesh


def plot_ratio_layers(arr, fname, x_col, y_col, x_bins, y_bins, code_col,
                      layers, layer_col, layer_names, fixed_txt, x_tick_idx,
                      y_tick_idx, ylabel, fig_cols=2, per_title=None,
                      figsize=None, subplot_w=4.4, subplot_h=4.2,
                      footnote=None):
    """通用多子图绘制"非安全建议占比"热力图 (用于 τ 敏感性分析)。"""
    n = len(layers)
    cols = min(fig_cols, n)
    rows = int(np.ceil(n / cols))
    if figsize is None:
        figsize = (subplot_w * cols + 3.5, subplot_h * rows + 1.5)
    fig, axes = plt.subplots(rows, cols, figsize=figsize)
    axes = np.atleast_1d(axes).ravel()
    meshes = []
    for idx, lv in enumerate(layers):
        ax = axes[idx]
        mask = arr[:, layer_col] == lv
        ratio_grid = build_ratio_grid(arr, mask, x_col, y_col,
                                      x_bins, y_bins, code_col)
        occ = ratio_grid >= 0
        avg = float(ratio_grid[occ].mean()) * 100.0 if occ.any() else 0.0
        title = per_title(lv) if per_title else f"{layer_names.get(lv, lv)}"
        mesh = draw_ratio_heat(ax, ratio_grid, x_bins, y_bins,
                               x_tick_idx, y_tick_idx, title, ylabel,
                               note_avg=avg)
        meshes.append(mesh)
        n_occ = int(occ.sum())
        print(f"    {fname} 层={lv}: 有效格 {n_occ}/{ratio_grid.size} "
              f"({n_occ / ratio_grid.size * 100:.0f}%), 建议占比均值={avg:.1f}%")
    for ax in axes[n:]:
        ax.axis('off')
    fig.suptitle(fixed_txt, fontsize=12, fontweight='bold', y=0.995)
    note = footnote or "颜色 = 该网格单元内非安全建议(V≠0)占比 | 灰色 = 无数据"
    add_footnote(fig, note)
    # 公共 colorbar (基于最后一个 mesh)
    cbar_ax = fig.add_axes([0.42, 0.01, 0.16, 0.015])
    cbar = fig.colorbar(meshes[-1], cax=cbar_ax, orientation='horizontal')
    cbar.set_label('非安全建议占比', fontsize=8)
    cbar.ax.tick_params(labelsize=7)
    fig.subplots_adjust(top=0.88, bottom=0.07, left=0.075, right=0.985,
                        hspace=0.55, wspace=0.55)
    fig.savefig(os.path.join(OUT_DIR, fname), dpi=150)
    plt.close(fig)
    print(f"  {fname}")


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
    ax.set_title(f"密集化查询表动作组合分布 — 共 {total:,} 条规则",
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
                     footnote=None, show_disagreement=True):
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
                  cmap, norm, title, ylabel,
                  show_disagreement=show_disagreement)
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
        arr, '02_h_range_bearing.png', C_R, C_B, CORE_RANGE_BINS, BRG_BINS, C_HC,
        layers, C_A, {}, cmap, norm, H_NAMES, H_COLORS,
        "水平决策面(核心区 Range 100~3000 ft): Range × Bearing (颜色 = 水平动作)\n"
        "固定: 对头接近(Rel_Heading=180°) | τ=5s | 聚合: 双机速度/垂直率取众数",
        CORE_R_TICK_IDX, BRG_TICK_IDX, "Bearing (°, 前方=0, 左负右正) 每格30°",
        per_title=per_title, figsize=(16.5, 9.5),
        footnote="灰色 = 无数据", show_disagreement=False)


# ---------------- 03 垂直决策面 (核心区, 按方位) ----------------
def plot_v_core_bearing(arr):
    cmap = ListedColormap(V_COLORS)
    norm = BoundaryNorm([-0.5 + i for i in range(8)], cmap.N)
    layers = [-180.0, -90.0, 0.0, 90.0]

    def per_title(b):
        return f"垂直决策面  Bearing={BRG_NAME[b]}"

    plot_heat_layers(
        arr, '03_v_core_bearing.png', C_R, C_A, CORE_RANGE_BINS, CORE_ALT_BINS, C_VC,
        layers, C_B, BRG_NAME, cmap, norm, V_NAMES, V_COLORS,
        "垂直决策面(核心区 Range≤3000ft, |Alt|≤1000ft): Range × Rel_Alt (颜色 = 垂直动作) — 入侵机方位对比\n"
        "固定: 对头接近(Rel_Heading=180°) | τ=5s | 聚合: 双机速度/垂直率取众数\n",
        CORE_R_TICK_IDX, CORE_ALT_TICK_IDX, "Rel_Alt (ft) 每格100ft",
        per_title=per_title, figsize=(14, 9.5), fig_cols=2,
        footnote="灰色 = 无数据", show_disagreement=False)


# ---------------- 04 垂直决策面 (核心区, 按接近几何) ----------------
def plot_v_core_heading(arr):
    cmap = ListedColormap(V_COLORS)
    norm = BoundaryNorm([-0.5 + i for i in range(8)], cmap.N)
    # 去掉 Rel_Heading=180° (同向) 子图, 保留 -180°/-90°/0°/90° 四张
    layers = [-180.0, -90.0, 0.0, 90.0]

    def per_title(h):
        return f"垂直决策面  Rel_Heading={HDG_NAME[h]}"

    plot_heat_layers(
        arr, '04_v_core_heading.png', C_R, C_A, CORE_RANGE_BINS, CORE_ALT_BINS, C_VC,
        layers, C_H, HDG_NAME, cmap, norm, V_NAMES, V_COLORS,
        "垂直决策面(核心区 Range≤3000ft, |Alt|≤1000ft): Range × Rel_Alt (颜色 = 垂直动作) — 接近几何对比\n"
        "固定: 正前方(Bearing=0°) | τ=5s | 聚合: 双机速度/垂直率取众数",
        CORE_R_TICK_IDX, CORE_ALT_TICK_IDX, "Rel_Alt (ft) 每格100ft",
        per_title=per_title, fig_cols=2,
        footnote="灰色 = 无数据", show_disagreement=False)


# ---------------- 05 τ 敏感性 (核心区, Range×Tau 联合占比) ----------------
def plot_v_core_tau(arr):
    """τ 敏感性: Range × Tau 联合热力图 (颜色 = 非安全建议占比, 白→黄→红)。

    聚合所有 Alt/Bearing/Heading/速度/垂直率, 纵轴 τ 从 -1 到 100s,
    清晰展示"τ 越大 → 建议占比越低"的梯度。
    """
    # 核心区: |Alt|<=1000, Range<=3000; 聚合其他所有维度
    sub = arr[(arr[:, C_A] >= -1000.0) & (arr[:, C_A] <= 1000.0)]
    sub = sub[(sub[:, C_R] >= 100.0) & (sub[:, C_R] <= 3000.0)]

    # 固定 Rel_Alt=0 (同高度) 单独一版? 不, 聚合 Alt 更有代表性
    ratio_grid = build_ratio_grid(sub, np.ones(len(sub), dtype=bool),
                                  C_R, C_T, CORE_RANGE_BINS, TAU_BINS, C_VC)

    fig, ax = plt.subplots(figsize=(15, 8.5))
    masked = np.ma.masked_where(ratio_grid < 0, ratio_grid)
    ax.set_facecolor("#F5F5F5")  # 无数据格浅灰
    x_edges = cell_edges(CORE_RANGE_BINS)
    y_edges = cell_edges(TAU_BINS)
    mesh = ax.pcolormesh(x_edges, y_edges, masked, cmap='YlOrRd',
                         vmin=0.0, vmax=1.0, shading='flat')
    ax.set_aspect('auto')
    ax.set_xticks([CORE_RANGE_BINS[i] for i in CORE_R_TICK_IDX])
    ax.set_xticklabels([str(CORE_RANGE_BINS[i]) for i in CORE_R_TICK_IDX], fontsize=9)
    ax.set_yticks([TAU_BINS[i] for i in TAU_TICK_IDX])
    ax.set_yticklabels([str(TAU_BINS[i]) for i in TAU_TICK_IDX], fontsize=9)
    ax.set_xlabel("Range (ft)", fontsize=12)
    ax.set_ylabel("Tau (s, 到达最接近点时间)", fontsize=12)
    ax.set_title("τ 敏感性 (核心区 |Alt|≤1000ft, Range 100~3000ft)\n"
                 "颜色 = 非安全建议(V≠0)占比 | 聚合所有方位/高度差/速度",
                 fontsize=13, fontweight='bold')

    # 每行 τ 的占比均值标注在右侧
    for i, tau in enumerate(TAU_BINS):
        row = ratio_grid[i, :]
        occ = row[row >= 0]
        if len(occ) == 0:
            continue
        avg = 100.0 * occ.mean()
        ax.text(3300, tau, f"{avg:.0f}%", fontsize=8, va='center',
                color='#333333')

    cbar = fig.colorbar(mesh, ax=ax, orientation='vertical', pad=0.02)
    cbar.set_label('非安全建议占比', fontsize=10)
    cbar.ax.tick_params(labelsize=8)
    note = ("左图: 颜色 = 该单元内 V≠0(有垂直机动建议) 的规则占比\n"
            "右侧标注 = 该 τ 行所有 Range 列的平均建议占比 | 灰色 = 无数据")
    add_footnote(fig, note)
    fig.tight_layout(rect=[0, 0.05, 1, 1])
    fig.savefig(os.path.join(OUT_DIR, '05_v_core_tau.png'), dpi=150)
    plt.close(fig)
    print("  05_v_core_tau.png (Range×Tau 联合占比版)")


# ---------------- 05b τ 敏感性 (核心区, 众数动作版, 保留对比) ----------------
def plot_v_core_tau_modes(arr):
    """τ 敏感性: 众数动作版 (原视图), 保留用于与占比版对比。"""
    cmap = ListedColormap(V_COLORS)
    norm = BoundaryNorm([-0.5 + i for i in range(8)], cmap.N)
    layers = [-1.0, 5.0, 10.0, 15.0]

    def per_title(t):
        return f"垂直决策面  {TAU_NAME[t]}"

    plot_heat_layers(
        arr, '05b_v_core_tau_modes.png', C_R, C_A, CORE_RANGE_BINS, CORE_ALT_BINS, C_VC,
        layers, C_T, TAU_NAME, cmap, norm, V_NAMES, V_COLORS,
        "τ 敏感性(核心区) 众数动作版: Range × Rel_Alt (颜色 = 垂直动作众数)\n"
        "聚合所有方位/几何 | 双机速度/垂直率取众数",
        CORE_R_TICK_IDX, CORE_ALT_TICK_IDX, "Rel_Alt (ft) 每格100ft",
        per_title=per_title, figsize=(16.5, 10.5), fig_cols=2,
        footnote="灰色 = 无数据", show_disagreement=False)


# ---------------- 08 危险热力图: Range × |Alt| 联合 + 双边际曲线 ----------------
def plot_risk_heatmap(arr):
    """08: Range × |Alt| 联合危险热力图 + 边际曲线。

    颜色 = 非安全建议(V≠0)占比, 展示距离和高度差对危险程度的协同影响。
    上方边际曲线: Range 聚合的占比-距离关系 (显示 500~1000ft 最危险)
    右侧边际曲线: |Alt| 聚合的占比-高度关系 (显示 600ft 安全阈值)
    """
    sub = arr[(arr[:, C_R] >= 100.0) & (arr[:, C_R] <= 3000.0)]
    sub = sub[(sub[:, C_A] >= -2400.0) & (sub[:, C_A] <= 2400.0)]
    abs_alt = np.abs(sub[:, C_A])

    # 主网格: Range × |Alt|
    mask_all = np.ones(len(sub), dtype=bool)
    ratio_grid = build_ratio_grid_from_abs(sub, mask_all, C_R, C_A,
                                           CORE_RANGE_BINS, ALT_ABS_BINS, C_VC)

    # 边际曲线
    x_marg = []
    for r in CORE_RANGE_BINS:
        m = sub[:, C_R] == r
        vals = sub[m, C_VC].astype(int)
        if len(vals):
            x_marg.append(100.0 * (vals != 0).mean())
        else:
            x_marg.append(np.nan)
    y_marg = []
    for a in ALT_ABS_BINS:
        m = np.abs(sub[:, C_A]) == a
        vals = sub[m, C_VC].astype(int)
        if len(vals):
            y_marg.append(100.0 * (vals != 0).mean())
        else:
            y_marg.append(np.nan)

    fig = plt.figure(figsize=(15, 11))
    # 主热力图
    ax_main = fig.add_axes([0.1, 0.12, 0.62, 0.62])
    masked = np.ma.masked_where(ratio_grid < 0, ratio_grid)
    ax_main.set_facecolor("#F5F5F5")
    x_edges = cell_edges(CORE_RANGE_BINS)
    y_edges = cell_edges(ALT_ABS_BINS)
    mesh = ax_main.pcolormesh(x_edges, y_edges, masked, cmap='YlOrRd',
                              vmin=0.0, vmax=1.0, shading='flat')
    ax_main.set_xticks([CORE_RANGE_BINS[i] for i in CORE_R_TICK_IDX])
    ax_main.set_xticklabels([str(CORE_RANGE_BINS[i]) for i in CORE_R_TICK_IDX], fontsize=9)
    ax_main.set_yticks([ALT_ABS_BINS[i] for i in ALT_ABS_TICK_IDX])
    ax_main.set_yticklabels([str(ALT_ABS_BINS[i]) for i in ALT_ABS_TICK_IDX], fontsize=9)
    ax_main.set_xlabel("Range (ft)", fontsize=12)
    ax_main.set_ylabel("|Rel_Alt| 绝对高度差 (ft)", fontsize=12)

    # 上方边际曲线: Range vs 建议占比 (与主图横轴 Range 对应)
    ax_top = fig.add_axes([0.1, 0.78, 0.62, 0.16])
    ax_top.plot(CORE_RANGE_BINS, x_marg, 's-', color='#1565C0', lw=2, ms=4)
    hi = np.nanargmax(x_marg)
    ax_top.axvline(CORE_RANGE_BINS[hi], color='#C62828', ls='--', lw=1.5)
    ax_top.text(CORE_RANGE_BINS[hi] + 30, np.nanmax(x_marg) * 0.9,
                f'峰值 {CORE_RANGE_BINS[hi]}ft', color='#C62828', fontsize=9)
    ax_top.set_ylabel('建议占比 (%)', fontsize=9)
    ax_top.set_title('按 Range 聚合: 近距最危险、过远安全', fontsize=10)
    ax_top.grid(alpha=0.3)
    ax_top.tick_params(labelsize=8)
    # 与主热力图横轴完全对齐 (相同的范围与刻度)
    ax_top.set_xlim(x_edges[0], x_edges[-1])
    ax_top.set_xticks([CORE_RANGE_BINS[i] for i in CORE_R_TICK_IDX])
    ax_top.set_xticklabels([str(CORE_RANGE_BINS[i]) for i in CORE_R_TICK_IDX], fontsize=8)

    # 右侧边际曲线: |Alt| vs 建议占比 (与主图纵轴 |Alt| 对应)
    ax_right = fig.add_axes([0.76, 0.12, 0.2, 0.62])
    ax_right.plot(y_marg, ALT_ABS_BINS, 'o-', color='#C62828', lw=2, ms=4)
    ax_right.axhline(600, color='#1565C0', ls='--', lw=1.5)
    ax_right.text(np.nanmax(y_marg) * 0.55, 620,
                  '600ft 安全阈值', color='#1565C0', fontsize=9)
    ax_right.set_xlabel('建议占比 (%)', fontsize=9)
    ax_right.set_title('按 |Alt| 聚合: 高度差越大 → 越安全', fontsize=10)
    ax_right.grid(alpha=0.3)
    ax_right.tick_params(labelsize=8)
    # 保持与主热力图纵轴同向 (0 在下, 2400 在上)
    ax_right.set_ylim(0, 2400)
    ax_right.set_yticks([ALT_ABS_BINS[i] for i in ALT_ABS_TICK_IDX])
    ax_right.set_yticklabels([str(ALT_ABS_BINS[i]) for i in ALT_ABS_TICK_IDX], fontsize=8)

    cbar = fig.colorbar(mesh, ax=[ax_main], orientation='vertical',
                        fraction=0.04, pad=0.03)
    cbar.set_label('非安全建议占比', fontsize=10)
    cbar.ax.tick_params(labelsize=8)

    fig.suptitle("危险分布: Range × |Alt| 联合 (颜色 = 非安全建议占比)\n",
                 fontsize=13, fontweight='bold')
    note = ("上方曲线: 500~1000ft 距离区间建议占比峰值 73%, 过近(<300ft)无建议、过远(>3000ft)逐渐安全\n"
            "右侧曲线: 高度差 |Alt| 越大建议占比越低, 超过 600ft 接近 0 (垂直已安全)")
    add_footnote(fig, note)
    fig.savefig(os.path.join(OUT_DIR, '08_risk_heatmap.png'), dpi=150)
    plt.close(fig)
    print("  08_risk_heatmap.png (Range×|Alt| 联合危险热力图 + 边际曲线)")


# ---------------- 09 合理性判定: 垂直方向 + 水平方向 ----------------
def plot_reasoning_check(arr):
    """09: 动作合理性判定图 (三面板)。

    面板A(左): 垂直方向合理性 — 入侵机在上→应下降, 在下→应爬升 (反向规避)。
    面板B(中): 水平方向合理性 — 来机在左→应右转, 在右→应左转 (转向分离)。
    面板C(右): Range 对决策正确性的影响 — 水平转向正确率随距离变化的趋势。
    """
    # 限定核心区 Range 100~3000ft (系统实际给出机动建议的距离范围)
    arr = arr[(arr[:, C_R] >= 100.0) & (arr[:, C_R] <= 3000.0)]

    # ---- 面板 A: 垂直方向合理性 ----
    groups_v = []
    for tag, lo, hi in [('入侵机在上\nAlt>300ft', 300, 2400),
                        ('同高度\n|Alt|≤300ft', -300, 300),
                        ('入侵机在下\nAlt<-300ft', -2400, -300)]:
        up = down = 0
        for i in range(len(arr)):
            al = arr[i, C_A]
            v = int(arr[i, C_VC])
            if al < lo or al > hi:
                continue
            if v == 4:
                up += 1    # 建议爬升
            elif v == 5:
                down += 1  # 建议下降
            elif v == 2:
                down += 1  # 禁爬升 ≈ 倾向下降 (保守纳入合理侧)
            elif v == 3:
                up += 1    # 禁下降 ≈ 倾向爬升
        tot = up + down
        groups_v.append((tag, up, down, tot))

    # ---- 面板 B: 水平方向合理性 ----
    groups_h = []
    for tag, lo, hi in [('左前方\nBearing<-30°', -180, -30),
                        ('正前方\nBearing=0', -0.1, 0.1),
                        ('右前方\nBearing>30°', 30, 180)]:
        right = left = 0
        for i in range(len(arr)):
            b = arr[i, C_B]
            h = int(arr[i, C_HC])
            if b < lo or b > hi:
                continue
            if h == 2:
                right += 1  # 建议右转
            elif h == 3:
                left += 1   # 建议左转
        tot = right + left
        groups_h.append((tag, right, left, tot))

    # ---- C 面板数据: Range 对决策正确性的影响 ----
    range_bins = [(200, 500, '200~500'), (500, 1000, '500~1000'),
                  (1000, 2000, '1000~2000'), (2000, 3000, '2000~3000')]
    c_h_ok_pct = []
    c_h_n = []
    c_v_ok_pct = []
    c_v_n = []
    for lo, hi, _tag in range_bins:
        m = (arr[:, C_R] >= lo) & (arr[:, C_R] <= hi)
        sub = arr[m]
        # 水平转向正确率: 左方→右转 / 右方→左转
        h_ok = h_tot = 0
        for i in range(len(sub)):
            b = sub[i, C_B]
            h = int(sub[i, C_HC])
            if b < -30 and h == 2:
                h_tot += 1
                h_ok += 1
            elif b < -30 and h == 3:
                h_tot += 1
            elif b > 30 and h == 3:
                h_tot += 1
                h_ok += 1
            elif b > 30 and h == 2:
                h_tot += 1
        c_h_ok_pct.append(100.0 * h_ok / h_tot if h_tot else 0.0)
        c_h_n.append(h_tot)
        # 垂直机动正确率
        v_ok = v_tot = 0
        for i in range(len(sub)):
            al = sub[i, C_A]
            v = int(sub[i, C_VC])
            if al > 300 and v in (2, 3, 4, 5):
                v_tot += 1
                if v in (5, 2):
                    v_ok += 1
            elif al < -300 and v in (2, 3, 4, 5):
                v_tot += 1
                if v in (4, 3):
                    v_ok += 1
        c_v_ok_pct.append(100.0 * v_ok / v_tot if v_tot else 0.0)
        c_v_n.append(v_tot)

    fig = plt.figure(figsize=(20, 7.5))

    # ---- A 面板 ----
    ax1 = fig.add_subplot(1, 3, 1)
    names_v = [g[0] for g in groups_v]
    up_pct = [100.0 * g[1] / g[3] if g[3] else 0 for g in groups_v]
    down_pct = [100.0 * g[2] / g[3] if g[3] else 0 for g in groups_v]
    n_v = [g[3] for g in groups_v]
    x = np.arange(len(names_v))
    ax1.bar(x, up_pct, color='#E53935', label='建议爬升(禁下降)')
    ax1.bar(x, down_pct, bottom=up_pct, color='#1E88E5',
            label='建议下降(禁爬升)')
    for i, (u, d, n) in enumerate(zip(up_pct, down_pct, n_v)):
        ax1.text(i, u / 2, f'{u:.0f}%', ha='center', va='center', fontsize=9,
                 color='white', fontweight='bold')
        ax1.text(i, u + d / 2, f'{d:.0f}%', ha='center', va='center', fontsize=9,
                 color='white', fontweight='bold')
        ax1.text(i, 102, f'n={n:,}', ha='center', fontsize=9, color='#333333')
    ax1.set_xticks(x)
    ax1.set_xticklabels(names_v, fontsize=9)
    ax1.set_ylabel('机动建议占比 (%)', fontsize=10)
    ax1.set_ylim(0, 110)
    ax1.set_title('A. 垂直方向合理性\n(入侵机在上→应下降, 在下→应爬升)', fontsize=11, fontweight='bold')
    ax1.legend(fontsize=8, loc='upper right')
    ax1.grid(axis='y', alpha=0.3)
    # ---- B 面板 ----
    ax2 = fig.add_subplot(1, 3, 2)
    names_h = [g[0] for g in groups_h]
    right_pct = [100.0 * g[1] / g[3] if g[3] else 0 for g in groups_h]
    left_pct = [100.0 * g[2] / g[3] if g[3] else 0 for g in groups_h]
    n_h = [g[3] for g in groups_h]
    x2 = np.arange(len(names_h))
    ax2.bar(x2, right_pct, color='#8E24AA', label='建议右转')
    ax2.bar(x2, left_pct, bottom=right_pct, color='#FB8C00',
            label='建议左转')
    for i, (r, l, n) in enumerate(zip(right_pct, left_pct, n_h)):
        ax2.text(i, r / 2, f'{r:.0f}%', ha='center', va='center', fontsize=9,
                 color='white', fontweight='bold')
        ax2.text(i, r + l / 2, f'{l:.0f}%', ha='center', va='center', fontsize=9,
                 color='white', fontweight='bold')
        ax2.text(i, 102, f'n={n:,}', ha='center', fontsize=9, color='#333333')
    ax2.set_xticks(x2)
    ax2.set_xticklabels(names_h, fontsize=9)
    ax2.set_ylabel('转向建议占比 (%)', fontsize=10)
    ax2.set_ylim(0, 110)
    ax2.set_title('B. 水平方向合理性\n(来机在左→应右转, 在右→应左转)', fontsize=11, fontweight='bold')
    ax2.legend(fontsize=8, loc='upper right')
    ax2.grid(axis='y', alpha=0.3)
    # ---- C 面板: Range 对决策正确性的影响 ----
    ax3 = fig.add_subplot(1, 3, 3)
    names_r = [t[2] for t in range_bins]
    x3 = np.arange(len(names_r))
    w = 0.35
    ax3.bar(x3 - w / 2, c_h_ok_pct, w, color='#8E24AA',
            label='水平转向正确率')
    ax3.bar(x3 + w / 2, c_v_ok_pct, w, color='#E53935',
            label='垂直机动正确率')
    for i, (hp, hn, vp, vn) in enumerate(zip(c_h_ok_pct, c_h_n, c_v_ok_pct, c_v_n)):
        ax3.text(i - w / 2, hp + 1.5, f'{hp:.0f}%\nn={hn:,}', ha='center',
                 va='bottom', fontsize=7.5, color='#8E24AA')
        ax3.text(i + w / 2, vp + 1.5, f'{vp:.0f}%\nn={vn:,}', ha='center',
                 va='bottom', fontsize=7.5, color='#E53935')
    ax3.set_xticks(x3)
    ax3.set_xticklabels(names_r, fontsize=9)
    ax3.set_ylabel('决策正确率 (%)', fontsize=10)
    ax3.set_xlabel('Range (ft)', fontsize=10)
    ax3.set_ylim(0, 110)
    ax3.set_title('C. Range 对决策正确性的影响\n(距离越远, 水平转向正确率下降)', fontsize=11, fontweight='bold')
    ax3.legend(fontsize=8, loc='lower left')
    ax3.grid(axis='y', alpha=0.3)
    fig.suptitle("动作合理性判定: 机动方向是否遵循[反向规避/转向分离]原则\n"
                 "面板C展示 Range 对决策正确性的影响 (核心区 200~3000ft)",
                 fontsize=13, fontweight='bold', y=0.98)
    note = ("面板A仅统计垂直机动(爬升/下降/禁爬/禁降)规则; 面板B仅统计水平转向(右转/左转)规则;\n"
            "面板C: 正确率 = 建议方向与入侵机所在侧相反的比例 (范围为100~3000ft核心区)")
    add_footnote(fig, note, size=7.5)
    fig.subplots_adjust(top=0.84, bottom=0.10, left=0.05, right=0.98, wspace=0.28)
    fig.savefig(os.path.join(OUT_DIR, '09_reasoning_check.png'), dpi=150)
    plt.close(fig)
    print("  09_reasoning_check.png (动作合理性判定图)")


# ---------------- 10 tau 对动作的影响 (平面热力图, 类图2) ----------------
def plot_tau_effect(arr):
    """10: τ(到达最接近点时间) 对水平动作的影响 (Range×Tau 平面热力图)。

    类图2 的平面网格展示: 横轴 Range, 纵轴 Tau, 颜色=水平动作众数。
    聚合所有 Alt/Bearing/Heading/速度 — 直观展示紧迫程度如何决定水平动作:
    τ小(紧迫)→转向建议(右转/左转/直飞)密集; τ大(宽松)→安全为主。
    """
    # 限定核心区 Range 100~3000ft, |Alt|<=1000ft
    core = arr[(arr[:, C_R] >= 100.0) & (arr[:, C_R] <= 3000.0)]
    core = core[(core[:, C_A] >= -1000.0) & (core[:, C_A] <= 1000.0)]

    fig, ax = plt.subplots(figsize=(15, 9.5))
    mask_all = np.ones(len(core), dtype=bool)
    grid, frac = build_grid(core, mask_all, C_R, C_T,
                            CORE_RANGE_BINS, TAU_BINS, C_HC)
    cmap = ListedColormap(H_COLORS)
    norm = BoundaryNorm([-0.5 + i for i in range(5)], cmap.N)
    draw_heat(ax, grid, frac, CORE_RANGE_BINS, TAU_BINS,
              CORE_R_TICK_IDX, TAU_TICK_IDX, cmap, norm,
              "水平动作众数 (τ 对动作的影响)", "Tau (s, 到达最接近点时间)",
              show_disagreement=False)
    codes_present = set(grid[grid >= 0].tolist())
    add_legend(ax, codes_present, H_NAMES, H_COLORS)
    ax.set_title('τ 对水平动作的影响 (核心区 Range 100~3000ft, |Alt|≤1000ft)\n'
                 '颜色 = 水平动作众数 | 聚合所有高度差/方位/接近几何/速度',
                 fontsize=13, fontweight='bold')
    # 标注关键紧迫区域
    ax.axhspan(-1.0, 15.0, color='white', alpha=0.25, linewidth=0)
    ax.text(3100, 7.0, '紧迫区\n(机动密集)', fontsize=9, color='#333333',
            ha='left', va='center')
    note = ("纵轴 Tau: 越小越紧迫(到达最接近点时间短)\n"
            "τ≤15s(紧迫)→右转/左转/直飞建议密集; τ大→安全(灰色)为主")
    add_footnote(fig, note)
    fig.subplots_adjust(top=0.82, bottom=0.10, left=0.08, right=0.98)
    fig.savefig(os.path.join(OUT_DIR, '10_tau_effect.png'), dpi=150)
    plt.close(fig)
    print("  10_tau_effect.png (τ 对水平动作的影响 - 平面热力图)")


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
        per_title=per_title, figsize=(16.5, 10.5), fig_cols=3,
        footnote="灰色 = 无数据", show_disagreement=False)


# ---------------- 07 水平决策面 τ 敏感性 (核心区) ----------------
def plot_h_tau_bearing(arr):
    cmap = ListedColormap(H_COLORS)
    norm = BoundaryNorm([-0.5 + i for i in range(5)], cmap.N)
    layers = [-1.0, 5.0, 10.0, 15.0]

    def per_title(t):
        return f"水平决策面  {TAU_NAME[t]}"

    # 固定: 同高度(Rel_Alt=0) + 对头(Rel_Heading=180°)
    sub = arr[(arr[:, C_A] == 0.0) & (arr[:, C_H] == 180.0)]
    plot_heat_layers(
        sub, '07_h_tau_bearing.png', C_R, C_B, CORE_RANGE_BINS, BRG_BINS, C_HC,
        layers, C_T, TAU_NAME, cmap, norm, H_NAMES, H_COLORS,
        "水平决策面 τ 敏感性(核心区 Range 100~3000 ft): Range × Bearing (颜色 = 水平动作)\n"
        "固定: 同高度(Rel_Alt=0) | 对头(Rel_Heading=180°) | 聚合: 双机速度/垂直率取众数",
        CORE_R_TICK_IDX, BRG_TICK_IDX, "Bearing (°, 前方=0, 左负右正) 每格30°",
        per_title=per_title, figsize=(16.5, 10.5), fig_cols=2,
        footnote="灰色 = 无数据", show_disagreement=False)


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
    plot_v_core_tau_modes(arr)
    plot_risk_heatmap(arr)
    plot_reasoning_check(arr)
    plot_v_far_bearing(arr)
    plot_h_tau_bearing(arr)
    print(f"\n全部图集已输出至: {OUT_DIR}")


if __name__ == "__main__":
    main()