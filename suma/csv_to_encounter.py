"""
csv_to_encounter.py
Convert Remote ID CSV data to ACAS sXu DO-396 encounter JSON files for SUMA.

Strategy:
1. Group CSV rows by aircraft.uasId (drone ID), sorted by time
2. Find time-overlapping drone pairs
3. For each pair, generate an encounter JSON where:
   - Drone A = ownship (WGS84_OBS, HEADING_OBS, PRES_ALT_OBS, etc.)
   - Drone B = intruder (VEHICLE_TO_VEHICLE_REPORT)
4. Distance filter: only generate encounters where drones were < 5 NM apart
   to avoid wasting computation on irrelevant scenarios.

Usage:
    python suma/csv_to_encounter.py [--max-pairs N] [--output-dir DIR] [--no-distance-filter]
"""

import os
import json
import math
import csv
import sys
import argparse
from datetime import datetime
from collections import defaultdict

# ============ Get script directory for relative paths ============
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

# ============ Constants ============
KTS_TO_FPS = 1.68781
M_TO_FT = 3.28084
FPS_TO_KTS = 1.0 / 1.68781
DEG_TO_RAD = math.pi / 180.0
RAD_TO_DEG = 180.0 / math.pi
NM_TO_FT = 6076.115
FT_TO_NM = 1.0 / NM_TO_FT

# Default distance threshold: 5 NM
DEFAULT_DIST_NM = 5.0

# Time tolerance: how close (in ms) two drones' timestamps need to be
# to consider them "same time". Default 100ms.
TIME_TOLERANCE_MS = 100

# Default paths relative to script location (script is at suma/ subfolder, CSV is one level deeper)
DEFAULT_CSV_PATH = os.path.join(SCRIPT_DIR, '..', 'suma', 'input_data', 'Apr 1t.csv')
DEFAULT_OUTPUT_DIR = os.path.join(SCRIPT_DIR, '..', 'suma', 'input_data', 'encounters')

# Minimum encounter duration: only generate if at least this many seconds of overlap
MIN_ENCOUNTER_DURATION_S = 5

# ============ Helper Functions ============

def lat_lon_to_xy_m(lat1_deg, lon1_deg, lat2_deg, lon2_deg):
    """Convert lat/lon difference to approximate meters (north, east)."""
    lat1 = lat1_deg * DEG_TO_RAD
    lon1 = lon1_deg * DEG_TO_RAD
    lat2 = lat2_deg * DEG_TO_RAD
    lon2 = lon2_deg * DEG_TO_RAD
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    R_m = 6371000  # Earth radius in meters
    north = dlat * R_m
    east = dlon * R_m * math.cos(lat1)
    return east, north


def calc_distance_nm(lat1, lon1, lat2, lon2):
    """Calculate approximate distance in NM between two lat/lon points."""
    e, n = lat_lon_to_xy_m(lat1, lon1, lat2, lon2)
    dist_m = math.sqrt(e**2 + n**2)
    return dist_m * 0.000539957  # meters to NM


def horizontal_speed_to_components(speed_ms, direction_deg):
    """
    Convert horizontal speed (m/s) and direction (degrees clockwise from north)
    to north and east velocity components in knots.
    """
    speed_kts = speed_ms * 1.94384  # m/s to knots
    heading_rad = direction_deg * DEG_TO_RAD
    vel_n_kts = speed_kts * math.cos(heading_rad)
    vel_e_kts = speed_kts * math.sin(heading_rad)
    return vel_n_kts, vel_e_kts


