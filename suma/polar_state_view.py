"""
polar_state_view.py —— 水平极坐标 + 垂直剖面 交互式状态浏览器
==================================================

数据源: my_lightweight_table_dense.csv (离散化状态表, 每行 = 一个"当前状态"+本机推荐动作)

用法:
    python polar_state_view.py                                  # 交互窗口(全表浏览)
    python polar_state_view.py --filter "Range<=3000,Bearing=0,Rel_Heading=-180"
    python polar_state_view.py --filter "H>=2"                  # 只看需要转向的状态
    python polar_state_view.py --index 123 --output out.png     # 无界面渲染某一行
    (Windows cmd 里多条件建议用逗号分隔; & 分隔在部分 shell 中需加引号/转义)

交互按键:
    ← / →        上一行 / 下一行
    ↑ / ↓        前/后 跳 10 行
    PgUp / PgDn  前/后 跳 100 行
    Home / End   跳到首行 / 尾行
    N / P        跳到下一个 / 上一个"非安全"动作行 (H或V动作码 != 0)
    S            保存当前行为 PNG
    Q / Esc      退出

坐标系约定(与仓库内可视化/图注一致):
    - 机头朝上显示: 图面 0° = 本机机头方向; 正角度(顺时针) = 右侧, 负角度 = 左侧
    - 入侵者位置: 极坐标 (Range, Bearing), Bearing 0=正前方, 左负右正
    - 入侵者机头方向: Rel_Heading 相对本机机头旋转, 0=同向, ±180=对头, ±90=交叉
    - 速度箭头一律等长(只表达方向/机动意图), 具体速度看机旁数值文字
    - 速度与垂直率统一使用 fps 单位显示(机旁标注与右侧状态栏均不再换算 kt)
    - 水平俯视图只画 位置 / 航向 / 速度 / 转向示意, 不再标注相对高度与 τ
      (相对高度看右侧垂直剖面纵轴; τ 仅参与风险等级判定, 不在图上显示)
    - 垂直态势图(水平态势右侧): 横轴=水平距离 Range, 纵轴=相对高度 Rel_Alt;
      入侵者的升降箭头等长(只表示升/降方向), 具体垂直率看旁注数值文字;
      本机不画方向箭头, 本机垂直率仅以 "本机 Vz" 旁注文字表达
"""

import argparse
import csv
import math
import os
import re
import sys

import matplotlib

# 无界面渲染时使用 Agg 后端(必须在 pyplot 导入前设置)
if "--output" in sys.argv or "-o" in sys.argv:
    matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.widgets import Slider

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DEFAULT_TABLE = os.path.join(SCRIPT_DIR, "my_lightweight_table_dense.csv")
DEFAULT_OUT_DIR = os.path.join(SCRIPT_DIR, "output", "polar_visuals")

plt.rcParams["font.sans-serif"] = ["Microsoft YaHei", "SimHei", "Arial Unicode MS"]
plt.rcParams["axes.unicode_minus"] = False

