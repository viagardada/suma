"""双机相遇三维演示：实际本机直飞，虚线假想执行避让并归航。

python encounter_3d_demo.py
python encounter_3d_demo.py --snapshot output/encounter_3d/preview.png --no-gui
python encounter_3d_demo.py --gif output/encounter_3d/demo.gif --no-gui

建议来自现有 CSV 的九维精确查表；缺失记录不会视作无建议。
虚线由本程序的运动学路径规划器生成，原生 sUMA 输出的是 H/V 建议而非轨迹。
规划器限制水平速度、航向角速度与爬升/下降率；未模拟气动力、加速度或飞控响应。
"""

import argparse
import csv
import json
import math
import re
from dataclasses import dataclass
from pathlib import Path

import numpy as np
from expand_native_table import DEFAULT_TABLE, FIELDS, discretize

OUT_DIR = Path(__file__).resolve().parent / "output" / "encounter_3d"
H_NAMES = {0: "无水平建议", 1: "解除水平建议", 2: "右转", 3: "左转", 4: "保持直飞"}
V_NAMES = {
    0: "无垂直建议",
    1: "解除垂直建议",
    2: "禁止爬升",
    3: "禁止下降",
    4: "爬升",
    5: "下降",
    6: "交叉爬升",
    7: "交叉下降",
}
BLUE, RED, GREEN = "#1678D4", "#E65054", "#00A884"


@dataclass(frozen=True)
class Config:
    speed: float = 200.0  # horizontal ft/s
    altitude: float = 1000.0
    destination: float = 10000.0  # northing, ft
    intruder_distance: float = 6000.0
    dt: float = 0.1
    max_turn_rate: float = 3.0  # deg/s
    max_vertical_rate: float = 16.667  # ft/s
    horizontal_margin: float = 300.0  # demonstration criteria, not ACAS thresholds
    vertical_margin: float = 100.0

    def validate(self):
        values = tuple(self.__dict__.values())
        if not all(math.isfinite(x) and x > 0 for x in values):
            raise ValueError("所有参数必须是正的有限数")
        if self.dt > 0.5:
            raise ValueError("时间步长不得超过 0.5 秒")
        if self.intruder_distance >= 2 * self.destination:
            raise ValueError("相遇点必须位于目的地之前，请减小入侵者初始距离")


class ActionTable:
    def __init__(self, path):
        self.path = Path(path).resolve()
        self.rows = {}
        with self.path.open(encoding="utf-8-sig", newline="") as f:
            reader = csv.DictReader(f)
            if not set(FIELDS).issubset(reader.fieldnames or []):
                raise ValueError("查找表缺少状态或动作字段")
            for row in reader:
                key = list(float(row[k]) for k in FIELDS[:9])
                key[2] = (key[2] + 180) % 360 - 180
                key[3] = (key[3] + 180) % 360 - 180
                match = re.fullmatch(r"\s*H:(\d+)\s*\|\s*V:(\d+)\s*", row[FIELDS[-1]])
                if match is None:
                    raise ValueError(f"无法解析动作: {row[FIELDS[-1]]}")
                h, v = map(int, match.groups())
                if h not in H_NAMES or v not in V_NAMES:
                    raise ValueError("表中存在未知动作码")
                self.rows[tuple(key)] = (h, v)

    def query(self, own, intruder, config, moving=True):
        if not moving:
            return Query(None, None, "本机已到达目的地")
        relative = intruder - own
        distance = float(np.linalg.norm(relative[:2]))
        if distance < 1e-6:
            return Query(None, None, "两机位置重合，方位未定义")
        radial = -2 * config.speed * relative[1] / distance
        tau = -distance / radial if radial < -0.1 else -1.0
        state = (
            distance,
            float(relative[2]),
            math.degrees(math.atan2(relative[0], relative[1])),
            -180.0,
            config.speed,
            config.speed,
            0.0,
            0.0,
            tau,
        )
        key = discretize(state)
        action = self.rows.get(key)
        return Query(
            action, key, "精确命中" if action is not None else "当前状态无匹配记录"
        )


@dataclass(frozen=True)
class Query:
    action: tuple | None
    key: tuple | None
    reason: str

    @property
    def maneuver(self):
        return self.action is not None and (
            self.action[0] in (2, 3) or self.action[1] in (4, 5, 6, 7)
        )