def load_csv_data(csv_path):
    """
    Load CSV and group data by drone ID.
    Returns: dict { drone_id: [{ row_dict }, ...] }
    Each group is sorted by time.
    """
    print(f"Loading {csv_path}...")
    drone_data = defaultdict(list)
    total_rows = 0

    f = open(csv_path, 'r', encoding='utf-8-sig')
    reader = csv.DictReader(f)
    for row in reader:
        uid = row['aircraft.uasId']
        drone_data[uid].append(row)
        total_rows += 1
        if total_rows % 100000 == 0:
            print(f"  Read {total_rows} rows...")
    f.close()

    print(f"  Total rows: {total_rows}")
    print(f"  Total drones: {len(drone_data)}")

    # Sort each drone's data by time
    for uid in drone_data:
        drone_data[uid].sort(key=lambda r: int(r['time']) if r['time'] else 0)

    return drone_data


def extract_float(row, key, default=0.0):
    """Safely extract float from CSV row."""
    val = row.get(key, '')
    if val is None or val == '':
        return default
    try:
        return float(val)
    except (ValueError, TypeError):
        return default


def get_drone_time_range(rows):
    """Get min and max timestamp for a drone's data."""
    times = [int(r['time']) if r['time'] else 0 for r in rows]
    return min(times), max(times)


def get_drone_avg_location(rows):
    """Get average lat/lon for a drone."""
    lats = [extract_float(r, 'location.latitude') for r in rows]
    lons = [extract_float(r, 'location.longitude') for r in rows]
    return sum(lats)/len(lats), sum(lons)/len(lons)


def find_time_overlapping_pairs(drone_data, min_overlap_ms=5000, geo_cell_deg=1.0):
    """
    Find pairs of drones whose time ranges overlap by at least min_overlap_ms.
    Only pairs drones within the same geographic grid cell (geo_cell_deg in degrees).
    Returns: list of (uid_a, uid_b, overlap_start_ms, overlap_end_ms)
    """
    from collections import defaultdict

    # Get time ranges and average location for each drone
    drone_meta = {}
    for uid, rows in drone_data.items():
        t_min, t_max = get_drone_time_range(rows)
        if t_max - t_min >= min_overlap_ms:
            avg_lat, avg_lon = get_drone_avg_location(rows)
            drone_meta[uid] = (t_min, t_max, avg_lat, avg_lon)

    # Group by geographic cell
    cells = defaultdict(list)
    for uid, (t_min, t_max, lat, lon) in drone_meta.items():
        cell_x = round(lon / geo_cell_deg)
        cell_y = round(lat / geo_cell_deg)
        cells[(cell_x, cell_y)].append((uid, t_min, t_max, lat, lon))

    print(f"Finding overlapping pairs among {len(drone_meta)} drones in {len(cells)} geographic cells...")

    pairs = []
    for cell_key, drone_list in cells.items():
        if len(drone_list) < 2:
            continue
        for i in range(len(drone_list)):
            uid_a, t_a_min, t_a_max, lat_a, lon_a = drone_list[i]
            for j in range(i + 1, len(drone_list)):
                uid_b, t_b_min, t_b_max, lat_b, lon_b = drone_list[j]
                # Check time overlap
                overlap_start = max(t_a_min, t_b_min)
                overlap_end = min(t_a_max, t_b_max)
                if overlap_end - overlap_start >= min_overlap_ms:
                    pairs.append((uid_a, uid_b, overlap_start, overlap_end))

    print(f"  Found {len(pairs)} overlapping pairs within same geographic cells")
    return pairs, drone_meta


def build_time_index(drone_rows):
    """
    Build a time-indexed lookup for a drone's data.
    Returns: list of (time_ms, row) sorted by time
    """
    indexed = []
    for row in drone_rows:
        t = int(row['time']) if row['time'] else 0
        indexed.append((t, row))
    return indexed


def get_state_at_time(indexed_rows, target_time_ms, tolerance_ms=500):
    """Find the closest row within tolerance_ms of target_time_ms."""
    if not indexed_rows:
        return None

    # Binary search
    lo, hi = 0, len(indexed_rows) - 1
    best_idx = 0
    best_diff = abs(indexed_rows[0][0] - target_time_ms)

    while lo <= hi:
        mid = (lo + hi) // 2
        t = indexed_rows[mid][0]
        diff = abs(t - target_time_ms)
        if diff < best_diff:
            best_diff = diff
            best_idx = mid
        if t < target_time_ms:
            lo = mid + 1
        elif t > target_time_ms:
            hi = mid - 1
        else:
            break

    if best_diff <= tolerance_ms:
        return indexed_rows[best_idx][1]
    return None