# ---------------- 动作命名与配色 (与 visualize_dense.py 一致) ----------------
H_NAMES = {
    0: "NO ADVISORY(安全)",
    1: "CLEAR(解除)",
    2: "TURN RIGHT(右转)",
    3: "TURN LEFT(左转)",
    4: "STRAIGHT(直飞)",
}
V_NAMES = {
    0: "NO ADVISORY(安全)",
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

# 距离环候选(自适应取 >= 1.3*Range 的最小档, 给速度箭头留空间)
RING_CANDIDATES = (
    200,
    300,
    500,
    800,
    1000,
    1500,
    2000,
    3000,
    4000,
    5000,
    8000,
    10000,
    15000,
    20000,
    30000,
    40000,
    50000,
    80000,
    100000,
    120000,
)

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

# 供 --filter 使用的别名
FIELD_ALIAS = {
    "R": "Range(ft)",
    "Range": "Range(ft)",
    "Z": "Rel_Altitude(ft)",
    "Alt": "Rel_Altitude(ft)",
    "Rel_Altitude": "Rel_Altitude(ft)",
    "Rel_Alt": "Rel_Altitude(ft)",
    "B": "Bearing(deg)",
    "Bearing": "Bearing(deg)",
    "Psi": "Rel_Heading(deg)",
    "Hdg": "Rel_Heading(deg)",
    "Rel_Heading": "Rel_Heading(deg)",
    "Int_Spd": "Intruder_Speed(fps)",
    "Intruder_Speed": "Intruder_Speed(fps)",
    "Own_Spd": "Own_Speed(fps)",
    "Own_Speed": "Own_Speed(fps)",
    "Own_Vert": "Own_Vert_Rate(fps)",
    "Int_Vert": "Int_Vert_Rate(fps)",
    "Tau": "Tau(s)",
}

KTS_TO_FPS = 1.68781
FPS_TO_KTS = 1.0 / KTS_TO_FPS
# 注: 界面(机旁标注 + 右侧状态栏)统一显示 fps, 上面两个换算常数仅作参考/后续扩展用


# ---------------- 基础工具 ----------------
def parse_action(s):
    """把 'H:2 | V:4' 解析成 (2, 4)"""
    try:
        h = int(s.split("|")[0].split(":")[1])
        v = int(s.split("|")[1].split(":")[1])
        return h, v
    except Exception:
        return 0, 0


def parse_float(v):
    """容错转换 float(支持 inf/-1 等)"""
    try:
        return float(v)
    except Exception:
        return math.nan


def load_table(path):
    """读取状态表 CSV, 返回 list[dict]"""
    rows = []
    with open(path, "r", encoding="utf-8-sig", newline="") as f:
        for line_no, raw in enumerate(csv.DictReader(f), start=2):
            try:
                h, v = parse_action(raw.get("Recommended_Action", ""))
                row = {"line": line_no, "h": h, "v": v}
                for key in STATE_FIELDS:
                    row[key] = parse_float(raw.get(key, ""))
                if math.isnan(row["Range(ft)"]):
                    continue
                rows.append(row)
            except Exception as e:  # noqa
                print(f"跳过无法解析的第 {line_no} 行: {e}")
    print(f"成功读取表格: {path}，共 {len(rows)} 行状态")
    return rows


def bearing_name(b):
    """方位角 -> 中文语义 (0=正前, 正=右侧, 负=左侧)"""
    bb = ((int(round(b)) + 180) % 360) - 180
    if bb == 0:
        return "正前方"
    if bb == 90:
        return "右侧"
    if bb == -90:
        return "左侧"
    if bb in (180, -180):
        return "正后方"
    return f"{bb:+d}°"


def heading_name(psi):
    """相对航向 -> 中文语义 (0=同向, ±90=交叉, ±180=对头)"""
    pp = ((int(round(psi)) + 180) % 360) - 180
    if pp == 0:
        return "同向"
    if pp == 90:
        return "右交叉"
    if pp == -90:
        return "左交叉"
    if pp in (180, -180):
        return "对头"
    return f"{pp:+d}°"


def fmt_ft(x):
    if math.isinf(x):
        return "∞"
    return f"{x:,.0f}"


def urgency_of(row):
    """按 τ/动作给一个简单的风险等级"""
    tau = row["Tau(s)"]
    h, v = row["h"], row["v"]
    if tau < 0 or math.isinf(tau):
        return "#2E7D32", "安全区(远离/无冲突)"
    if h in (2, 3) or v in (2, 3, 4, 5, 6, 7):
        if tau <= 20:
            return "#C62828", "告警 RA 区 (τ≤20s)"
        if tau <= 35:
            return "#EF6C00", "警戒区 (20s<τ≤35s)"
    return "#2E7D32", "安全区"


# ---------------- 状态过滤 ----------------
_COND_RE = re.compile(r"^\s*([A-Za-z_]+)\s*(<=|>=|==|=|<|>)\s*(-?\d+(?:\.\d+)?)\s*$")


def _eval_cond(row, field, op, val):
    if field == "H":
        x = float(row["h"])
    elif field == "V":
        x = float(row["v"])
    else:
        x = row[field]
    if op in ("=", "=="):
        return abs(x - val) < 1e-9
    if op == "<":
        return x < val
    if op == ">":
        return x > val
    if op == "<=":
        return x <= val
    if op == ">=":
        return x >= val
    return False


def parse_filter(expr):
    """把 'Range<=3000&Rel_Heading=-180,H>=2' 编译成 (row)->bool 谓词"""
    if not expr or not expr.strip():
        return None
    conds = []
    for part in re.split(r"[,&]", expr):
        part = part.strip()
        if not part:
            continue
        m = _COND_RE.match(part)
        if not m:
            print(f"警告: 无法识别的过滤条件 '{part}'，已忽略")
            continue
        fname, op, vstr = m.groups()
        if fname == "H":
            field = "H"
        elif fname == "V":
            field = "V"
        elif fname in FIELD_ALIAS:
            field = FIELD_ALIAS[fname]
        else:
            print(f"警告: 未知字段 '{fname}'，已忽略该条件")
            continue
        conds.append((field, op, float(vstr)))
    if not conds:
        return None

    def pred(row):
        return all(_eval_cond(row, f, o, v) for f, o, v in conds)

    return pred


# ---------------- 视图辅助 ----------------
def choose_rmax(r):
    """根据入侵机距离选择图幅半径(留 30% 余量给速度箭头)"""
    need = r * 1.30
    for c in RING_CANDIDATES:
        if c >= need:
            return float(c)
    return float(RING_CANDIDATES[-1])


def safe_deg(d):
    """归一化到 [0, 360)"""
    return d % 360.0


class PolarStateViewer(object):
    """交互/无界面渲染控制器"""

    def __init__(self, rows, own_heading=0.0, filter_expr=None):
        self.rows = rows
        self.own_heading = float(own_heading) % 360.0
        if filter_expr:
            pred = parse_filter(filter_expr)
            self.subset = [r for r in rows if pred(r)] if pred else list(rows)
            self.filter_desc = filter_expr
        else:
            self.subset = list(rows)
            self.filter_desc = "(全部)"
        if not self.subset:
            raise RuntimeError("筛选后没有任何状态行!")
        self.i = 0
        self.fig = None
        self.axp = None  # 极坐标轴
        self.axo = None  # 覆盖轴(用于水平文字/像素长度箭头)
        self.axv = None  # 垂直态势轴(侧视: 距离-相对高度)
        self.axpanel = None  # 右侧状态面板
        self.slider = None

    # ---------- 布局 ----------
    def make_figure(self):
        fig = plt.figure(figsize=(16.5, 9.5))
        fig.canvas.manager.set_window_title(
            "2D 状态浏览器(水平+垂直) — ACAS sXu 轻量查询表"
        )
        axp = fig.add_axes([0.028, 0.115, 0.405, 0.705], projection="polar")
        # 覆盖轴: 与极坐标同位置, 用于绘制屏幕方向恒定/水平排版的元素
        axo = fig.add_axes(axp.get_position(), frameon=False)
        axo.set_xticks([])
        axo.set_yticks([])
        axo.set_xlim(0, 1)
        axo.set_ylim(0, 1)
        axo.set_facecolor("none")
        # 垂直态势轴(侧视): 位于水平态势右侧
        axv = fig.add_axes([0.445, 0.115, 0.238, 0.705])
        axpanel = fig.add_axes([0.70, 0.10, 0.288, 0.82])
        axpanel.set_xlim(0, 1)
        axpanel.set_ylim(0, 1)
        axpanel.axis("off")

        axp.set_theta_zero_location("N")  # 0° 在正上方
        axp.set_theta_direction(-1)  # 角度顺时针为正 => 正角在右侧
        axp.set_rlabel_position(135)

        self.fig, self.axp, self.axo, self.axv, self.axpanel = (
            fig,
            axp,
            axo,
            axv,
            axpanel,
        )
        return fig

    def make_slider(self):
        n = len(self.subset)
        axs = self.fig.add_axes([0.028, 0.035, 0.405, 0.028])
        self.slider = Slider(
            axs, "行", 0, n - 1, valinit=self.i, valstep=1, color="#1565C0"
        )
        self.slider.valtext.set_text(f"{self.i + 1}/{n}")
        self.slider.on_changed(self._on_slider)
        return self.slider

    # ---------- 坐标/像素转换工具 ----------
    def _pt_to_frac(self, th_deg, r):
        """极坐标数据点 -> 覆盖轴(0..1)坐标"""
        th = math.radians(safe_deg(th_deg))
        disp = self.axp.transData.transform((th, r))
        return self.axp.transAxes.inverted().transform(disp)

    def _shift_px(self, fr, dx_px, dy_px):
        """在覆盖轴上按屏幕像素偏移一个点"""
        dp = self.axo.transAxes.transform(fr)
        return self.axo.transAxes.inverted().transform((dp[0] + dx_px, dp[1] + dy_px))

    def _shift_data_px(self, ax, x, y, dx_px, dy_px):
        """在普通(非极坐标)轴上按屏幕像素偏移一个数据点"""
        dp = ax.transData.transform((x, y))
        return ax.transData.inverted().transform((dp[0] + dx_px, dp[1] + dy_px))

    def _arrow(self, fr_tail, hdg_deg, length_px, color, lw=3.2, alpha=1.0):
        """绘制等长方向箭头: hdg_deg 为自正上方顺时针旋转的屏幕角
        (显示坐标 y 向上: 0°→上, 90°→右, 180°→下)"""
        rad = math.radians(safe_deg(hdg_deg))
        fr_head = self._shift_px(
            fr_tail, math.sin(rad) * length_px, math.cos(rad) * length_px
        )
        self.axo.annotate(
            "",
            xy=fr_head,
            xytext=fr_tail,
            arrowprops=dict(
                arrowstyle="-|>",
                color=color,
                lw=lw,
                mutation_scale=17,
                shrinkA=0,
                shrinkB=0,
                alpha=alpha,
            ),
        )
        return fr_head

    # ---------- 绘制 ----------
    def _draw_polar(self, row):
        axp = self.axp
        r = row["Range(ft)"]
        b = row["Bearing(deg)"]
        own_hdg = self.own_heading
        intr_ang = safe_deg(own_hdg + b)  # 入侵者所在角度
        rmax = choose_rmax(r)

        axp.set_ylim(0, rmax)
        yticks = sorted({rmax / 2.0, rmax})
        axp.set_yticks(yticks)
        axp.set_yticklabels([fmt_ft(y) for y in yticks], color="#555555", fontsize=10)
        deg_ticks = np.arange(0, 360, 30)
        axp.set_xticks(np.radians(deg_ticks))
        tick_labels = []
        for d in deg_ticks:
            if d == 0:
                tick_labels.append("0°(正前)")
            elif d == 90:
                tick_labels.append("90°")
            elif d == 180:
                tick_labels.append("180°(正后)")
            elif d == 270:
                tick_labels.append("270°")
            else:
                tick_labels.append("")
        axp.set_xticklabels(tick_labels, fontsize=8, color="#444444")
        axp.grid(True, color="#CCCCCC", linestyle="--", alpha=0.7)
        axp.set_facecolor("#FAFCFF")
        axp.set_title(
            "水平态势",
            fontsize=12,
            fontweight="bold",
            pad=24,
            color="#222222",
        )

        # 入侵者位置
        axp.scatter(
            [math.radians(intr_ang)],
            [r],
            s=110,
            marker="D",
            c=INT_COLOR,
            edgecolors="white",
            linewidths=1.2,
            zorder=6,
            label="入侵者",
        )
        # 本机位置
        axp.scatter(
            [math.radians(own_hdg)],
            [0],
            s=260,
            marker="o",
            c=OWN_COLOR,
            edgecolors="white",
            linewidths=1.8,
            zorder=6,
            label="本机",
        )
        axp.legend(
            loc="lower left", bbox_to_anchor=(-0.08, -0.02), fontsize=9, framealpha=0.9
        )

    def _draw_overlay(self, row):
        """覆盖层: 等长速度方向箭头(屏幕方向恒定) + 机旁数值文字 + 转向示意"""
        own_hdg = self.own_heading
        r = row["Range(ft)"]
        b = row["Bearing(deg)"]
        psi = row["Rel_Heading(deg)"]
        own_spd = row["Own_Speed(fps)"]
        int_spd = row["Intruder_Speed(fps)"]

        # 本机/入侵者屏幕位置
        own_fr = self._pt_to_frac(own_hdg, 0)
        intr_ang = safe_deg(own_hdg + b)
        intr_fr = self._pt_to_frac(intr_ang, r)

        # ---- 本机等长速度方向箭头 + 数值 ----
        if own_spd > 1:
            own_head = self._arrow(own_fr, own_hdg, 72, OWN_COLOR)
            rad_o = math.radians(own_hdg)
            lx = self._shift_px(own_head, math.sin(rad_o) * 12, math.cos(rad_o) * 12)
            self.axo.text(
                lx[0],
                lx[1],
                f"本机 {own_spd:.0f} fps",
                color=OWN_COLOR,
                fontsize=10.5,
                fontweight="bold",
                ha="center",
                va="center",
                bbox=dict(
                    fc="white", ec=OWN_COLOR, alpha=0.85, boxstyle="round,pad=0.3", lw=1
                ),
            )
            lz = self._shift_px(lx, 0, -22)
            self.axo.text(
                lz[0],
                lz[1],
                f"垂直率 {row['Own_Vert_Rate(fps)']:+.0f} fps",
                color="#555555",
                fontsize=9,
                ha="center",
                va="center",
            )

        # ---- 入侵者等长机头方向箭头 + 数值 ----
        if int_spd > 1:
            int_psi = safe_deg(own_hdg + psi)
            int_head = self._arrow(intr_fr, int_psi, 72, INT_COLOR)
            rad_i = math.radians(int_psi)
            lx2 = self._shift_px(int_head, math.sin(rad_i) * 12, math.cos(rad_i) * 12)
            self.axo.text(
                lx2[0],
                lx2[1],
                f"入侵者 {int_spd:.0f} fps",
                color=INT_COLOR,
                fontsize=10.5,
                fontweight="bold",
                ha="center",
                va="center",
                bbox=dict(
                    fc="white", ec=INT_COLOR, alpha=0.85, boxstyle="round,pad=0.3", lw=1
                ),
            )
            lz2 = self._shift_px(lx2, 0, -22)
            self.axo.text(
                lz2[0],
                lz2[1],
                f"垂直率 {row['Int_Vert_Rate(fps)']:+.0f} fps",
                color="#555555",
                fontsize=9,
                ha="center",
                va="center",
            )
        else:
            self.axo.text(
                intr_fr[0] + 8,
                intr_fr[1] + 6,
                f"入侵者 {int_spd:.0f} fps(静止/无航向)",
                color=INT_COLOR,
                fontsize=10,
                fontweight="bold",
                ha="left",
                va="center",
                bbox=dict(
                    fc="white", ec=INT_COLOR, alpha=0.85, boxstyle="round,pad=0.3", lw=1
                ),
            )

        # ---- 水平机动(右转/左转)转向示意弧 ----
        h = row["h"]
        if h in (2, 3):
            self._draw_turn_arc(h, H_COLORS[h], own_fr)

    def _draw_vertical(self, row):
        """垂直态势
        仅入侵者画等长升降箭头(只表达升/降方向), 具体垂直率看旁注数值文字;
        本机不画方向箭头, 本机垂直率仅以 "本机 Vz" 旁注文字表达"""
        ax = self.axv
        r = row["Range(ft)"]
        z = row["Rel_Altitude(ft)"]
        own_dz = row["Own_Vert_Rate(fps)"]
        int_dz = row["Int_Vert_Rate(fps)"]

        rmax = choose_rmax(r)
        # 防御: 表里若出现 inf/NaN 则退化为默认量程, 避免 set_ylim 报错
        span = max(abs(z) + 600.0, 900.0) if math.isfinite(z) else 900.0
        ax.set_xlim(-0.06 * rmax, rmax)
        ax.set_ylim(-span, span)
        ax.set_facecolor("#FAFCFF")
        ax.grid(True, color="#CCCCCC", linestyle="--", alpha=0.7)

        # 本机高度基准线 与 ±600ft 垂直间隔阈值
        ax.axhline(0.0, color="#888888", lw=1.0, zorder=1)
        for zz in (600.0, -600.0):
            ax.axhline(zz, color="#B0BEC5", ls="--", lw=1.0, zorder=1)
        # 两机连线: 直观看出相对高度
        ax.plot([0, r], [0, z], color="#90A4AE", ls=":", lw=1.2, zorder=2)

        # 本机 / 入侵者位置
        ax.scatter(
            [0],
            [0],
            s=220,
            marker="o",
            c=OWN_COLOR,
            edgecolors="white",
            linewidths=1.8,
            zorder=6,
            label="本机",
        )
        ax.scatter(
            [r],
            [z],
            s=110,
            marker="D",
            c=INT_COLOR,
            edgecolors="white",
            linewidths=1.2,
            zorder=6,
            label="入侵者",
        )

        # 入侵者等长升降箭头(仅表示方向) + 旁注数值
        # 注: 本机方向箭头已取消, 本机垂直率只由下方 "本机 Vz" 旁注文字表达
        arrow_px = 46.0
        for x0, y0, rate, color, lw in ((r, z, int_dz, INT_COLOR, 2.6),):
            if abs(rate) > 1:
                head = self._shift_data_px(
                    ax, x0, y0, 0.0, math.copysign(arrow_px, rate)
                )
                ax.annotate(
                    "",
                    xy=head,
                    xytext=(x0, y0),
                    arrowprops=dict(
                        arrowstyle="-|>",
                        color=color,
                        lw=lw,
                        mutation_scale=16,
                        shrinkA=0,
                        shrinkB=0,
                    ),
                    zorder=5,
                )

        own_txt = "平飞" if abs(own_dz) <= 1 else f"{own_dz:+.0f} fps"
        ax.text(
            *self._shift_data_px(ax, 0.0, 0.0, 12.0, 16.0),
            f"本机 Vz {own_txt}",
            color=OWN_COLOR,
            fontsize=9,
            fontweight="bold",
            ha="left",
            va="bottom",
            bbox=dict(
                fc="white", ec=OWN_COLOR, alpha=0.85, boxstyle="round,pad=0.25", lw=1
            ),
            zorder=7,
        )

        int_txt = "平飞" if abs(int_dz) <= 1 else f"{int_dz:+.0f} fps"
        # 标注放在与高度差同侧(上方/下方): span=|z|+600 保证有足够余量不越界;
        # 水平方向朝图内空处(远距离向左延伸, 近距离向右延伸), 避免压到"本机"标注
        lx = -12.0 if r > 0.65 * rmax else 12.0
        ly = 12.0 if z >= 0 else -12.0
        if lx > 0 and ly > 0 and r < 0.36 * rmax:
            ly = -12.0  # 与 0 线上方的"本机"标注水平重叠时, 改放到下方
        ha = "right" if lx < 0 else "left"
        va = "bottom" if ly > 0 else "top"
        ax.text(
            *self._shift_data_px(ax, r, z, lx, ly),
            f"相对高度 {z:+.0f} ft\nVz {int_txt}",
            color=INT_COLOR,
            fontsize=9,
            fontweight="bold",
            ha=ha,
            multialignment=ha,
            va=va,
            bbox=dict(
                fc="white", ec=INT_COLOR, alpha=0.85, boxstyle="round,pad=0.25", lw=1
            ),
            zorder=7,
        )

        ax.set_xticks([0.0, rmax / 2.0, rmax])
        ax.set_xticklabels(
            [fmt_ft(v) for v in (0.0, rmax / 2.0, rmax)],
            color="#555555",
            fontsize=9,
        )
        yticks = sorted({-span, -600.0, 0.0, 600.0, span})
        ax.set_yticks(yticks)
        ax.set_yticklabels([fmt_ft(v) for v in yticks], color="#555555", fontsize=9)
        ax.set_xlabel("水平距离 Range (ft)", fontsize=10)
        ax.set_ylabel("相对高度 Rel_Alt (ft)", fontsize=10)
        ax.set_title(
            "垂直态势",
            fontsize=12,
            fontweight="bold",
            pad=20,
            color="#222222",
        )
        ax.text(
            0.5,
            1.006,
            "蓝=本机 · 红=入侵者 · 箭头=入侵者升/降方向 · 虚线=±600 ft 垂直间隔阈值",
            transform=ax.transAxes,
            ha="center",
            va="bottom",
            fontsize=8,
            color="#607D8B",
        )

    def _draw_turn_arc(self, h, color, own_fr):
        """在圆心附近画小段转向弧(右转 h=2 顺时针 / 左转 h=3 逆时针)"""
        R_PX = 26.0
        if h == 2:  # 右转: 机头由 0° 向右(顺时针)偏转
            a0, a1 = 12.0, 62.0
        else:  # 左转: 逆时针
            a0, a1 = -62.0, -12.0
        xs, ys = [], []
        for t in np.linspace(a0, a1, 24):
            rad = math.radians(t)
            fx, fy = self._shift_px(own_fr, math.sin(rad) * R_PX, math.cos(rad) * R_PX)
            xs.append(fx)
            ys.append(fy)
        self.axo.plot(xs, ys, color=color, lw=2.6, alpha=0.95, zorder=3)
        self.axo.annotate(
            "",
            xy=(xs[-1], ys[-1]),
            xytext=(xs[-2], ys[-2]),
            arrowprops=dict(arrowstyle="-|>", color=color, lw=1.6, mutation_scale=13),
        )

    # ---------- 右侧状态/动作面板 ----------
    def _draw_panel(self, row):
        ax = self.axpanel
        ax.clear()
        ax.axis("off")
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)
        y = 0.985

        def line(
            text,
            dy=0.041,
            size=11.5,
            color="#222222",
            weight="normal",
            x=0.03,
            ha="left",
        ):
            nonlocal y
            ax.text(
                x,
                y,
                text,
                fontsize=size,
                color=color,
                fontweight=weight,
                va="top",
                ha=ha,
                linespacing=1.25,
            )
            y -= dy

        def kv(label, value, dy=0.041, size=11.5):
            nonlocal y
            ax.text(0.03, y, label, fontsize=size, color="#555555", va="top", ha="left")
            ax.text(
                0.985, y, value, fontsize=size, color="#111111", va="top", ha="right"
            )
            y -= dy

        def blank(dy=0.012):
            nonlocal y
            y -= dy

        def chip(title, text, color, dy=None, size=13.5, gap_px=6.0):
            """动作 chip: dy 为 None 时按文字实际高度+盒边距自动排距, 避免上下重叠"""
            nonlocal y
            t = ax.text(
                0.5,
                y,
                f"{title}\n{text}",
                fontsize=size,
                color="white",
                va="top",
                ha="center",
                fontweight="bold",
                bbox=dict(fc=color, ec="none", alpha=0.95, boxstyle="round,pad=0.4"),
            )
            if dy is None:
                dy = 0.10  # 兜底值(取不到渲染器/面板高度时)
                try:
                    h_px = t.get_window_extent().height
                    panel_px = ax.get_position().height * ax.figure.bbox.height
                    if panel_px > 0:
                        pad_px = 2.0 * 0.4 * size * ax.figure.dpi / 72.0
                        dy = (h_px + pad_px + gap_px) / panel_px
                except Exception:  # noqa
                    pass
            y -= dy

        r = row["Range(ft)"]
        z = row["Rel_Altitude(ft)"]
        b = row["Bearing(deg)"]
        psi = row["Rel_Heading(deg)"]
        int_spd = row["Intruder_Speed(fps)"]
        own_spd = row["Own_Speed(fps)"]
        h, v = row["h"], row["v"]

        line("◆ 当前状态 / 本机动作", size=15, color="#0D47A1", weight="bold", dy=0.042)
        line(
            f"表格第 {row['line']} 行   筛选内 {self.i + 1} / {len(self.subset)}",
            size=9.5,
            color="#777777",
            dy=0.036,
        )
        line(f"筛选: {self.filter_desc}", size=9, color="#999999", dy=0.03)
        blank()

        kv("距离 Range", f"{r:,.0f} ft = {r * 0.3048:,.0f} m")
        kv("相对高度 Rel_Alt", f"{z:+,.0f} ft = {z * 0.3048:+,.0f} m")
        kv("方位 Bearing", f"{b:.0f}°  ({bearing_name(b)})")
        kv("相对航向 Rel_Heading", f"{psi:.0f}°  ({heading_name(psi)})")
        kv("本机速度 Own_Spd", f"{own_spd:.0f} fps")
        kv("入侵者速度 Int_Spd", f"{int_spd:.0f} fps")
        blank(0.006)

        line(
            "本机推荐动作 (Recommended_Action)",
            size=12.5,
            color="#222222",
            weight="bold",
            dy=0.046,
        )
        blank(0.010)
        chip(
            f"水平动作  H:{h}",
            H_NAMES.get(h, f"未知({h})"),
            H_COLORS[h % len(H_COLORS)],
        )
        chip(
            f"垂直动作  V:{v}",
            V_NAMES.get(v, f"未知({v})"),
            V_COLORS[v % len(V_COLORS)],
        )
        risk_color, risk_name = urgency_of(row)
        chip("风险等级", risk_name, risk_color)
        blank(0.02)
        line(
            "操作: ←/→ 翻行 · ↑/↓ 跳10 · PgUp/PgDn 跳100",
            size=9,
            color="#777777",
            dy=0.030,
        )
        line(
            "Home/End 首尾 · N/P 跳动作行 · S 存PNG · Q 退出",
            size=9,
            color="#777777",
            dy=0.030,
        )

    # ---------- 刷新 ----------
    def update(self, i=None):
        """重绘当前行"""
        if i is not None:
            i = int(round(i))
            self.i = max(0, min(i, len(self.subset) - 1))
        row = self.subset[self.i]

        for a in (self.axp, self.axo, self.axv):
            a.clear()
        self.axp.set_theta_zero_location("N")
        self.axp.set_theta_direction(-1)
        self.axp.set_rlabel_position(135)
        self.axp.set_facecolor("#FAFCFF")
        self.axo.set_facecolor("none")
        self.axo.patch.set_visible(False)
        self.axo.set_xlim(0, 1)
        self.axo.set_ylim(0, 1)
        # clear() 会恢复默认刻度, 这里重新关掉(否则覆盖轴上会冒出 0.0~1.0 的刻度文字)
        self.axo.set_xticks([])
        self.axo.set_yticks([])

        self._draw_polar(row)
        self._draw_overlay(row)
        self._draw_vertical(row)
        self._draw_panel(row)

        h, v = row["h"], row["v"]
        self.fig.suptitle(
            f"第 {row['line']} 行 (筛选内 {self.i + 1}/{len(self.subset)})  |  "
            f"Range {fmt_ft(row['Range(ft)'])} ft  |  "
            f"动作 H:{h} {H_NAMES.get(h, '')}  /  V:{v} {V_NAMES.get(v, '')}",
            fontsize=13,
            fontweight="bold",
            y=0.995,
        )
        if self.fig.canvas is not None:
            self.fig.canvas.draw_idle()

    def _on_slider(self, val):
        self.update(int(round(val)))

    # ---------- 保存 ----------
    def save_png(self, path=None):
        row = self.subset[self.i]
        if path is None:
            os.makedirs(DEFAULT_OUT_DIR, exist_ok=True)
            fname = (
                f"polar_row{row['line']:06d}_R{row['Range(ft)']:.0f}_"
                f"B{row['Bearing(deg)']:.0f}_H{row['h']}V{row['v']}.png"
            )
            path = os.path.join(DEFAULT_OUT_DIR, fname)
        path = os.path.abspath(path)
        pdir = os.path.dirname(path)
        if pdir:
            os.makedirs(pdir, exist_ok=True)
        self.fig.savefig(path, dpi=160)
        print(f"已保存当前状态图: {path}")
        return path