def own_actual(times, config):
    times = np.atleast_1d(times)
    return np.column_stack(
        (
            np.zeros_like(times),
            np.minimum(config.speed * times, config.destination),
            np.full_like(times, config.altitude),
        )
    )


def intruder_actual(times, config):
    times = np.atleast_1d(times)
    return np.column_stack(
        (
            np.zeros_like(times),
            config.intruder_distance - config.speed * times,
            np.full_like(times, config.altitude),
        )
    )


def smoothstep(u):
    u = np.clip(u, 0, 1)
    return (
        u**3 * (10 - 15 * u + 6 * u * u),
        30 * u * u * (1 - u) ** 2,
        60 * u - 180 * u * u + 120 * u**3,
    )


def bump(y, start, peak, return_start, rejoin):
    b, db, ddb = np.zeros_like(y), np.zeros_like(y), np.zeros_like(y)
    outbound = (y >= start) & (y < peak)
    hold = (y >= peak) & (y < return_start)
    inbound = (y >= return_start) & (y < rejoin)
    length = peak - start
    b[outbound], db[outbound], ddb[outbound] = smoothstep(
        (y[outbound] - start) / length
    )
    db[outbound] /= length
    ddb[outbound] /= length**2
    b[hold] = 1
    length = rejoin - return_start
    val, deriv, second = smoothstep((y[inbound] - return_start) / length)
    b[inbound] = 1 - val
    db[inbound] = -deriv / length
    ddb[inbound] = -second / length**2
    return b, db, ddb


@dataclass
class Route:
    time: np.ndarray
    xyz: np.ndarray
    velocity: np.ndarray
    trigger_time: float
    peak_time: float
    return_time: float
    rejoin_time: float
    rejoin_y: float
    action: tuple
    clearance_ratio: float = 0.0
    min_distance: float = 0.0
    path_length: float = 0.0
    feasible_candidates: int = 0

    def positions(self, times, config):
        return self.state(times,config)[0]

    def state(self, times, config):
        times = np.atleast_1d(times)
        clamped = np.clip(times, self.time[0], self.time[-1])
        index = np.clip(
            np.searchsorted(self.time, clamped, side="right") - 1, 0, len(self.time) - 2
        )
        span = self.time[index + 1] - self.time[index]
        u = ((clamped - self.time[index]) / span)[:, None]
        # Cubic Hermite interpolation preserves node velocities; linear XYZ
        # interpolation would introduce heading-rate spikes at every node.
        result = (
            (2 * u**3 - 3 * u * u + 1) * self.xyz[index]
            + (u**3 - 2 * u * u + u) * span[:, None] * self.velocity[index]
            + (-2 * u**3 + 3 * u * u) * self.xyz[index + 1]
            + (u**3 - u * u) * span[:, None] * self.velocity[index + 1]
        )
        velocity = ((6*u*u-6*u)*self.xyz[index]/span[:,None]
                    +(3*u*u-4*u+1)*self.velocity[index]
                    +(-6*u*u+6*u)*self.xyz[index+1]/span[:,None]
                    +(3*u*u-2*u)*self.velocity[index+1])
        acceleration = ((12*u-6)*self.xyz[index]/span[:,None]**2
                        +(6*u-4)*self.velocity[index]/span[:,None]
                        +(-12*u+6)*self.xyz[index+1]/span[:,None]**2
                        +(6*u-2)*self.velocity[index+1]/span[:,None])
        before = times < self.trigger_time
        result[before] = own_actual(times[before], config)
        velocity[before] = [0,config.speed,0]
        acceleration[before] = 0
        return result,velocity,acceleration

    def phase(self, t):
        if t < self.trigger_time:
            return "等待建议"
        if t < self.peak_time:
            return "假想执行避让"
        if t < self.return_time:
            return "假想保持偏置，等待通过"
        if t < self.rejoin_time:
            return "假想平滑归航"
        if t < self.time[-1]:
            return "已接回原航线，继续前往目的地"
        return "假想本机已到达目的地"

    def planned_view(self, now, config):
        """The complete route and join point stay fixed throughout playback."""
        return self.xyz,self.rejoin_y


