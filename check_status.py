import os, datetime, csv

csv_path = 'suma/my_lightweight_table.csv'
t = os.path.getmtime(csv_path)
print(f'CSV last modified: {datetime.datetime.fromtimestamp(t)}')

total = 0
nonzero = 0
with open(csv_path) as f:
    for row in csv.DictReader(f):
        total += 1
        if row['Recommended_Action'] != 'H:0 | V:0':
            nonzero += 1
print(f'Total: {total}, Non-zero: {nonzero}')

import subprocess
result = subprocess.run(['tasklist', '/fi', 'imagename eq julia.exe'], capture_output=True, text=True)
if 'julia.exe' in result.stdout:
    # count instances
    count = result.stdout.count('julia.exe')
    print(f'Julia processes running: {count}')
else:
    print('Julia: not running')