import json
import math
import os
import sys

def js_round(x):
    if x - math.floor(x) == 0.5:
        return math.floor(x) if math.floor(x) % 2 == 0 else math.ceil(x)
    return round(x)

script_dir = os.path.dirname(os.path.abspath(__file__))
base_dir = os.path.dirname(script_dir)

data = json.load(open(os.path.join(base_dir, 'level_data/parsed_levels_complete.json')))
game_order = ['Level 1', 'Level 2', 'Level 3', 'Level 4', 'Level 5', 'Level 6', 'Level 8', 'Level 9', 'Derin Level 7', 'New Level 4', 'Level 45', 'Level 12', 'Level 14', 'Derin Level 9', 'Level 18', 'Level 25', 'New Level 29', 'Level 33', 'New Level 26', 'Derin Level 15', 'Level 36']

if '--hidden' in sys.argv:
    print('Levels with fully hidden edge columns:')
    print('=' * 80)
    for i, name in enumerate(game_order):
        level = next((l for l in data if l['name'] == name), None)
        if not level: continue
        hidden = level.get('hiddenCoords', [])
        if hidden:
            grid_w = level['gridSize']['x']
            grid_h = level['gridSize']['y']
            
            col0_hidden = set()
            col_last_hidden = set()
            for h in hidden:
                if h['x'] == 0:
                    col0_hidden.add(h['y'])
                if h['x'] == grid_w - 1:
                    col_last_hidden.add(h['y'])
            
            all_col0_hidden = len(col0_hidden) == grid_h
            all_collast_hidden = len(col_last_hidden) == grid_h
            
            if all_col0_hidden or all_collast_hidden:
                print(f'Game {i+1:2} {name:15}: grid={grid_w}x{grid_h}, col0_all_hidden={all_col0_hidden}, col{grid_w-1}_all_hidden={all_collast_hidden}')
            elif len(col0_hidden) > 0 or len(col_last_hidden) > 0:
                print(f'Game {i+1:2} {name:15}: grid={grid_w}x{grid_h}, col0_hidden={len(col0_hidden)}/{grid_h}, col{grid_w-1}_hidden={len(col_last_hidden)}/{grid_h}')
    sys.exit(0)

if '--blocks' in sys.argv:
    print('ShortL (blockGroupType=5) with rotZ=2:')
    print('=' * 80)
    for i, name in enumerate(game_order):
        level = next((l for l in data if l['name'] == name), None)
        if not level: continue
        for b in level.get('gameBlocks', []):
            if b['blockGroupType'] == 5:
                rotZ = round(b['rotation']['z'] / 90) % 4
                if rotZ == 2:
                    has_hidden = len(level.get('hiddenCoords', [])) > 0
                    bt = b['blockType']
                    wy = b['position']['y']
                    print(f'Game {i+1:2} {name:15}: color={bt} worldY={wy:6.2f} hidden={has_hidden}')
    
    print()
    print('ShortT (blockGroupType=8) with rotZ=2:')
    print('=' * 80)
    for i, name in enumerate(game_order):
        level = next((l for l in data if l['name'] == name), None)
        if not level: continue
        for b in level.get('gameBlocks', []):
            if b['blockGroupType'] == 8:
                rotZ = round(b['rotation']['z'] / 90) % 4
                if rotZ == 2:
                    bt = b['blockType']
                    wy = b['position']['y']
                    print(f'Game {i+1:2} {name:15}: color={bt} worldY={wy:6.2f}')
    
    print()
    print('ReverseL (blockGroupType=4) with rotZ=3:')
    print('=' * 80)
    for i, name in enumerate(game_order):
        level = next((l for l in data if l['name'] == name), None)
        if not level: continue
        for b in level.get('gameBlocks', []):
            if b['blockGroupType'] == 4:
                rotZ = round(b['rotation']['z'] / 90) % 4
                if rotZ == 3:
                    bt = b['blockType']
                    wy = b['position']['y']
                    wx = b['position']['x']
                    print(f'Game {i+1:2} {name:15}: color={bt} worldX={wx:6.2f} worldY={wy:6.2f}')
    
    sys.exit(0)

if '--grid-parity' in sys.argv:
    # Check grid height parity for all levels
    print('Grid height parity for verified levels:')
    print('=' * 60)
    for i, name in enumerate(game_order):
        level = next((l for l in data if l['name'] == name), None)
        if not level: continue
        grid_h = level['gridSize']['y']
        parity = 'ODD' if grid_h % 2 == 1 else 'even'
        print(f'Game {i+1:2} {name:15}: grid_h={grid_h} ({parity})')
    sys.exit(0)