def route_candidate(
    config,
    trigger,
    action,
    lateral,
    vertical,
    hold_distance=700.0,
    return_distance=1800.0,
):
    start = trigger * config.speed
    cpa_y = config.intruder_distance / 2
    available = config.destination - start
    if available < 2000:
        raise ValueError("建议出现太晚，剩余航程不足以演示避让和归航")
    peak = start + min(available * 0.28, max(700.0, cpa_y - start))
    return_start = max(peak + hold_distance, cpa_y + 300)
    rejoin = return_start + return_distance
    if rejoin > config.destination - 600:
        return None
    if not start < peak < return_start < rejoin < config.destination:
        raise ValueError("无法构造有序的避让、保持、归航区间")
    # Include all joins explicitly; quintic offsets have zero first/second
    # derivatives there, so both heading and climb rate match the original route.
    anchors = np.array([start, peak, return_start, rejoin, config.destination])
    interior = np.arange(start, config.destination, 3.0)
    interior = interior[
        np.min(np.abs(interior[:, None] - anchors[None, :]), axis=1) > 1e-5
    ]
    y = np.unique(np.r_[interior, anchors])
    b, db, ddb = bump(y, start, peak, return_start, rejoin)
    h, v = action
    side = 1 if h == 2 else (-1 if h == 3 else 0)
    up = 1 if v in (4, 6) else (-1 if v in (5, 7) else 0)
    x = side * lateral * b
    z = config.altitude + up * vertical * b
    if np.min(z) < 50:
        return None
    dxdy, dzdy = side * lateral * db, up * vertical * db
    dhead_dy = side * lateral * ddb / (1 + dxdy * dxdy)
    ydot = config.speed / np.sqrt(1 + dxdy * dxdy)
    ydot = np.minimum(ydot, config.max_vertical_rate / np.maximum(np.abs(dzdy), 1e-12))
    ydot = np.minimum(
        ydot, math.radians(config.max_turn_rate) / np.maximum(np.abs(dhead_dy), 1e-12)
    )
    # Kinematic time scaling may reduce speed during the manoeuvre. A small
    # margin covers interpolation and finite-difference verification errors.
    ydot *= 0.98
    time = trigger + np.r_[0, np.cumsum(np.diff(y) / ((ydot[1:] + ydot[:-1]) / 2))]
    velocity = np.column_stack((dxdy * ydot, ydot, dzdy * ydot))
    xyz = np.column_stack((x, y, z))
    route = Route(
        time,
        xyz,
        velocity,
        trigger,
        float(np.interp(peak, y, time)),
        float(np.interp(return_start, y, time)),
        float(np.interp(rejoin, y, time)),
        rejoin,
        action,
    )
    route.path_length = float(np.sum(np.linalg.norm(np.diff(xyz, axis=0), axis=1)))
    return route


def plan_route(config, trigger, action):
    horizontal = [50, 100, 150, 200, 300, 400, 500, 600, 800, 1000] if action[0] in (2, 3) else [0]
    vertical = [100, 120, 150, 180, 200, 220, 300, 400] if action[1] in (4, 5, 6, 7) else [0]
    candidates = []
    for lateral in horizontal:
        for height in vertical:
            for hold in (300.0, 700.0, 1100.0):
                for length in (1200.0, 1800.0, 2400.0, 3200.0):
                    route = route_candidate(
                        config, trigger, action, lateral, height, hold, length
                    )
                    if route is None:
                        continue
                    t = np.r_[np.arange(trigger, route.time[-1], 0.025), route.time[-1]]
                    relative = route.positions(t, config) - intruder_actual(t, config)
                    horizontal_gap = np.linalg.norm(relative[:, :2], axis=1)
                    vertical_gap = np.abs(relative[:, 2])
                    # Check the complete return as well as the initial avoidance.
                    route.clearance_ratio = float(
                        np.min(
                            np.maximum(
                                horizontal_gap / config.horizontal_margin,
                                vertical_gap / config.vertical_margin,
                            )
                        )
                    )
                    route.min_distance = float(np.min(np.linalg.norm(relative, axis=1)))
                    if route.clearance_ratio >= 1.1:
                        candidates.append(route)
    if not candidates:
        raise ValueError(
            "在当前机动限幅下未找到满足演示间隔的归航路线；不会绘制未经检查的避让虚线"
        )
    # A finite candidate search, not a claim of a globally optimal flight path.
    best = min(candidates, key=lambda route: (float(np.max(np.abs(route.xyz[:,0]))),
                                              float(np.max(np.abs(route.xyz[:,2]-config.altitude))),
                                              route.time[-1],route.path_length))
    best.feasible_candidates = len(candidates)
    return best



