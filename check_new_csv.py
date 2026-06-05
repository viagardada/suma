import csv, os, glob

# Check multiple paths for CSVs
paths = [
    'suma/my_lightweight_table.csv',
    'suma/suma/my_lightweight_table.csv',
    'suma/test_output.csv',
    'suma/suma/test_output.csv',
    'my_lightweight_table.csv',
]

for p in paths:
    if os.path.exists(p):
        total = 0
        nonzero = 0
        with open(p) as f:
            reader = csv.DictReader(f)
            for row in reader:
                total += 1
                if row['Recommended_Action'] != 'H:0 | V:0':
                    nonzero += 1
        print(f'{p}: {total} entries, {nonzero} non-zero')
    else:
        print(f'{p}: not found')

# Also check if test jl ran
print()
print('test_output.csv in suma dir:', os.path.exists('suma/test_output.csv'))