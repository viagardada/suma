# -*- coding: utf-8 -*-
"""
avoidance_polar_map.py —— 避障决策极坐标查询器 (ACAS sXu 轻量查询表)
=====================================================================

用途
----
把 my_lightweight_table_dense.csv (89,853 条离散规则) 中"做出避障动作"的状态
集中到一张**极坐标态势图**上, 并支持手动选定:
    * 入侵者相对于本机的位置区块 (方位 Bearing × 距离 Range)
    * 入侵者的速度方向 (Rel_Heading)
    * 本机与入侵者的速度大小比 (方式 B: 一把比例滑块, 该比例下多组绝对速度取众数)
确定后, 右侧直接输出本机的动作 (水平 H / 垂直 V)。

速度比滑块: 档位 = 表中实际出现的全部 35 种不同比例; 标签一律归一化为 "本机:入侵者"
且**保证有一边恰为 1** (慢的一方记为 1, 另一侧为小数倍率), 从小到大依次为
    1:4 / 1:3 / 1:2.5 / 1:2.33 / 1:2 / … / 1:1 (同速) / … / 2:1 / 2.5:1 / 3:1 / 4:1
本机比入侵者慢时写作 1:x, 快时写作 x:1, 覆盖 100% 的规则; 同一比例下的多组绝对
速度 (如 1:1 的 150/150、200/200 … 400/400) 按众数汇总为一个动作。

固定高度：-200 / -100 / 0 / 100 / 200 ft，共享四个滑块。
固定高度若不在输入表中则显示无数据，不做插值。

用法
----
    python avoidance_polar_map.py                     # 交互窗口(全表，默认包含无建议记录)
    python avoidance_polar_map.py --avoid-only        # 隐藏 H:0|V:0 记录
    python avoidance_polar_map.py --max-range 1000    # 查看 1000 ft 内圈
    python avoidance_polar_map.py --hv v              # 背景按垂直动作着色
    python avoidance_polar_map.py -o out.png          # 无界面渲染当前视图为 PNG
    python avoidance_polar_map.py --bearing 30 --range 1000 --rel-heading -180 --ratio 1:2
                                      # 速度比写作 本机:入侵者, 一边恒为 1 (此处本机慢一半)

交互按键
    A  切换 "是否包含无建议记录"
    H  背景按水平动作着色      V  背景按垂直动作着色
    ← / →   选中的方位扇区 -/+ 1 档
    ↑ / ↓   选中的距离环   +/− 1 档
    S  保存当前视图为 PNG      Q / Esc  退出

图面约定 (与 polar_state_view.py 一致)
    * 机头朝上: 图面 0° = 本机机头方向, 正角度(顺时针) = 右侧, 负角度 = 左侧
    * 背景铺满颜色: 每个"方位×距离"区块是一个**扇环**, 颜色 = 当前切片下的动作众数
    * 浅灰 #E8E8E8 = 无数据 (该区块在当前切片下没有任何避障规则, 面板显示 H:--/V:--)
    * 中灰 #9E9E9E = 当前方向无建议 (H:0 或 V:0)，另一方向可能仍有建议
    * 选中区块用黑色加粗扇环高亮
"""

import argparse
import csv
import math
import os
import sys

import matplotlib
import numpy as np

# 无界面渲染时使用 Agg 后端 (必须在 pyplot 导入前设置)
if "--output" in sys.argv or "-o" in sys.argv:
    matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.colors import BoundaryNorm, ListedColormap
from matplotlib.patches import FancyBboxPatch, Rectangle
from matplotlib.widgets import Slider

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_TABLE = os.path.join(SCRIPT_DIR, "my_lightweight_table_dense.csv")
OUT_DIR = os.path.join(SCRIPT_DIR, "output", "avoidance_visuals")

plt.rcParams["font.sans-serif"] = ["Microsoft YaHei", "SimHei", "Arial Unicode MS"]
plt.rcParams["axes.unicode_minus"] = False

# ---------------- 动作命名与配色 (与 visualize_dense.py / polar_state_view.py 一致) ----------------
H_NAMES = {
    0: "NO ADVISORY(无水平建议)",
    1: "CLEAR(解除)",
    2: "TURN RIGHT(右转)",
    3: "TURN LEFT(左转)",
    4: "STRAIGHT(直飞)",
}
V_NAMES = {
    0: "NO ADVISORY(无垂直建议)",
    1: "CLEAR(解除)",
    2: "DO NOT CLIMB(禁止爬升)",
    3: "DO NOT DESCEND(禁止下降)",
    4: "CLIMB(建议爬升)",
    5: "DESCEND(建议下降)",
    6: "XC CLIMB(交叉爬升)",
    7: "XC DESCEND(交叉下降)",
}
H_COLORS = ["#9E9E9E", "#66BB6A", "#EF5350", "#AB47BC", "#42A5F5"]
V_COLORS = [
    "#9E9E9E",
    "#66BB6A",
    "#FFEE58",
    "#26C6DA",
    "#EF5350",
    "#42A5F5",
    "#FFA726",
    "#AB47BC",
]

OWN_COLOR = "#1565C0"
INT_COLOR = "#D32F2F"
NO_DATA_COLOR = "#E8E8E8"  # 无数据格: 比中灰 #9E9E9E(0/安全) 淡, 又明显区别于白底

STATE_FIELDS = (
    "Range(ft)",
    "Rel_Altitude(ft)",
    "Bearing(deg)",
    "Rel_Heading(deg)",
    "Intruder_Speed(fps)",
    "Own_Speed(fps)",
    "Own_Vert_Rate(fps)",
    "Int_Vert_Rate(fps)",
    "Tau(s)",
)
ACTION_FIELD = "Recommended_Action"