def row_to_ownship_report(row, report_time, v2v_uid="111"):
    """Convert a CSV row to ownship reports (list of dicts)."""
    reports = []

    lat = extract_float(row, 'location.latitude')
    lon = extract_float(row, 'location.longitude')
    alt_m = extract_float(row, 'location.geodeticAltitude', 0)
    alt_ft = alt_m * M_TO_FT
    press_alt_m = extract_float(row, 'location.pressureAltitude', alt_m)
    press_alt_ft = press_alt_m * M_TO_FT
    speed_ms = extract_float(row, 'location.horizontalSpeed', 0)
    direction_deg = extract_float(row, 'location.direction', 0)
    vert_speed_ms = extract_float(row, 'location.verticalSpeed', 0)
    vert_speed_fps = vert_speed_ms * M_TO_FT  # m/s to ft/s

    # Resolve vertical speed - if CSV has 0, keep it, SUMA will handle it
    vert_rate = vert_speed_fps if abs(vert_speed_fps) > 0.01 else 0.0
    # If altitude changes can be derived, use that instead
    # But for simplicity, use the CSV value directly

    vel_n_kts, vel_e_kts = horizontal_speed_to_components(speed_ms, direction_deg)
    heading_rad = direction_deg * DEG_TO_RAD

    # 1. OWNSHIP_DISCRETES
    reports.append({
        "report_time": report_time,
        "report_type": "Acas_sXu_DO396",
        "acas_sxu_do396": {
            "data_type": "OWNSHIP_DISCRETES",
            "ownship_discretes": {
                "toa": report_time,
                "v2v_uid": v2v_uid,
                "opflg": True,
                "requested_opmode": 3,
                "effective_turn_rate_rad": 0.053,
                "effective_vert_rate_fps": 16.667,
                "prefer_wind_relative": False,
                "perform_poa": False,
                "disable_gpoa": False,
                "equipment": 15
            }
        }
    })

    # 2. HEADING_OBS
    reports.append({
        "report_time": report_time + 0.001,
        "report_type": "Acas_sXu_DO396",
        "acas_sxu_do396": {
            "data_type": "HEADING_OBS",
            "heading_obs": {
                "toa": report_time + 0.001,
                "psi_rad": heading_rad,
                "heading_degraded": False
            }
        }
    })

    # 3. PRES_ALT_OBS
    reports.append({
        "report_time": report_time + 0.002,
        "report_type": "Acas_sXu_DO396",
        "acas_sxu_do396": {
            "data_type": "PRES_ALT_OBS",
            "pres_alt_obs": {
                "toa": report_time + 0.002,
                "alt_pres_ft": press_alt_ft
            }
        }
    })

    # 4. HEIGHT_AGL_OBS
    reports.append({
        "report_time": report_time + 0.003,
        "report_type": "Acas_sXu_DO396",
        "acas_sxu_do396": {
            "data_type": "HEIGHT_AGL_OBS",
            "height_agl_obs": {
                "toa": report_time + 0.003,
                "h_ft": alt_ft
            }
        }
    })

    # 5. WGS84_OBS (ownship GPS position + velocity)
    reports.append({
        "report_time": report_time + 0.004,
        "report_type": "Acas_sXu_DO396",
        "acas_sxu_do396": {
            "data_type": "WGS84_OBS",
            "wgs84_obs": {
                "toa": report_time + 0.004,
                "lat_deg": lat,
                "lon_deg": lon,
                "vel_ew_kts": vel_e_kts,
                "vel_ns_kts": vel_n_kts,
                "alt_hae_ft": alt_ft,
                "alt_rate_hae_fps": vert_rate,
                "nacp": 10,
                "nacv": 3,
                "vfom_m": 8.0
            }
        }
    })

    return reports