if '--raw-row' in sys.argv:
    # Find all doors where raw_row is close to .5 (ambiguous)
    print('Doors with raw_row near .5 boundary (±0.1):')
    print('=' * 100)
    for i, name in enumerate(game_order):
        level = next((l for l in data if l['name'] == name), None)
        if not level: continue
        grid_h = level['gridSize']['y']
        grid_w = level['gridSize']['x']
        
        for d in level.get('doors', []):
            x = d['position']['x']
            y = d['position']['y']
            if abs(x) >= grid_w + 0.5:  # Side door
                offset_y = (grid_h - 1) / 2
                raw_row = -y / 2.0 + offset_y
                decimal = raw_row - int(raw_row)
                
                if 0.4 < decimal < 0.6:  # Close to .5
                    edge = 'right' if x > 0 else 'left'
                    row_center = js_round(raw_row)
                    parts = d['doorPartCount']
                    if y < -2:
                        row = row_center - (parts - 1) // 2
                    else:
                        row = row_center - parts // 2
                    print(f'Game {i+1:2} {name:15}: {edge} type={d["blockType"]} y={y:.2f} raw_row={raw_row:.2f} decimal={decimal:.2f} row={row} parts={parts}')
    sys.exit(0)

if '--door-calc' in sys.argv:
    # Calculate door positions in detail to find patterns
    print('Detailed door row calculation for doors needing offset:')
    print('=' * 100)
    
    # Known doors that need offset:
    # Level 25: right blue (type=0) at y=-3.0 needs row-1
    # Level 36: left orange (type=7) at y=-2.05 needs row-1
    
    check_levels = ['Level 25', 'Level 36']
    for name in check_levels:
        level = next((l for l in data if l['name'] == name), None)
        if not level: continue
        
        grid_h = level['gridSize']['y']
        grid_w = level['gridSize']['x']
        
        print(f'\n{name} (grid {grid_w}x{grid_h}):')
        for d in level.get('doors', []):
            x = d['position']['x']
            y = d['position']['y']
            parts = d['doorPartCount']
            
            if abs(x) >= grid_w + 0.5:  # Side door
                edge = 'right' if x > 0 else 'left'
                offset_y = (grid_h - 1) / 2
                raw_row = -y / 2.0 + offset_y
                row_center = js_round(raw_row)
                
                # Current algorithm
                if y < -2:
                    row = row_center - (parts - 1) // 2
                else:
                    row = row_center - parts // 2
                row_clamped = max(0, min(row, grid_h - parts))
                
                # Check remainder
                y_half = y / 2.0
                decimal_part = y_half - int(y_half)
                
                print(f'  {edge} type={d["blockType"]} y={y:.2f} parts={parts}')
                print(f'    offset_y={offset_y} raw_row={raw_row:.2f} row_center={row_center}')
                print(f'    y/2={y_half:.2f} decimal={decimal_part:.3f}')
                print(f'    calculated row={row} clamped={row_clamped}')
                if grid_h % 2 == 1 and abs(decimal_part - 0.5) < 0.1:
                    print(f'    -> Odd grid height with y/2 close to .5 - might need adjustment')
    
    sys.exit(0)

print('Analyzing ALL side doors to find patterns:')
print('=' * 100)
print(f'{"Game":5} {"Level":15} {"Edge":5} {"Type":4} {"worldY":8} {"Parts":5} {"GridH":5} {"RowCtr":6} {"Row":4} {"y%2":6}')
print('=' * 100)

for i, name in enumerate(game_order):
    level = next((l for l in data if l['name'] == name), None)
    if not level: continue
    grid_h = level['gridSize']['y']
    grid_w = level['gridSize']['x']
    
    for d in level.get('doors', []):
        x = d['position']['x']
        y = d['position']['y']
        parts = d['doorPartCount']
        
        # Side doors only
        if abs(x) >= grid_w + 0.5:
            offset_y = (grid_h - 1) / 2
            row_center = js_round(-y / 2.0 + offset_y)
            
            # Current algorithm
            if y < -2:
                row = row_center - (parts - 1) // 2
            else:
                row = row_center - parts // 2
            row = max(0, min(row, grid_h - parts))
            
            edge = 'right' if x > 0 else 'left'
            y_mod = y % 2  # Check pattern
            print(f'{i+1:5} {name:15} {edge:5} {d["blockType"]:4} {y:8.2f} {parts:5} {grid_h:5} {row_center:6} {row:4} {y_mod:6.2f}')