# 列索引
C_R, C_A, C_B, C_H, C_IS, C_OS, C_OV, C_IV, C_T, C_HC, C_VC = range(11)

# 速度比 (方式 B): 一把"速度比"滑块, 档位 = 表中实际出现的全部不同比例;
# 标签归一化为 "本机:入侵者" 且一边恰为 1 (1 在速度较小的一侧, 如 1:1.33 / 2.5:1);
# 该比例下所有绝对速度组合按众数汇总动作。
RATIO_FALLBACK = (1.0, "1:1")

# 距离显示基准 (核心区), 选中更远距离时自动扩展
R_DISPLAY_BASE = 3000.0
FIXED_ALTITUDES = (-200.0, -100.0, 0.0, 100.0, 200.0)

# 背景扇环平滑度: 每个方位 bin 的角边细分成多少段折线。
# 极坐标下 pcolormesh 只变换顶点, 直连顶点会画成直边梯形; 细分后内外缘贴合圆弧。
BG_ARC_STEPS = 8


def parse_hv(s):
    """把 'H:2 | V:5' 解析成 (2, 5)"""
    try:
        h = int(s.split("|")[0].split(":")[1].strip())
        v = int(s.split("|")[1].split(":")[1].strip())
        return h, v
    except Exception:  # noqa
        return 0, 0


def canon_deg(x):
    """把 ±180 归一到 [-180, 180): 180 -> -180 (同一物理方向, 合并统计)"""
    x = float(x)
    if x >= 180.0:
        x -= 360.0
    return x


def bearing_name(b):
    """方位角 -> 中文语义 (0=正前, 正=右侧, 负=左侧)"""
    bb = int(round(canon_deg(b)))
    if bb == 0:
        return "正前方"
    if bb == 90:
        return "右侧"
    if bb == -90:
        return "左侧"
    if bb == -180:
        return "正后方"
    return "%+d°" % bb


def heading_name(psi):
    """相对航向 -> 中文语义 (0=同向, ±90=交叉, ±180=对头)"""
    pp = int(round(canon_deg(psi)))
    if pp == 0:
        return "同向"
    if pp == 90:
        return "右交叉"
    if pp == -90:
        return "左交叉"
    if pp == -180:
        return "对头"
    return "%+d°" % pp


def bearing_label(b):
    """滑块显示文本: 方位角 + (仅正前/正后/正左/正右时补语义)"""
    bb = int(round(canon_deg(b)))
    nm = bearing_name(b)
    if nm.endswith("°"):
        return "%+d°" % bb
    return "%d° %s" % (bb, nm)


def heading_label(psi):
    """滑块显示文本: 相对航向 + (仅同向/对头/交叉时补语义)"""
    pp = int(round(canon_deg(psi)))
    nm = heading_name(psi)
    if nm.endswith("°"):
        return "%+d°" % pp
    return "%d° %s" % (pp, nm)


def tick_rings(ring_vals, rmax, min_frac=0.085, max_ticks=9):
    """从距离环中挑出间隔足够大的标注环 (避免圆心附近标签堆叠)"""
    if not ring_vals:
        return []
    gap = rmax * min_frac
    out = [ring_vals[-1]]
    for r in reversed(ring_vals[:-1]):
        if out[0] - r >= gap:
            out.insert(0, r)
    while len(out) > max_ticks:
        out = out[::2]
    return out


def fmt_ft(x):
    """距离/高度显示格式"""
    if x >= 1000:
        return "{:,.0f}".format(x)
    return "{:.0f}".format(x)


def fmt_num(x, nd=2):
    """小数显示: 固定 nd 位后去掉多余的 0 (2.00 -> 2, 1.50 -> 1.5, 4/3 -> 1.33)"""
    s = ("%.*f" % (nd, float(x))).rstrip("0").rstrip(".")
    return s or "0"


def ratio_pair(r, nd=2):
    """速度比数值 r (= 本机速度/入侵者速度) -> "本机:入侵者" 标签。

    标签**保证有一边恰为 1**, 且 1 落在速度较小的一方, 另一侧为小数倍率:
        r = 0.75 -> "1:1.33"   本机慢, 入侵者速度是本机的 1.33 倍
        r = 2.0  -> "2:1"      本机快, 本机速度是入侵者的 2 倍
        r = 1.0  -> "1:1"      同速
    """
    r = float(r)
    if r <= 1.0:
        return "1:%s" % fmt_num(1.0 / r, nd)
    return "%s:1" % fmt_num(r, nd)


def ratio_labels(vals):
    """为一组速度比生成互不重复的显示标签 (必要时自动提高小数位)"""
    for nd in (2, 3, 4):
        labs = [ratio_pair(v, nd) for v in vals]
        if len(set(labs)) == len(labs):
            return labs
    return [ratio_pair(v, 6) for v in vals]


def cell_edges(centers):
    """由 bin 中心生成 pcolormesh 边界 (相邻中点), 使格宽与离散步长成正比"""
    centers = np.asarray(centers, dtype=float)
    if len(centers) == 1:
        return np.array([centers[0] - 0.5, centers[0] + 0.5])
    diffs = np.diff(centers)
    edges = np.empty(len(centers) + 1)
    edges[0] = centers[0] - diffs[0] / 2.0
    edges[-1] = centers[-1] + diffs[-1] / 2.0
    edges[1:-1] = (centers[:-1] + centers[1:]) / 2.0
    return edges


