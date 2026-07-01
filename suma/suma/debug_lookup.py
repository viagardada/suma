import csv

# Load table
with open('suma/suma/my_lightweight_table.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    rows = list(reader)
    
print(f"Total rows: {len(rows)}")

# Check actions
actions = set(r['Recommended_Action'] for r in rows)
print(f"Unique actions: {actions}")

# Check a few non-default entries
non_default = [r for r in rows if r['Recommended_Action'] != 'H:0 | V:0']
print(f"Non-default entries: {len(non_default)}")
for r in non_default[:5]:
    print(r)

# Check default actions
default = [r for r in rows if r['Recommended_Action'] == 'H:0 | V:0']
print(f"Default entries: {len(default)}")