# ---------------- 命令行入口 ----------------
def build_parser():
    p = argparse.ArgumentParser(
        description="2D 状态浏览器(水平极坐标 + 垂直剖面) —— 读取 my_lightweight_table_dense.csv，"
        "交互浏览各'当前状态'，左侧水平态势 + 中间垂直剖面，右侧本机推荐动作"
    )
    p.add_argument(
        "--table",
        default=DEFAULT_TABLE,
        help=f"状态表 CSV 路径 (默认: {DEFAULT_TABLE})",
    )
    p.add_argument(
        "--filter",
        default="",
        help="筛选条件, 多个条件用逗号或 & 分隔(Windows 命令行建议用逗号), "
        "如 'Range<=3000,Rel_Heading=-180,H>=2'；"
        "字段别名 R/B/Alt/Psi/Hdg/Tau 等, H/V 表示动作码",
    )
    p.add_argument(
        "--own-heading",
        type=float,
        default=0.0,
        help="本机屏幕航向角(度, 0=机头朝上), 默认 0",
    )
    p.add_argument(
        "--index", type=int, default=0, help="起始行位置(0 起, 相对筛选结果), 默认 0"
    )
    p.add_argument(
        "--output",
        "-o",
        default=None,
        help="无界面渲染指定行并存为 PNG(提供路径即退出, 不弹窗)",
    )
    return p