def arc_mesh(bear_edges, r_edges, sub, steps=BG_ARC_STEPS):
    """背景着色网格: 每个方位 bin 的角边细分为 steps 段, 使色块呈"扇环"。

    极坐标下 pcolormesh 只对顶点做变换, 直接把 bin 的 4 个角点连成四边形会得到
    直边梯形; 这里把角边展开成折线, 内外缘即贴合圆弧。返回:
        TH, RR    —— pcolormesh 角点网格 (弧度 / ft), 已加密
        sub_wide  —— 与网格单元一一对应的动作值 (每个原 bin 横向重复 steps 次)
    """
    edges = np.radians(np.asarray(bear_edges, dtype=float))
    if steps <= 1 or len(edges) < 2:
        TH, RR = np.meshgrid(edges, r_edges)
        return TH, RR, sub
    fine = np.linspace(edges[:-1], edges[1:], int(steps) + 1, axis=1)
    t_edges = np.concatenate([fine[:, :-1].ravel(), fine[-1, -1:]])
    TH, RR = np.meshgrid(t_edges, r_edges)
    return TH, RR, np.repeat(sub, int(steps), axis=1)


def load_data(path):
    """读取状态表 CSV, 返回 (arr, meta)。

    arr 每行: [Range, Rel_Alt, Bearing, Rel_Heading, Int_Spd, Own_Spd,
               Own_Vz, Int_Vz, Tau, H, V]
    Bearing / Rel_Heading 已把 180 归一到 -180。
    """
    rows = []
    with open(path, "r", encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        header = reader.fieldnames or []
        missing = [c for c in STATE_FIELDS + (ACTION_FIELD,) if c not in header]
        if missing:
            raise ValueError("表 %s 缺少列: %s" % (path, ", ".join(missing)))
        for rec in reader:
            h, v = parse_hv(rec.get(ACTION_FIELD, ""))
            try:
                rows.append(
                    (
                        float(rec["Range(ft)"]),
                        float(rec["Rel_Altitude(ft)"]),
                        canon_deg(rec["Bearing(deg)"]),
                        canon_deg(rec["Rel_Heading(deg)"]),
                        float(rec["Intruder_Speed(fps)"]),
                        float(rec["Own_Speed(fps)"]),
                        float(rec["Own_Vert_Rate(fps)"]),
                        float(rec["Int_Vert_Rate(fps)"]),
                        float(rec["Tau(s)"]),
                        h,
                        v,
                    )
                )
            except (KeyError, ValueError):
                continue
    arr = np.array(rows, dtype=np.float64)
    ratios = arr[:, C_OS] / np.where(arr[:, C_IS] == 0, 1.0, arr[:, C_IS])
    meta = {
        "bearings": np.unique(arr[:, C_B]),
        "ranges": np.unique(arr[:, C_R]),
        "headings": np.unique(arr[:, C_H]),
        "alts": np.unique(arr[:, C_A]),
        "taus": np.unique(arr[:, C_T]),
        "own_vz": np.unique(arr[:, C_OV]),
        "int_vz": np.unique(arr[:, C_IV]),
        "ratios": ratios,
        "ratio_list": distinct_ratios(arr),
        "path": path,
    }
    print("成功读取表格: %s" % path)
    print(
        "  共 %d 条规则 | 方位 %d 档 | 距离 %d 档 | 相对航向 %d 档"
        % (len(arr), len(meta["bearings"]), len(meta["ranges"]), len(meta["headings"]))
    )
    safe = (arr[:, C_HC] == 0) & (arr[:, C_VC] == 0)
    print(
        "  无建议 H:0|V:0: %d 条 | 非零动作: %d 条"
        % (int(safe.sum()), int((~safe).sum()))
    )
    print("  不同速度比: %d 档" % len(meta["ratio_list"]))
    return arr, meta


def distinct_ratios(arr):
    """表中实际出现的全部不同速度比。

    返回 [(数值, "本机:入侵者"), ...] 按数值升序; 标签已归一化 —— 慢的一方恰为 1,
    另一侧为小数倍率 (如 "1:1.33" = 入侵者比本机快 1.33 倍, "2.5:1" = 本机快 2.5 倍)。
    """
    vals = set()
    for o, i in zip(arr[:, C_OS], arr[:, C_IS]):
        o, i = float(o), float(i)
        if o <= 0.0 or i <= 0.0:
            continue
        vals.add(round(o / i, 6))
    vals = sorted(vals)
    return list(zip(vals, ratio_labels(vals)))


class AvoidancePolarMap(object):
    """极坐标避障查询器: 手动摆态势(位置/速度方向/速度比) -> 输出本机动作。"""

    def __init__(self, arr, meta, args):
        self.arr = arr
        self.meta = meta
        self.include_safe = bool(args.include_safe)
        self.bg = args.hv  # 'h' -> 背景按水平动作着色; 'v' -> 按垂直动作
        self.display_max = getattr(args, "max_range", None)

        self.bearings = meta["bearings"]
        self.ranges = meta["ranges"]
        self.nB = len(self.bearings)
        self.nR = len(self.ranges)
        self.bear_edges = cell_edges(self.bearings)
        self.range_edges = cell_edges(self.ranges)
        # The table clamps every range below 150 ft to its minimum 100-ft bin.
        if np.isclose(self.ranges[0], 100.0):
            self.range_edges[0] = 0.0
        self.avoid_mask = ~((arr[:, C_HC] == 0) & (arr[:, C_VC] == 0))

        N = len(arr)
        ones = np.ones(N, dtype=bool)

        rlist = meta.get("ratio_list") or [RATIO_FALLBACK]
        self.ratio_vals = [v for v, _ in rlist]
        self.ratio_labels = [lab for _, lab in rlist]

        def numeric_masks(col, values, with_all):
            masks = [None] * (1 if with_all else 0)
            for v in values:
                masks.append(np.isclose(arr[:, col], v))
            return masks

        # 每一维: labels(给滑块显示) / vals / masks(None=不筛选)
        self.dims = {
            "bearing": dict(
                vals=list(self.bearings),
                labels=[bearing_label(b) for b in self.bearings],
                masks=[ones] * self.nB,
                agg=False,
            ),
            "range": dict(
                vals=list(self.ranges),
                labels=[fmt_ft(r) for r in self.ranges],
                masks=[ones] * self.nR,
                agg=False,
            ),
            "heading": dict(
                vals=list(meta["headings"]),
                labels=[heading_label(h) for h in meta["headings"]],
                masks=numeric_masks(C_H, meta["headings"], False),
                agg=False,
            ),
            "ratio": dict(
                vals=list(self.ratio_vals),
                labels=list(self.ratio_labels),
                masks=[
                    np.isclose(meta["ratios"], v, atol=1e-3) for v in self.ratio_vals
                ],
                agg=False,
            ),
            "alt": dict(
                vals=[None] + list(meta["alts"]),
                labels=["全部"] + [fmt_ft(a) for a in meta["alts"]],
                masks=numeric_masks(C_A, meta["alts"], True),
                agg=True,
            ),
        }

        # 初始选中档位 (聚合维默认 index 0 = "全部")
        self.sel = {}
        for key, d in self.dims.items():
            self.sel[key] = 0 if d.get("agg") else (len(d["vals"]) - 1) // 2
        if args.bearing is not None:
            self._set_sel_near("bearing", args.bearing)
        else:
            self._set_sel_near("bearing", 0.0)
        self._set_sel_near("range", 1000.0 if args.range is None else args.range)
        self._set_sel_near(
            "heading", -180.0 if args.rel_heading is None else args.rel_heading
        )
        self._set_sel_ratio(args.ratio if args.ratio is not None else "1:1")
        # Exact fixed heights; absent levels remain empty rather than snapping.
        self.dims["alt"] = dict(
            vals=list(FIXED_ALTITUDES),
            labels=[fmt_ft(a) for a in FIXED_ALTITUDES],
            masks=numeric_masks(C_A, FIXED_ALTITUDES, False),
            agg=False,
        )
        self.sel["alt"] = 0

        self.ratios_arr = meta["ratios"]
        self.gridH = None
        self.gridV = None
        self.fracH = None
        self.fracV = None
        self.cnt = None

    # ------------------------------------------------------------------ 选择工具
    def _set_sel_near(self, key, value):
        vals = self.dims[key]["vals"]
        arr = np.array([np.nan if v is None else v for v in vals], dtype=float)
        self.sel[key] = int(np.nanargmin(np.abs(arr - float(value))))

    def _set_sel_ratio(self, text):
        """接受 "1:1.33" / "2:1" (本机:入侵者, 一边恒为 1) 或纯数值 (如 0.75)"""
        t = str(text).strip().replace(" ", "").replace("：", ":")
        labels = [s.replace(" ", "") for s in self.ratio_labels]
        if t in labels:
            self.sel["ratio"] = labels.index(t)
            return
        if ":" in t:
            a, b = t.split(":", 1)
            try:
                val = float(a) / float(b)
            except (ValueError, ZeroDivisionError):
                return
        else:
            try:
                val = float(t)
            except ValueError:
                return
        self._set_sel_near("ratio", val)

    def _val(self, key):
        return self.dims[key]["vals"][self.sel[key]]

    def _label(self, key):
        return self.dims[key]["labels"][self.sel[key]]

    # ------------------------------------------------------------------ 数据切片与聚合
    # 参与筛选的状态维 (Tau / 本机Vz / 入侵Vz 恒按"全部"聚合, 不可选)
    FILTER_KEYS = ("heading", "ratio", "alt")

    def _filter_mask(self):
        """当前切片对应的行掩码 (方位/距离是图面坐标轴, 不作为筛选条件)"""
        mask = np.ones(len(self.arr), dtype=bool)
        for key in self.FILTER_KEYS:
            m = self.dims[key]["masks"][self.sel[key]]
            if m is not None:
                mask &= m
        if not self.include_safe:
            mask &= self.avoid_mask
        return mask

    def aggregate(self):
        """按当前切片, 对每个 (距离×方位) 区块求 H/V 动作众数。"""
        idx = np.nonzero(self._filter_mask())[0]
        nR, nB = self.nR, self.nB
        gridH = np.full((nR, nB), -1, dtype=int)
        gridV = np.full((nR, nB), -1, dtype=int)
        fracH = np.zeros((nR, nB))
        fracV = np.zeros((nR, nB))
        cnt = np.zeros((nR, nB), dtype=int)
        if idx.size:
            ri = np.searchsorted(self.ranges, self.arr[idx, C_R])
            bi = np.searchsorted(self.bearings, self.arr[idx, C_B])
            hc = self.arr[idx, C_HC].astype(int)
            vc = self.arr[idx, C_VC].astype(int)
            histH = np.zeros((nR, nB, len(H_COLORS)), dtype=int)
            histV = np.zeros((nR, nB, len(V_COLORS)), dtype=int)
            np.add.at(histH, (ri, bi, hc), 1)
            np.add.at(histV, (ri, bi, vc), 1)
            totH = histH.sum(axis=2)
            pair_hist = np.zeros((nR, nB, len(H_COLORS) * len(V_COLORS)), dtype=int)
            np.add.at(pair_hist, (ri, bi, hc * len(V_COLORS) + vc), 1)
            pair_mode = pair_hist.argmax(axis=2)
            selected_h, selected_v = (
                pair_mode // len(V_COLORS),
                pair_mode % len(V_COLORS),
            )
            gridH = np.where(totH > 0, selected_h, -1)
            gridV = np.where(totH > 0, selected_v, -1)
            fracH = np.take_along_axis(histH, selected_h[..., None], axis=2)[
                ..., 0
            ] / np.maximum(totH, 1)
            fracV = np.take_along_axis(histV, selected_v[..., None], axis=2)[
                ..., 0
            ] / np.maximum(totH, 1)
            cnt = totH
        self.gridH, self.gridV = gridH, gridV
        self.fracH, self.fracV = fracH, fracV
        self.cnt = cnt
        return idx

    def current_pair(self):
        """当前选中位置的 (H, V, 命中规则数, H一致度, V一致度)"""
        ri, bi = self.sel["range"], self.sel["bearing"]
        h = int(self.gridH[ri, bi])
        v = int(self.gridV[ri, bi])
        return (
            h,
            v,
            int(self.cnt[ri, bi]),
            float(self.fracH[ri, bi]),
            float(self.fracV[ri, bi]),
        )

    # ------------------------------------------------------------------ 图面与控件
    SLIDER_NAMES = {
        "bearing": "方位",
        "range": "距离",
        "heading": "入侵方向",
        "ratio": "速度比",
        "alt": "相对高度",
    }

    def build(self):
        self.fig = plt.figure(figsize=(24, 17), facecolor="white")
        self.views = []
        for i, altitude in enumerate(FIXED_ALTITUDES):
            row, col = divmod(i, 3)
            x, y = 0.025 + col * 0.33, 0.60 - row * 0.40
            axp = self.fig.add_axes([x, y, 0.285, 0.265], projection="polar")
            pos = axp.get_position()
            axo = self.fig.add_axes(pos.bounds, frameon=False, zorder=6)
            text = self.fig.add_axes([x, y - 0.065, 0.30, 0.055], frameon=False)
            self.views.append((axp, axo, text))
        self.legend_ax = self.fig.add_axes([0.70, 0.20, 0.28, 0.30], frameon=False)
        self.sliders = {}
        for key, x, y in (
            ("bearing", 0.08, 0.105),
            ("range", 0.57, 0.105),
            ("heading", 0.08, 0.060),
            ("ratio", 0.57, 0.060),
        ):
            d = self.dims[key]
            sl = Slider(
                self.fig.add_axes([x, y, 0.32, 0.018]),
                self.SLIDER_NAMES[key],
                0,
                len(d["vals"]) - 1,
                valinit=self.sel[key],
                valstep=1,
                color="#5C6BC0",
            )
            sl.on_changed(self._make_cb(key))
            self.sliders[key] = sl
        self.fig.canvas.mpl_connect("key_press_event", self.on_key)
        self.fig.canvas.mpl_connect("resize_event", self._on_resize)

    # ------------------------------------------------------------------ 屏幕坐标工具
    def _frac(self, theta_deg, r):
        """极坐标数据点 -> 该 axes 的 fraction 坐标"""
        px = self.axp.transData.transform((math.radians(theta_deg), r))
        return self.axp.transAxes.inverted().transform(px)

    def _shift(self, fr, hdg_deg, length_px):
        """从 fraction 点 fr 出发, 朝屏幕方向 hdg(0=上, 正=顺时针) 前进 length_px 像素"""
        p = self.axo.transAxes.transform(fr)
        a = math.radians(hdg_deg)
        q = self.axo.transAxes.inverted().transform(
            (p[0] + math.sin(a) * length_px, p[1] + math.cos(a) * length_px)
        )
        return q

    def _arrow(self, tail_fr, hdg_deg, length_px, color, lw=2.4, label=None):
        head = self._shift(tail_fr, hdg_deg, length_px)
        self.axo.annotate(
            "",
            xy=head,
            xytext=tail_fr,
            xycoords="axes fraction",
            textcoords="axes fraction",
            arrowprops=dict(
                arrowstyle="-|>",
                color=color,
                lw=lw,
                shrinkA=0,
                shrinkB=0,
                mutation_scale=18,
            ),
        )
        if label:
            self.axo.text(
                head[0],
                head[1],
                label,
                color=color,
                fontsize=9,
                ha="center",
                va="center",
                fontweight="bold",
                zorder=8,
            )

    # ------------------------------------------------------------------ 绘制: 极坐标图
    def _rmax(self):
        if self.display_max is not None:
            return self.display_max
        return max(R_DISPLAY_BASE, float(self._val("range")) * 1.15)

    @staticmethod
    def _lbl_box():
        """标注文字的白底, 保证压在彩色区块上仍清晰"""
        return dict(
            boxstyle="round,pad=0.22", facecolor="white", edgecolor="none", alpha=0.78
        )

    def draw_polar(self):
        axp = self.axp
        axp.clear()
        axp.set_theta_zero_location("N")
        axp.set_theta_direction(-1)
        axp.set_facecolor(NO_DATA_COLOR)
        cmap, norm, _ = self._cmap_norm()
        # 显式指定 masked 格(无数据)填充色, 不依赖 axes 底色这条隐式路径
        cmap.set_bad(NO_DATA_COLOR)
        grid = self.gridH if self.bg == "h" else self.gridV

        rmax = self._rmax()
        k = max(1, int((self.ranges <= rmax).sum()))
        r_edges = self.range_edges[: k + 1]
        rmax = (
            float(r_edges[-1])
            if self.display_max is None
            else min(rmax, float(r_edges[-1]))
        )
        sub = grid[:k, :]
        # 背景按"扇环"铺色 (角边加密, 避免直边梯形)
        TH, RR, cells = arc_mesh(self.bear_edges, r_edges, sub)
        masked = np.ma.masked_where(cells < 0, cells)
        axp.pcolormesh(TH, RR, masked, cmap=cmap, norm=norm, shading="flat", zorder=1)

        axp.set_ylim(0, rmax)
        ring_vals = list(self.ranges[:k])
        ticks = tick_rings(ring_vals, rmax)
        axp.set_yticks(ticks)
        axp.set_yticklabels([fmt_ft(t) for t in ticks], fontsize=8, color="#616161")
        axp.set_rlabel_position(212)
        axp.set_thetagrids(
            [0, 90, 180, 270], ["前 0°", "右 90°", "后 180°", "左 270°"], fontsize=10
        )
        axp.grid(True, color="white", lw=0.8, alpha=0.85)
        axp.tick_params(labelsize=9, colors="#424242")
        try:
            axp.spines["polar"].set_color("#9E9E9E")
        except KeyError:
            pass

        # 选中区块高亮
        bi, ri = self.sel["bearing"], self.sel["range"]
        if ri < k:
            t0, t1 = self.bear_edges[bi], self.bear_edges[bi + 1]
            r0, r1 = self.range_edges[ri], self.range_edges[ri + 1]
            tt = np.linspace(t0, t1, 30)
            axp.plot(
                np.radians(tt), np.full_like(tt, r1), color="#212121", lw=2.6, zorder=4
            )
            axp.plot(
                np.radians(tt), np.full_like(tt, r0), color="#212121", lw=2.6, zorder=4
            )
            axp.plot(np.radians([t0, t0]), [r0, r1], color="#212121", lw=2.6, zorder=4)
            axp.plot(np.radians([t1, t1]), [r0, r1], color="#212121", lw=2.6, zorder=4)

        label = (
            "水平动作 H (本机转向/直飞)"
            if self.bg == "h"
            else "垂直动作 V (本机爬升/下降)"
        )
        axp.set_title(label, fontsize=12.5, color="#263238", pad=10)

    # ------------------------------------------------------------------ 绘制: 本机/入侵者与速度矢量
    def draw_overlay(self):
        axo = self.axo
        axo.clear()
        axo.set_xlim(0, 1)
        axo.set_ylim(0, 1)
        axo.set_xticks([])
        axo.set_yticks([])
        axo.patch.set_visible(False)

        bearing = float(self._val("bearing"))
        rng = float(self._val("range"))
        psi = float(self._val("heading"))

        fr_own = self._frac(0.0, 0.0)
        self._arrow(fr_own, 0.0, 52, OWN_COLOR, lw=2.8)
        axo.scatter(
            [fr_own[0]],
            [fr_own[1]],
            s=110,
            marker="o",
            facecolor=OWN_COLOR,
            edgecolor="white",
            lw=1.6,
            zorder=8,
        )
        t = self._shift(fr_own, 180.0, 26)
        axo.text(
            t[0],
            t[1],
            "本机",
            color=OWN_COLOR,
            fontsize=10,
            fontweight="bold",
            ha="center",
            va="top",
            zorder=8,
            bbox=self._lbl_box(),
        )

        fr_int = self._frac(bearing, rng)
        self._arrow(fr_int, psi, 52, INT_COLOR, lw=2.8)
        axo.scatter(
            [fr_int[0]],
            [fr_int[1]],
            s=170,
            marker="D",
            facecolor=INT_COLOR,
            edgecolor="white",
            lw=1.6,
            zorder=8,
        )
        t2 = self._shift(fr_int, 90.0, 18)
        axo.text(
            t2[0],
            t2[1],
            "入侵者",
            color=INT_COLOR,
            fontsize=10,
            fontweight="bold",
            ha="left",
            va="center",
            zorder=8,
            bbox=self._lbl_box(),
        )
        t3 = self._shift(fr_int, 270.0, 24)
        axo.text(
            t3[0],
            t3[1],
            "%s\n%sft" % (bearing_name(bearing), fmt_ft(rng)),
            color="#37474F",
            fontsize=8.5,
            ha="right",
            va="center",
            zorder=8,
            bbox=self._lbl_box(),
        )

        hdg_tip = self._shift(fr_int, psi, 68)
        axo.text(
            hdg_tip[0],
            hdg_tip[1],
            heading_name(psi),
            color=INT_COLOR,
            fontsize=9,
            fontweight="bold",
            ha="center",
            va="center",
            zorder=8,
            bbox=self._lbl_box(),
        )

    # ------------------------------------------------------------------ 绘制: 右侧动作输出面板
    def _cmap_norm(self):
        if self.bg == "h":
            return (
                ListedColormap(H_COLORS),
                BoundaryNorm(np.arange(-0.5, len(H_COLORS) + 0.5, 1.0), len(H_COLORS)),
                H_NAMES,
            )
        return (
            ListedColormap(V_COLORS),
            BoundaryNorm(np.arange(-0.5, len(V_COLORS) + 0.5, 1.0), len(V_COLORS)),
            V_NAMES,
        )

    def _chip(self, cx, cy, w, h, title, sub, color):
        ax = self.axpanel
        ax.add_patch(
            FancyBboxPatch(
                (cx - w / 2.0, cy - h / 2.0),
                w,
                h,
                boxstyle="round,pad=0.010,rounding_size=0.03",
                linewidth=1.6,
                edgecolor="#263238",
                facecolor=color,
                zorder=3,
            )
        )
        ax.text(
            cx,
            cy,
            title,
            ha="center",
            va="center",
            color="white",
            fontsize=20,
            fontweight="bold",
            zorder=4,
        )
        if sub:
            ax.text(
                cx,
                cy - h / 2.0 - 0.042,
                sub,
                ha="center",
                va="center",
                color="#37474F",
                fontsize=11.5,
                zorder=4,
            )

    def draw_panel(self):
        ax = self.axpanel
        ax.clear()
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)
        ax.set_xticks([])
        ax.set_yticks([])
        for sp in ax.spines.values():
            sp.set_edgecolor("#BDBDBD")

        h, v, n, fh, fv = self.current_pair()
        ax.text(
            0.5,
            0.975,
            "本机推荐动作",
            ha="center",
            va="top",
            fontsize=19,
            fontweight="bold",
            color="#263238",
        )

        lines = (
            "入侵者位置:  %s    距离 %s ft"
            % (self._label("bearing"), fmt_ft(float(self._val("range")))),
            "入侵者速度方向:  %s      速度比 (本机:入侵者):  %s"
            % (
                self._label("heading"),
                self._label("ratio"),
            ),
            "相对高度: %s" % (self._label("alt"),),
        )
        y = 0.912
        for ln in lines:
            ax.text(0.03, y, ln, ha="left", va="top", fontsize=11.5, color="#37474F")
            y -= 0.046

        if n == 0:
            self._chip(0.26, 0.655, 0.42, 0.115, "H: --", "无避障规则", "#9E9E9E")
            self._chip(0.74, 0.655, 0.42, 0.115, "V: --", "无避障规则", "#9E9E9E")
            ax.text(
                0.5,
                0.50,
                "无匹配规则或记录已被过滤，无法判断安全性",
                ha="center",
                va="center",
                fontsize=13,
                color="#609B41",
            )
        else:
            self._chip(0.26, 0.655, 0.42, 0.115, "H:%d" % h, H_NAMES[h], H_COLORS[h])
            self._chip(0.74, 0.655, 0.42, 0.115, "V:%d" % v, V_NAMES[v], V_COLORS[v])
            ax.text(
                0.5,
                0.505,
                "动作组合:  H:%d | V:%d" % (h, v),
                ha="center",
                va="center",
                fontsize=14,
                fontweight="bold",
                color="#263238",
            )

        names = H_NAMES if self.bg == "h" else V_NAMES
        colors = H_COLORS if self.bg == "h" else V_COLORS
        ax.text(
            0.03,
            0.338,
            "背景配色 = %s" % ("水平动作 H" if self.bg == "h" else "垂直动作 V"),
            ha="left",
            va="center",
            fontsize=11,
            fontweight="bold",
            color="#263238",
        )
        ncol = 1 if len(colors) <= 4 else 2
        per = int(np.ceil(len(colors) / float(ncol)))
        for i, c in enumerate(colors):
            col = i // per
            row = i % per
            x = 0.05 + col * 0.47
            yy = 0.288 - row * 0.043
            ax.add_patch(
                Rectangle(
                    (x, yy - 0.014),
                    0.035,
                    0.028,
                    facecolor=c,
                    edgecolor="#263238",
                    lw=0.6,
                    zorder=3,
                )
            )
            ax.text(
                x + 0.05,
                yy,
                "%d  %s" % (i, names[i]),
                fontsize=10,
                va="center",
                color="#37474F",
            )

        # 无数据色块: 不属于动作码, 单独一行放在动作码图例正下方
        yy = 0.288 - per * 0.043 - 0.012
        ax.add_patch(
            Rectangle(
                (0.05, yy - 0.014),
                0.035,
                0.028,
                facecolor=NO_DATA_COLOR,
                edgecolor="#BDBDBD",
                lw=0.6,
                zorder=3,
            )
        )
        ax.text(
            0.10,
            yy,
            "无数据 (该区块当前切片下无避障规则)",
            fontsize=10,
            va="center",
            color="#546E7A",
        )

        ax.text(
            0.5,
            0.015,
            "速度比 = 本机:入侵者, 慢者记为 1 (如 1:1.33);  该比例下所有绝对速度组合按众数汇总;  无建议记录: %s"
            % ("开" if self.include_safe else "关"),
            ha="center",
            va="bottom",
            fontsize=9.5,
            color="#78909C",
        )

    # ------------------------------------------------------------------ 刷新与交互
    def update(self):
        self.summaries = []
        for i, (axp, axo, text) in enumerate(self.views):
            self.sel["alt"] = i
            self.axp, self.axo = axp, axo
            self.aggregate()
            self.draw_polar()
            self.draw_overlay()
            altitude = FIXED_ALTITUDES[i]
            exact = np.any(np.isclose(self.arr[:, C_A], altitude))
            axp.set_title(
                "相对高度 %+.0f ft%s"
                % (altitude, "" if exact else " · 无精确高度数据"),
                fontsize=13,
                pad=30,
            )
            text.clear()
            text.axis("off")
            h, v, n, fh, fv = self.current_pair()
            if n:
                result = "H:%d %s / V:%d %s" % (h, H_NAMES[h], v, V_NAMES[v])
            else:
                result = "无匹配规则或记录已被过滤，无法判断安全性"
            text.text(0.5, 0.5, result, ha="center", va="center", fontsize=10)
            self.summaries.append(self.summary())
        ax = self.legend_ax
        ax.clear()
        ax.axis("off")
        names = H_NAMES if self.bg == "h" else V_NAMES
        colors = H_COLORS if self.bg == "h" else V_COLORS
        ax.text(
            0,
            1,
            "背景：%s动作众数" % ("水平 H" if self.bg == "h" else "垂直 V"),
            fontsize=14,
            weight="bold",
        )
        for j, color in enumerate(colors + [NO_DATA_COLOR]):
            y = 0.88 - j * 0.078
            ax.add_patch(Rectangle((0, y - 0.02), 0.06, 0.04, color=color))
            label = "%d %s" % (j, names[j]) if j < len(colors) else "已过滤"
            ax.text(0.09, y, label, va="center", fontsize=11)
        for key, sl in self.sliders.items():
            sl.valtext.set_text(self._label(key))
        self.fig.canvas.draw_idle()

    def _make_cb(self, key):
        def cb(val):
            idx = int(round(val))
            if idx != self.sel[key]:
                self.sel[key] = idx
                self.update()
            else:
                # Slider.set_val 会先把 valtext 写成数字, 这里确保回显始终是语义标签
                self.sliders[key].valtext.set_text(self.dims[key]["labels"][idx])
                self.fig.canvas.draw_idle()

        return cb

    def _nudge(self, key, delta):
        n = len(self.dims[key]["vals"])
        idx = int(np.clip(self.sel[key] + delta, 0, n - 1))
        if idx != self.sel[key]:
            self.sliders[key].set_val(idx)

    def _on_resize(self, event):
        """画布尺寸变化: 箭头按像素长度定义, 需要重算 overlay"""
        if self.gridH is not None:
            self.update()

    def on_key(self, event):
        k = event.key
        if k in ("q", "escape"):
            plt.close(self.fig)
        elif k == "s":
            self.save()
        elif k in ("a", "A"):
            self.include_safe = not self.include_safe
            self.update()
        elif k in ("h", "H"):
            self.bg = "h"
            self.update()
        elif k in ("v", "V"):
            self.bg = "v"
            self.update()
        elif k == "left":
            self._nudge("bearing", -1)
        elif k == "right":
            self._nudge("bearing", 1)
        elif k == "up":
            self._nudge("range", 1)
        elif k == "down":
            self._nudge("range", -1)

    def save(self, path=None):
        if path is None:
            if not os.path.isdir(OUT_DIR):
                os.makedirs(OUT_DIR)
            path = os.path.join(OUT_DIR, "avoidance_polar_%s.png" % self.bg)
        self.fig.savefig(path, dpi=150, facecolor="white")
        print("已保存图片: %s" % path)
        return path

    def summary(self):
        h, v, n, _, _ = self.current_pair()
        if n == 0:
            act = "H:-- | V:--  (无匹配规则或已过滤，无法判断安全性)"
        else:
            act = "H:%d %s | V:%d %s" % (h, H_NAMES[h], v, V_NAMES[v])
        return "方位 %s | 距离 %s ft | 速度方向 %s | 速度比 %s | 高度 %s -> %s" % (
            self._label("bearing"),
            fmt_ft(float(self._val("range"))),
            self._label("heading"),
            self._label("ratio"),
            self._label("alt"),
            act,
        )

    def run(self):
        self.build()
        self.update()
        self.fig.suptitle(
            "避障决策极坐标查询器 —— 五个固定相对高度，共享位置 / 航向 / 速度比",
            fontsize=15,
            fontweight="bold",
            y=0.985,
        )
        self.fig.text(
            0.5,
            0.010,
            "按键:  A 无建议记录开关 | H / V 切换背景动作 | ← → 调方位 | ↑ ↓ 调距离 | S 存图 | Q 退出",
            ha="center",
            fontsize=10.5,
            color="#546E7A",
        )
        return self.fig