@dataclass
class Encounter:
    config: Config
    time: np.ndarray
    own: np.ndarray
    intruder: np.ndarray
    hypothetical: np.ndarray
    queries: list
    route: Route
    table_path: str

    def report(self):
        c, r = self.config, self.route
        actual_distance = np.linalg.norm(self.own - self.intruder, axis=1)
        index = int(np.argmin(actual_distance))
        return dict(
            table=self.table_path,
            config=c.__dict__,
            actual_route="straight, never executes advisories",
            advisory_source="exact nine-dimensional lookup; missing is unknown",
            hypothetical_route="first actionable H/V, kinematic avoidance, hold, smooth return, destination",
            trigger_time=r.trigger_time,
            first_action=list(r.action),
            actual_closest_time=float(self.time[index]),
            actual_min_distance=float(actual_distance[index]),
            hypothetical_min_distance=r.min_distance,
            clearance_ratio=r.clearance_ratio,
            rejoin_time=r.rejoin_time,
            rejoin_position=[0, r.rejoin_y, c.altitude],
            return_start_time=r.return_time,
            route_selection="minimum lateral deviation, then vertical deviation, arrival time and path length among feasible candidates",
            max_lateral_offset=float(np.max(np.abs(r.xyz[:,0]))),
            max_vertical_offset=float(np.max(np.abs(r.xyz[:,2]-c.altitude))),
            return_planning='single complete route selected at first actionable advisory; fixed thereafter',
            planning_runs=1,
            feasible_candidates=r.feasible_candidates,
            path_length_after_trigger=r.path_length,
            rejoin_tangent=r.velocity[
                np.argmin(np.abs(r.time - r.rejoin_time))
            ].tolist(),
            actual_arrival=c.destination / c.speed,
            hypothetical_arrival=float(r.time[-1]),
            exact_matches=sum(q.action is not None for q in self.queries),
            unknown_queries=sum(q.action is None for q in self.queries),
            limitation="Kinematic illustration, not a native sUMA trajectory or flight-controller simulation",
        )


def build_encounter(table, config):
    config.validate()
    arrival = config.destination / config.speed
    provisional = np.arange(0, arrival, config.dt)
    route = None
    for t in provisional:
        own, intruder = own_actual([t], config)[0], intruder_actual([t], config)[0]
        q = table.query(own, intruder, config)
        if q.maneuver:
            route = plan_route(config, float(t), q.action)
            break
    if route is None:
        raise ValueError(
            "当前场景未精确查到可执行的转向/升降建议，不能生成虚线。请使用默认速度或检查表格"
        )
    end = max(arrival, float(route.time[-1])) + 2
    times = np.unique(
        np.r_[
            np.arange(0, end, config.dt),
            end,
            config.intruder_distance / (2 * config.speed),
            route.trigger_time,
            route.rejoin_time,
            route.time[-1],
            arrival,
        ]
    )
    own, intruder = own_actual(times, config), intruder_actual(times, config)
    queries = [
        table.query(o, i, config, bool(t < arrival))
        for t, o, i in zip(times, own, intruder)
    ]
    return Encounter(
        config,
        times,
        own,
        intruder,
        route.positions(times, config),
        queries,
        route,
        str(table.path),
    )