def row_to_intruder_report(row, report_time, intruder_id="100", mode_s=100):
    """Convert a CSV row to intruder reports (list of dicts)."""
    reports = []

    lat = extract_float(row, 'location.latitude')
    lon = extract_float(row, 'location.longitude')
    alt_m = extract_float(row, 'location.geodeticAltitude', 0)
    alt_ft = alt_m * M_TO_FT
    press_alt_m = extract_float(row, 'location.pressureAltitude', alt_m)
    press_alt_ft = press_alt_m * M_TO_FT
    speed_ms = extract_float(row, 'location.horizontalSpeed', 0)
    direction_deg = extract_float(row, 'location.direction', 0)
    vert_speed_ms = extract_float(row, 'location.verticalSpeed', 0)
    vert_speed_fps = vert_speed_ms * M_TO_FT

    vel_n_kts, vel_e_kts = horizontal_speed_to_components(speed_ms, direction_deg)

    # 1. AIRBORNE_POSITION_REPORT (ADS-B position)
    reports.append({
        "report_time": report_time,
        "report_type": "Acas_sXu_DO396",
        "acas_sxu_do396": {
            "data_type": "AIRBORNE_POSITION_REPORT",
            "airborne_position_report": {
                "toa": report_time,
                "mode_s": mode_s,
                "non_icao": False,
                "lat_deg": lat,
                "lon_deg": lon,
                "alt_ft": press_alt_ft,
                "is_alt_geo_hae": False,
                "q_int_ft": 25,
                "nic": 8
            }
        }
    })

    # 2. AIRBORNE_VELOCITY_REPORT (ADS-B velocity)
    reports.append({
        "report_time": report_time + 0.011,
        "report_type": "Acas_sXu_DO396",
        "acas_sxu_do396": {
            "data_type": "AIRBORNE_VELOCITY_REPORT",
            "airborne_velocity_report": {
                "toa": report_time + 0.011,
                "mode_s": mode_s,
                "non_icao": False,
                "vel_ns_kts": vel_n_kts,
                "vel_ew_kts": vel_e_kts,
                "nic": 8
            }
        }
    })

    # 3. VEHICLE_TO_VEHICLE_REPORT (V2V report)
    reports.append({
        "report_time": report_time + 0.041,
        "report_type": "Acas_sXu_DO396",
        "acas_sxu_do396": {
            "data_type": "VEHICLE_TO_VEHICLE_REPORT",
            "vehicle_to_vehicle_report": {
                "toa": report_time + 0.041,
                "v2v_uid": intruder_id,
                "mode_s": mode_s,
                "mode_s_non_icao": False,
                "mode_s_valid": True,
                "lat_deg": lat,
                "lon_deg": lon,
                "vel_ns_kts": vel_n_kts,
                "vel_ew_kts": vel_e_kts,
                "alt_pres_ft": press_alt_ft,
                "alt_hae_ft": alt_ft,
                "nacp": 10,
                "nacv": 2,
                "vfom_m": 8,
                "sil": 3,
                "sda": 1,
                "nic": 7,
                "q_int": 1,
                "classification": 1
            }
        }
    })

    # 4. EXTERNALLY_VALIDATED_V2V
    reports.append({
        "report_time": report_time + 0.042,
        "report_type": "Acas_sXu_DO396",
        "acas_sxu_do396": {
            "data_type": "EXTERNALLY_VALIDATED_V2V",
            "externally_validated_v2v": {
                "toa": report_time + 0.042,
                "externally_validated": True,
                "v2v_uid": intruder_id
            }
        }
    })

    return reports