# ---------------------------------------------------------------------- 命令行入口
def build_argparser():
    p = argparse.ArgumentParser(
        description="避障决策极坐标查询器: 手动选定入侵者位置/速度方向/速度比 -> 输出本机动作"
    )
    p.add_argument("--table", default=DEFAULT_TABLE, help="状态表 CSV 路径")
    p.add_argument(
        "--include-safe",
        action="store_true",
        default=True,
        help="背景纳入无建议记录 H:0|V:0（默认开启）",
    )
    p.add_argument(
        "--avoid-only",
        action="store_false",
        dest="include_safe",
        help="仅显示有动作的记录，隐藏无建议记录",
    )
    p.add_argument(
        "--hv", choices=("h", "v"), default="h", help="背景着色依据的动作类型"
    )
    p.add_argument("--bearing", type=float, default=None, help="初始方位角 (deg)")
    p.add_argument("--range", type=float, default=None, help="初始距离 (ft)")
    p.add_argument(
        "--max-range",
        type=float,
        default=None,
        help="固定显示半径 (ft)，例如 1000；不随选中距离扩展",
    )
    p.add_argument("--rel-heading", type=float, default=None, help="初始相对航向 (deg)")
    p.add_argument(
        "--ratio",
        default=None,
        help="初始速度比: 本机:入侵者, 一边恒为 1 (如 1:1.33 / 2:1) 或数值 (如 0.75)",
    )
    p.add_argument("-o", "--output", default=None, help="输出 PNG 路径 (无界面渲染)")
    return p


def main(argv=None):
    parser = build_argparser()
    args = parser.parse_args(argv)
    if args.max_range is not None and (
        not math.isfinite(args.max_range) or args.max_range <= 0
    ):
        parser.error("--max-range 必须为正的有限数")
    if not os.path.isfile(args.table):
        print("未找到表格文件: %s" % args.table)
        return 1

    arr, meta = load_data(args.table)
    viewer = AvoidancePolarMap(arr, meta, args)
    viewer.run()
    for summary in viewer.summaries:
        print("当前选择 -> %s" % summary)

    if args.output:
        out = os.path.abspath(args.output)
        d = os.path.dirname(out)
        if d and not os.path.isdir(d):
            os.makedirs(d)
        viewer.save(out)
        plt.close(viewer.fig)
        return 0

    plt.show()
    return 0


if __name__ == "__main__":
    sys.exit(main())