class DemoViewer:
    def __init__(self, data, fps=20, playback=3):
        import matplotlib.pyplot as plt
        from matplotlib.widgets import Button, Slider
        from mpl_toolkits.mplot3d.art3d import Line3DCollection

        self.plt, self.data = plt, data
        self.fps, self.playback = fps, playback
        self.playing, self.t, self.setting_slider = True, 0.0, False
        self.zoom = 1.12
        self.animation = None
        plt.rcParams["font.sans-serif"] = ["Microsoft YaHei", "SimHei", "DejaVu Sans"]
        plt.rcParams["axes.unicode_minus"] = False
        c, r = data.config, data.route
        self.fig = plt.figure(figsize=(16, 9.2), facecolor="#F6F8FC")
        self.fig.suptitle(
            "双机相遇三维演示", fontsize=20, weight="bold", y=0.965, color="#17314B"
        )
        self.ax = self.fig.add_axes(
            [0.0, 0.17, 0.74, 0.74], projection="3d", facecolor="#F6F8FC"
        )
        self.ax.set(
            xlabel="东向 X (ft)",
            ylabel="航线方向 Y (ft)",
            zlabel="高度 Z (ft)",
            xlim=(min(0,float(r.xyz[:,0].min()))-140,max(0,float(r.xyz[:,0].max()))+140),
            ylim=(-1200, c.destination + 600),
            zlim=(max(0,float(r.xyz[:,2].min())-100),float(r.xyz[:,2].max())+100),
        )
        self.ax.set_box_aspect((2.5, 4.6, 2.4),zoom=self.zoom)
        self.ax.view_init(elev=24, azim=-125)
        self.ax.tick_params(labelsize=8)
        start = np.array([0, 0, c.altitude])
        goal = np.array([0, c.destination, c.altitude])
        self.ax.plot(*np.array([start, goal]).T, color=BLUE, lw=1.3, alpha=0.25)
        guide = intruder_actual(
            np.linspace(0, (c.intruder_distance + 1200) / c.speed, 60), c
        )
        self.ax.plot(*guide.T, color=RED, lw=1, alpha=0.18)
        self.ax.scatter(
            *goal, s=180, marker="*", color="#D49B22", edgecolors="white", zorder=12
        )
        self.ax.text(
            0, c.destination, c.altitude + 90, "目的地", fontsize=11, color="#96681A"
        )
        self.ax.text(0, 0, c.altitude - 110, "起点", fontsize=10, color=BLUE)
        (self.actual_line,) = self.ax.plot(
            [], [], [], color=BLUE, lw=3, label="本机实际：直飞"
        )
        (self.intruder_line,) = self.ax.plot(
            [], [], [], color=RED, lw=2.3, label="入侵者实际"
        )
        (self.plan_line,) = self.ax.plot(
            [],
            [],
            [],
            color=GREEN,
            lw=2.6,
            ls=(0, (5, 3)),
            label="本机假想：避让后归航",
        )
        (self.ghost,) = self.ax.plot(
            [], [], [], marker="o", ms=8, mfc="white", mec=GREEN, mew=2, ls=""
        )
        (self.trigger_marker,) = self.ax.plot(
            [], [], [], marker="o", ms=6, color="#E5A52A", ls=""
        )
        (self.rejoin_marker,) = self.ax.plot(
            [], [], [], marker="D", ms=7, mfc="white", mec=GREEN, mew=2, ls=""
        )
        self.rejoin_label = self.ax.text(
            0, r.rejoin_y, c.altitude + 80, "相切接回原航线", fontsize=10, color=GREEN
        )
        self.own_label = self.ax.text(
            0, 0, c.altitude + 100, "本机", color=BLUE, fontsize=11, weight="bold"
        )
        self.intruder_label = self.ax.text(
            0,
            c.intruder_distance,
            c.altitude + 100,
            "入侵者",
            color=RED,
            fontsize=11,
            weight="bold",
        )
        geometry = np.array(
            [
                [[0, -100, 0], [0, 140, 0]],
                [[-110, 10, 0], [110, 10, 0]],
                [[-55, -75, 25], [55, -75, 25]],
                [[0, -100, 0], [0, -65, 65]],
            ],
            dtype=float,
        )
        geometry *= np.array([.2,1,.3])
        self.geometry = geometry
        self.own_glyph = Line3DCollection(geometry, colors=BLUE, linewidths=3)
        self.intruder_glyph = Line3DCollection(geometry, colors=RED, linewidths=3)
        self.ax.add_collection3d(self.own_glyph)
        self.ax.add_collection3d(self.intruder_glyph)
        self.ax.legend(
            loc="upper left", bbox_to_anchor=(0.0, 1.03), frameon=False, fontsize=10
        )

        panel = self.fig.add_axes([0.755, 0.435, 0.225, 0.435])
        panel.axis("off")
        panel.text(
            0, 1, "当前态势", fontsize=17, weight="bold", color="#17314B", va="top"
        )
        self.time_text = panel.text(0, 0.88, "", fontsize=14, color="#17314B")
        self.advisory_text = panel.text(
            0, 0.76, "", fontsize=13, weight="bold", va="top"
        )
        self.distance_text = panel.text(
            0, 0.57, "", fontsize=11, linespacing=1.7, va="top", color="#40536A"
        )
        self.phase_text = panel.text(
            0, 0.32, "", fontsize=12, weight="bold", va="top", color=GREEN
        )
        panel.text(
            0,
            0.12,
            "实线本机始终不执行建议\n虚线一次规划，全程固定",
            fontsize=10,
            linespacing=1.7,
            color="#60738B",
            va="top",
        )
        self.chart = self.fig.add_axes([0.77, 0.23, 0.205, 0.16], facecolor="white")
        self.chart.plot(
            data.time,
            np.linalg.norm(data.own - data.intruder, axis=1),
            color=BLUE,
            lw=1.6,
            label="实飞",
        )
        self.chart.plot(
            data.time,
            np.linalg.norm(data.hypothetical - data.intruder, axis=1),
            color=GREEN,
            lw=1.8,
            ls="--",
            label="假想",
        )
        encounter_end = min(data.time[-1], c.intruder_distance / (2 * c.speed) + 20)
        self.chart.set(
            xlim=(0, encounter_end),
            ylim=(0, min(6500, c.intruder_distance + 500)),
            ylabel="两机三维间距 (ft)",
            xlabel="相遇阶段时间 (s)",
        )
        self.chart.tick_params(labelsize=8)
        self.chart.grid(alpha=0.18)
        self.chart.legend(fontsize=8, loc="upper right", frameon=False)
        self.chart.axvline(c.intruder_distance / (2 * c.speed), ls=":", color=RED, lw=1)
        self.chart_cursor = self.chart.axvline(0, color="#17314B", lw=1.3)
        self.fig.text(0.06, 0.14, "时间", fontsize=11, color="#40536A")
        self.slider = Slider(
            self.fig.add_axes([0.11, 0.137, 0.76, 0.02]),
            "",
            0,
            float(data.time[-1]),
            valinit=0,
            color=BLUE,
            valfmt="%.1f s",
        )
        self.slider.drawon = False
        self.slider.on_changed(self._seek)
        self.play_button = Button(
            self.fig.add_axes([0.28, 0.062, 0.105, 0.045]), "暂停"
        )
        self.reset_button = Button(
            self.fig.add_axes([0.40, 0.062, 0.105, 0.045]), "重置"
        )
        self.speed_button = Button(
            self.fig.add_axes([0.52, 0.062, 0.105, 0.045]), f"{playback:g} 倍速"
        )
        self.play_button.on_clicked(self._toggle)
        self.reset_button.on_clicked(self._reset)
        self.speed_button.on_clicked(self._speed)
        self.fig.text(
            0.5,
            0.025,
            "拖动三维视图可旋转 · 滚动缩放 · 空格播放/暂停 · 左右键步进 · R 重置",
            ha="center",
            fontsize=10,
            color="#60738B",
        )
        self.fig.canvas.mpl_connect("key_press_event", self._key)
        self.fig.canvas.mpl_connect("scroll_event", self._scroll)
        self.draw_time(0)

    @staticmethod
    def set_line(line, points):
        line.set_data_3d(points[:, 0], points[:, 1], points[:, 2])

    def draw_time(self, t, redraw=True):
        d, c, r = self.data, self.data.config, self.data.route
        self.t = float(np.clip(t, 0, d.time[-1]))
        index = max(
            0,
            min(
                int(np.searchsorted(d.time, self.t + 1e-9, side="right") - 1),
                len(d.time) - 1,
            ),
        )
        own = own_actual([self.t], c)[0]
        intruder = intruder_actual([self.t], c)[0]
        hypothetical = r.positions([self.t], c)[0]
        actual_trail = np.vstack((d.own[:index], own))
        self.set_line(self.actual_line, actual_trail)
        red_trail = np.vstack((d.intruder[:index], intruder))
        red_trail = red_trail[red_trail[:, 1] >= -1200]
        self.set_line(self.intruder_line, red_trail)
        self.own_glyph.set_segments(self.geometry + own)
        rotation = np.diag([-1, -1, 1])
        self.intruder_glyph.set_segments(self.geometry @ rotation.T + intruder)
        visible = intruder[1] >= -1200
        self.intruder_glyph.set_visible(visible)
        self.intruder_label.set_visible(visible)
        for label, p, offset in (
            (self.own_label, own, -55),
            (self.intruder_label, intruder, 55),
        ):
            label.set_position((p[0] + offset, p[1]))
            label.set_3d_properties(p[2] + 130, zdir=None)
        active = self.t + 1e-9 >= r.trigger_time
        self.plan_line.set_visible(active)
        self.ghost.set_visible(active)
        self.trigger_marker.set_visible(active)
        self.rejoin_marker.set_visible(active)
        self.rejoin_label.set_visible(active)
        if active:
            plan,join_y = r.planned_view(self.t,c)
            self.set_line(self.plan_line, plan)
            self.set_line(self.ghost, hypothetical[None, :])
            self.set_line(self.trigger_marker, r.xyz[:1])
            self.set_line(self.rejoin_marker, np.array([[0, join_y, c.altitude]]))
            self.rejoin_label.set_position((0,join_y))
            self.rejoin_label.set_3d_properties(c.altitude+80,zdir=None)
        q = d.queries[index]
        if q.action is None:
            advisory = q.reason
            color = "#78889A"
            if "位置重合" in q.reason:
                advisory = "实际两机位置重合\n本机仍未执行避让"
                color = RED
        else:
            h, v = q.action
            advisory = f"H:{h} {H_NAMES[h]}\nV:{v} {V_NAMES[v]}"
            color = "#D3821C" if q.maneuver else "#40536A"
        self.time_text.set_text(f"t = {self.t:5.1f} s")
        self.advisory_text.set_text(advisory)
        self.advisory_text.set_color(color)
        actual_gap = np.linalg.norm(own - intruder)
        hyp_gap = np.linalg.norm(hypothetical - intruder)
        self.distance_text.set_text(
            f"实际两机间距  {actual_gap:,.0f} ft\n"
            f"假想两机间距  {hyp_gap:,.0f} ft\n"
            f"实际本机高度  {own[2]:,.0f} ft\n假想本机高度  {hypothetical[2]:,.0f} ft"
        )
        self.phase_text.set_text(r.phase(self.t))
        self.chart_cursor.set_xdata([self.t, self.t])
        self.chart_cursor.set_visible(self.t <= self.chart.get_xlim()[1])
        self.setting_slider = True
        self.slider.set_val(self.t)
        self.setting_slider = False
        if redraw:
            self.fig.canvas.draw_idle()

    def _seek(self, t):
        if self.setting_slider:
            return
        self.playing = False
        self.play_button.label.set_text("播放")
        self.draw_time(t)

    def _toggle(self, event=None):
        if self.t >= self.data.time[-1] and not self.playing:
            self.draw_time(0)
        self.playing = not self.playing
        self.play_button.label.set_text("暂停" if self.playing else "播放")
        self.fig.canvas.draw_idle()

    def _reset(self, event=None):
        self.playing = False
        self.play_button.label.set_text("播放")
        self.draw_time(0)

    def _speed(self, event=None):
        speeds = [0.5, 1, 2, 3, 4, 8]
        self.playback = next((v for v in speeds if v > self.playback), speeds[0])
        self.speed_button.label.set_text(f"{self.playback:g} 倍速")
        self.fig.canvas.draw_idle()

    def _key(self, event):
        if event.key == " ":
            self._toggle()
        elif event.key in ("r", "R"):
            self._reset()
        elif event.key in ("left", "right"):
            self.playing = False
            self.play_button.label.set_text("播放")
            self.draw_time(self.t + (0.5 if event.key == "right" else -0.5))
        elif event.key in ("q", "escape"):
            self.plt.close(self.fig)

    def _scroll(self, event):
        if event.inaxes is not self.ax:
            return
        self.zoom = float(
            np.clip(self.zoom * (1.1 if event.button == "up" else 1 / 1.1), 0.6, 1.7)
        )
        self.ax.set_box_aspect((2.5, 4.6, 2.4), zoom=self.zoom)
        self.fig.canvas.draw_idle()

    def run(self):
        from matplotlib.animation import FuncAnimation

        def tick(_):
            if self.playing:
                self.draw_time(self.t + self.playback / self.fps)
                if self.t >= self.data.time[-1]:
                    self.playing = False
                    self.play_button.label.set_text("播放")

        self.animation = FuncAnimation(
            self.fig, tick, interval=1000 / self.fps, cache_frame_data=False
        )
        self.plt.show()

    def save_gif(self, path):
        from matplotlib.animation import FuncAnimation, PillowWriter

        path = Path(path)
        path.parent.mkdir(parents=True, exist_ok=True)
        self.playing = False
        self.play_button.label.set_text("播放")
        frames = np.r_[
            np.arange(0, self.data.time[-1], self.playback / self.fps),
            self.data.time[-1],
        ]
        animation = FuncAnimation(
            self.fig,
            lambda t: self.draw_time(t, redraw=False),
            frames=frames,
            interval=1000 / self.fps,
            repeat=False,
            cache_frame_data=False,
        )
        animation.save(str(path), writer=PillowWriter(fps=self.fps), dpi=72)