def generate_encounter_json(ownship_id, intruder_id, ownship_rows, intruder_rows,
                            overlap_start_ms, overlap_end_ms, output_dir,
                            distance_filter_nm=DEFAULT_DIST_NM):
    """
    Generate an encounter JSON file for a pair of drones.
    
    Returns: (output_path, num_steps) or (None, 0) if filtered out.
    """
    # Build time-indexed lookups
    ownship_indexed = build_time_index(ownship_rows)
    intruder_indexed = build_time_index(intruder_rows)

    # Generate time steps at 1-second intervals
    step_ms = 1000  # 1 second
    start_time_s = overlap_start_ms / 1000.0
    # Round to next second boundary
    start_time_s = math.ceil(start_time_s)
    end_time_s = overlap_end_ms / 1000.0

    # Check minimum duration
    if end_time_s - start_time_s < MIN_ENCOUNTER_DURATION_S:
        return None, 0

    reports = []
    time_step = 0
    ownship_v2v_uid = f"OS_{ownship_id[-6:]}"
    intruder_v2v_uid = f"IN_{intruder_id[-6:]}"
    mode_s_id = abs(hash(intruder_id)) % 1000 + 1  # deterministic ID

    # First, check if any step has drones within distance threshold
    steps_to_process = []
    current_ms = overlap_start_ms
    ownship_start_lat = None
    ownship_start_lon = None
    any_within_range = False

    while current_ms <= overlap_end_ms:
        ow_row = get_state_at_time(ownship_indexed, current_ms, TIME_TOLERANCE_MS)
        in_row = get_state_at_time(intruder_indexed, current_ms, TIME_TOLERANCE_MS)

        if ow_row is None or in_row is None:
            current_ms += step_ms
            continue

        ow_lat = extract_float(ow_row, 'location.latitude')
        ow_lon = extract_float(ow_row, 'location.longitude')
        in_lat = extract_float(in_row, 'location.latitude')
        in_lon = extract_float(in_row, 'location.longitude')

        if ownship_start_lat is None:
            ownship_start_lat = ow_lat
            ownship_start_lon = ow_lon

        dist_nm = calc_distance_nm(ow_lat, ow_lon, in_lat, in_lon)

        if distance_filter_nm is None or dist_nm <= distance_filter_nm:
            any_within_range = True
            report_time = current_ms / 1000.0
            steps_to_process.append((current_ms, report_time, ow_row, in_row, dist_nm))

        current_ms += step_ms

    if not any_within_range and distance_filter_nm is not None:
        return None, 0

    # Generate reports for each time step
    for current_ms, report_time, ow_row, in_row, dist_nm in steps_to_process:
        # Ownship reports
        own_reports = row_to_ownship_report(ow_row, report_time, ownship_v2v_uid)
        reports.extend(own_reports)

        # Intruder reports
        # Use last 4 chars of intruder_id as identifier
        intr_reports = row_to_intruder_report(in_row, report_time + 0.01,
                                              intruder_v2v_uid, mode_s_id)
        reports.extend(intr_reports)
        time_step += 1

    if time_step < MIN_ENCOUNTER_DURATION_S:
        return None, 0

    # Build encounter JSON
    encounter = {
        "playback_header": {
            "description": {
                "text": f"Encounter from RID data: Ownship={ownship_id}, Intruder={intruder_id}",
                "info": {
                    "testgroup": 0,
                    "prescriptive": False
                }
            },
            "start_time": overlap_start_ms / 1000.0,
            "has_timing_control": False
        },
        "acasx_reports": reports
    }

    # Create output filename
    own_short = ownship_id[-8:] if len(ownship_id) > 8 else ownship_id
    int_short = intruder_id[-8:] if len(intruder_id) > 8 else intruder_id
    filename = f"Encounter_{own_short}_vs_{int_short}.json"
    output_path = os.path.join(output_dir, filename)

    os.makedirs(output_dir, exist_ok=True)
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(encounter, f, indent=2)

    return output_path, time_step