def _clamp_idx(viewer, i):
    return max(0, min(i, len(viewer.subset) - 1))


def run_interactive(viewer):
    fig = viewer.fig

    def on_key(event):
        n = len(viewer.subset)
        i = viewer.i
        key = event.key
        if key == "left":
            i -= 1
        elif key == "right":
            i += 1
        elif key == "up":
            i -= 10
        elif key == "down":
            i += 10
        elif key == "pageup":
            i -= 100
        elif key == "pagedown":
            i += 100
        elif key == "home":
            i = 0
        elif key == "end":
            i = n - 1
        elif key in ("n", "N", "p", "P"):
            step = 1 if key in ("n", "N") else -1
            j = i + step
            while 0 <= j < n:
                r = viewer.subset[j]
                if r["h"] != 0 or r["v"] != 0:
                    break
                j += step
            if 0 <= j < n:
                i = j
            else:
                return
        elif key in ("s", "S"):
            viewer.save_png()
            return
        elif key in ("q", "escape"):
            plt.close(fig)
            return
        else:
            return
        viewer.slider.set_val(_clamp_idx(viewer, i))

    fig.canvas.mpl_connect("key_press_event", on_key)
    # 窗口尺寸变化后按新尺寸重排(否则按点值排距的文字会重新重叠)
    fig.canvas.mpl_connect("resize_event", lambda _e: viewer.update())
    viewer.make_slider()
    plt.show()


def main():
    args = build_parser().parse_args()
    if not os.path.exists(args.table):
        print(f"错误: 找不到表格 {args.table}")
        sys.exit(1)
    rows = load_table(args.table)

    try:
        viewer = PolarStateViewer(
            rows, own_heading=args.own_heading, filter_expr=args.filter
        )
    except RuntimeError as e:
        print(f"错误: {e}")
        sys.exit(1)

    fig = viewer.make_figure()
    fig.canvas.draw()  # 先布局一次, 保证坐标转换可用
    viewer.update(_clamp_idx(viewer, args.index))

    if args.output:
        viewer.save_png(args.output)
        plt.close(fig)
        return

    run_interactive(viewer)


if __name__ == "__main__":
    main()
