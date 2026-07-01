import csv, math, json

# --- Copy of discretize_state from visualize.py ---
RANGE_BIN     = 500.0
ALT_BIN       = 100.0
BEARING_BIN   = 30.0
HEADING_BIN   = 30.0
INT_SPEED_BIN = 50.0
OWN_SPEED_BIN = 50.0
V_RATE_BIN    = 10.0
TAU_BIN       = 5.0

def discretize_state(r, z, b, psi, int_spd, own_spd, own_dz, int_dz, tau):
    if r <= 500.0:
        r_bin = round(r / 100.0) * 100.0
        r_bin = max(100.0, r_bin)
    elif r <= 2000.0:
        r_bin = round(r / 500.0) * 500.0
    else:
        r_bin = round(r / 1000.0) * 1000.0
    a_bin = round(z / ALT_BIN) * ALT_BIN
    b_bin = round(b / BEARING_BIN) * BEARING_BIN
    if b_bin > 180.0: b_bin -= 360.0
    psi_bin = round(psi / HEADING_BIN) * HEADING_BIN
    if psi_bin > 180.0: psi_bin -= 360.0
    int_spd_bin = round(int_spd / INT_SPEED_BIN) * INT_SPEED_BIN
    own_spd_bin = round(own_spd / OWN_SPEED_BIN) * OWN_SPEED_BIN
    own_dz_bin = round(own_dz / V_RATE_BIN) * V_RATE_BIN
    int_dz_bin = round(int_dz / V_RATE_BIN) * V_RATE_BIN
    if tau < 0:
        tau_bin = -1.0
    else:
        tau_bin = 100.0 if tau >= 100.0 else round(tau / TAU_BIN) * TAU_BIN
        tau_bin = max(TAU_BIN, tau_bin)
    return (r_bin, a_bin, b_bin, psi_bin, int_spd_bin, own_spd_bin, own_dz_bin, int_dz_bin, tau_bin)

# Load table
with open('suma/suma/my_lightweight_table.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    lookup_table = {}
    for row in reader:
        key = (
            float(row['Range(ft)']),
            float(row['Rel_Altitude(ft)']),
            float(row['Bearing(deg)']),
            float(row['Rel_Heading(deg)']),
            float(row['Intruder_Speed(fps)']),
            float(row['Own_Speed(fps)']),
            float(row['Own_Vert_Rate(fps)']),
            float(row['Int_Vert_Rate(fps)']),
            float(row['Tau(s)'])
        )
        lookup_table[key] = row['Recommended_Action']

print(f"Table has {len(lookup_table)} entries")
non_h0v0 = sum(1 for v in lookup_table.values() if v != 'H:0 | V:0')
print(f"Non-H:0|V:0 entries: {non_h0v0}")

# Test with some synthetic state values from a typical encounter
test_states = [
    (5000.0, 0.0, 0.0, 0.0, 250.0, 250.0, 0.0, 0.0, 90.0),   # far away, head-on
    (4500.0, 50.0, 5.0, 0.0, 250.0, 250.0, 0.0, 0.0, 80.0),
    (3000.0, 50.0, 10.0, 0.0, 250.0, 250.0, 0.0, 0.0, 50.0),
    (1500.0, -50.0, -5.0, 0.0, 250.0, 250.0, 0.0, 0.0, 25.0),
    (800.0, 100.0, 20.0, 0.0, 250.0, 250.0, 0.0, 0.0, 15.0),
    (500.0, 200.0, 30.0, 0.0, 250.0, 250.0, 0.0, 0.0, 10.0),
    (300.0, 150.0, 45.0, 0.0, 250.0, 250.0, 0.0, 0.0, 5.0),
]

print("\nTesting with example states:")
for s in test_states:
    dk = discretize_state(*s)
    action = lookup_table.get(dk, "H:0 | V:0 [DEFAULT]")
    action_str = "MATCH!" if action != "H:0 | V:0 [DEFAULT]" else "NO MATCH"
    print(f"  State: range={s[0]}, alt={s[1]}, bearing={s[2]}")
    print(f"    -> Discrete: {dk}")
    print(f"    -> Action: {action} ({action_str})")