def main():
    parser = argparse.ArgumentParser(description='Convert RID CSV to SUMA encounter JSON')
    parser.add_argument('--csv', type=str, default=DEFAULT_CSV_PATH,
                        help='Input CSV file path')
    parser.add_argument('--output-dir', type=str, default=DEFAULT_OUTPUT_DIR,
                        help='Output directory for encounter JSON files')
    parser.add_argument('--max-pairs', type=int, default=None,
                        help='Maximum number of encounter pairs to generate (for testing)')
    parser.add_argument('--no-distance-filter', action='store_true',
                        help='Disable distance filter (generate all pairs regardless of distance)')
    parser.add_argument('--distance-nm', type=float, default=DEFAULT_DIST_NM,
                        help=f'Distance threshold in NM (default: {DEFAULT_DIST_NM})')
    parser.add_argument('--min-duration-s', type=int, default=MIN_ENCOUNTER_DURATION_S,
                        help=f'Minimum encounter duration in seconds (default: {MIN_ENCOUNTER_DURATION_S})')
    parser.add_argument('--all-pairs', action='store_true',
                        help='Generate all overlapping pairs (not just one vs all)')
    args = parser.parse_args()

    csv_path = args.csv
    output_dir = args.output_dir
    dist_filter = None if args.no_distance_filter else args.distance_nm

    print("=" * 60)
    print("CSV to SUMA Encounter Converter")
    print("=" * 60)
    print(f"Input: {csv_path}")
    print(f"Output: {output_dir}")
    print(f"Distance filter: {'OFF' if dist_filter is None else f'{dist_filter} NM'}")
    print(f"Min duration: {args.min_duration_s}s")
    print("=" * 60)

    # Load data
    drone_data = load_csv_data(csv_path)

    # Filter: only drones with enough data
    min_rows = 5
    min_duration_ms = args.min_duration_s * 1000
    filtered_drone_data = {}
    for uid, rows in drone_data.items():
        t_min, t_max = get_drone_time_range(rows)
        if len(rows) >= min_rows and (t_max - t_min) >= min_duration_ms:
            filtered_drone_data[uid] = rows

    print(f"Drones with >= {min_rows} rows and >= {args.min_duration_s}s duration: {len(filtered_drone_data)}")

    # Find pairs
    pairs, time_ranges = find_time_overlapping_pairs(
        filtered_drone_data, min_overlap_ms=min_duration_ms)

    # Apply max pairs limit
    if args.max_pairs and len(pairs) > args.max_pairs:
        print(f"Limiting to {args.max_pairs} pairs (out of {len(pairs)})")
        pairs = pairs[:args.max_pairs]

    print(f"\nGenerating {len(pairs)} encounters...")

    # Generate encounters
    generated = 0
    filtered_out = 0
    total_steps = 0
    for idx, (uid_a, uid_b, overlap_start, overlap_end) in enumerate(pairs):
        result, steps = generate_encounter_json(
            uid_a, uid_b,
            filtered_drone_data[uid_a], filtered_drone_data[uid_b],
            overlap_start, overlap_end,
            output_dir,
            distance_filter_nm=dist_filter
        )

        if result:
            generated += 1
            total_steps += steps
            if generated % 10 == 0:
                print(f"  Generated {generated}/{len(pairs)} encounters...")
        else:
            filtered_out += 1

        # Also generate the reverse pair if all_pairs mode
        if args.all_pairs:
            result2, steps2 = generate_encounter_json(
                uid_b, uid_a,
                filtered_drone_data[uid_b], filtered_drone_data[uid_a],
                overlap_start, overlap_end,
                output_dir,
                distance_filter_nm=dist_filter
            )
            if result2:
                generated += 1
                total_steps += steps2

    print(f"\n{'=' * 60}")
    print(f"Summary:")
    print(f"  Total pairs processed: {len(pairs)}")
    print(f"  Encounters generated: {generated}")
    print(f"  Filtered out (beyond distance threshold): {filtered_out}")
    print(f"  Total time steps across all encounters: {total_steps}")
    print(f"  Output directory: {os.path.abspath(output_dir)}")
    print(f"{'=' * 60}")


if __name__ == '__main__':
    main()