def write_outputs(data, folder):
    folder = Path(folder)
    folder.mkdir(parents=True, exist_ok=True)
    (folder / "report.json").write_text(
        json.dumps(data.report(), ensure_ascii=False, indent=2), encoding="utf-8"
    )
    with (folder / "trajectory.csv").open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(
            [
                "time_s",
                "actual_x_ft",
                "actual_y_ft",
                "actual_z_ft",
                "intruder_x_ft",
                "intruder_y_ft",
                "intruder_z_ft",
                "hypothetical_x_ft",
                "hypothetical_y_ft",
                "hypothetical_z_ft",
                "H",
                "V",
                "lookup_status",
            ]
        )
        for t, o, i, h, q in zip(
            data.time, data.own, data.intruder, data.hypothetical, data.queries
        ):
            w.writerow(
                [
                    t,
                    *o,
                    *i,
                    *h,
                    *(q.action if q.action is not None else ("", "")),
                    q.reason,
                ]
            )


def main():
    p = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    p.add_argument("--table", type=Path, default=DEFAULT_TABLE)
    p.add_argument("--speed", type=float, default=200, help="两机水平地速，ft/s")
    p.add_argument("--altitude", type=float, default=1000, help="初始高度，ft")
    p.add_argument(
        "--destination", type=float, default=10000, help="目的地北向坐标，ft"
    )
    p.add_argument(
        "--intruder-distance", type=float, default=6000, help="入侵者初始北向坐标，ft"
    )
    p.add_argument(
        "--turn-rate", type=float, default=3, help="假想轨迹航向角速度上限，deg/s"
    )
    p.add_argument(
        "--vertical-rate", type=float, default=16.667, help="假想轨迹垂直速度上限，ft/s"
    )
    p.add_argument("--fps", type=int, default=20)
    p.add_argument("--playback", type=float, default=3)
    p.add_argument("--output-dir", type=Path, default=OUT_DIR)
    p.add_argument("--snapshot", type=Path)
    p.add_argument("--snapshot-time", type=float, default=15)
    p.add_argument("--gif", type=Path)
    p.add_argument("--no-gui", action="store_true")
    args = p.parse_args()
    if args.fps < 1 or not math.isfinite(args.playback) or args.playback <= 0:
        p.error("fps 和 playback 必须为正数")
    if args.no_gui or args.snapshot or args.gif:
        import matplotlib

        matplotlib.use("Agg")
    try:
        table = ActionTable(args.table)
        config = Config(
            speed=args.speed,
            altitude=args.altitude,
            destination=args.destination,
            intruder_distance=args.intruder_distance,
            max_turn_rate=args.turn_rate,
            max_vertical_rate=args.vertical_rate,
        )
        data = build_encounter(table, config)
    except (ValueError, OSError) as error:
        p.error(str(error))
    write_outputs(data, args.output_dir)
    print(json.dumps(data.report(), ensure_ascii=False, indent=2))
    if args.no_gui and not (args.snapshot or args.gif):
        return
    viewer = DemoViewer(data, args.fps, args.playback)
    if args.snapshot:
        args.snapshot.parent.mkdir(parents=True, exist_ok=True)
        viewer.playing = False
        viewer.play_button.label.set_text("播放")
        viewer.draw_time(args.snapshot_time)
        viewer.fig.savefig(args.snapshot, dpi=130, facecolor=viewer.fig.get_facecolor())
        print("已保存截图:", args.snapshot)
    if args.gif:
        viewer.save_gif(args.gif)
        print("已保存动画:", args.gif)
    if not (args.no_gui or args.snapshot or args.gif):
        viewer.run()


if __name__ == "__main__":
    main()
