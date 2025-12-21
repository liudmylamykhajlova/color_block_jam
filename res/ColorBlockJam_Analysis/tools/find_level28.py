import json

with open('res/ColorBlockJam_Analysis/level_data/parsed_levels_complete.json', 'r') as f:
    parsed = json.load(f)
    
# Find all levels with '28' in name
print('All levels containing "28" in name:')
for i, level in enumerate(parsed):
    name = level.get('name', '')
    if '28' in name:
        grid = level.get('gridSize', {})
        gx = grid.get('x', '?')
        gy = grid.get('y', '?')
        print(f'  Index {i}: {name}, grid: {gx}x{gy}')
        
# Find first 50 level names
print()
print('First 60 levels:')
for i in range(min(60, len(parsed))):
    name = parsed[i].get('name', '')
    grid = parsed[i].get('gridSize', {})
    gx = grid.get('x', '?')
    gy = grid.get('y', '?')
    print(f'  {i+1}. {name}, grid: {gx}x{gy}')
