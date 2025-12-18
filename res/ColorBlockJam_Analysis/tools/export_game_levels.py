#!/usr/bin/env python3
"""Exports first 15 levels to game-friendly JSON format."""

import json
import os

import math

def js_round(x):
    """JavaScript-style rounding (0.5 rounds up, not banker's rounding)."""
    if x >= 0:
        return int(x + 0.5)
    else:
        return int(x - 0.5) if (x - int(x)) == -0.5 else round(x)

def world_to_grid(world_x, world_y, grid_width, grid_height):
    """Convert world coordinates to grid coordinates (center of block)."""
    cell_size = 2.0
    offset_x = (grid_width - 1) / 2
    offset_y = (grid_height - 1) / 2
    col = js_round(world_x / cell_size + offset_x)
    row = js_round(-world_y / cell_size + offset_y)
    return int(row), int(col)

def get_door_edge(world_x, world_y, grid_width, grid_height):
    """Determine which edge a door is on."""
    side_threshold = max(3.5, grid_width + 0.5)
    if abs(world_x) >= side_threshold:
        return 'left' if world_x < 0 else 'right'
    else:
        return 'top' if world_y > 0 else 'bottom'

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    base_dir = os.path.dirname(script_dir)
    
    # Load data
    with open(os.path.join(base_dir, 'level_data/parsed_levels_complete.json'), 'r', encoding='utf-8') as f:
        levels_data = json.load(f)
    
    with open(os.path.join(base_dir, 'level_data/AllLevels_guids.json'), 'r', encoding='utf-8') as f:
        guids_data = json.load(f)
    
    guids = guids_data['level_guids']
    guid_to_level = {level['guid']: level for level in levels_data}
    
    # Convert levels
    game_levels = []
    for i in range(27):
        level = guid_to_level.get(guids[i])
        if not level:
            continue
        
        grid_w = level['gridSize']['x']
        grid_h = level['gridSize']['y']
        
        # Convert blocks - зберігаємо ЦЕНТР блоку (як у візуалізаторі)
        blocks = []
        for b in level['gameBlocks']:
            center_row, center_col = world_to_grid(b['position']['x'], b['position']['y'], grid_w, grid_h)
            rot_z = round(b.get('rotation', {}).get('z', 0) / 90) % 4
            
            blocks.append({
                'blockType': b['blockType'],
                'blockGroupType': b['blockGroupType'],
                'gridRow': center_row,
                'gridCol': center_col,
                'rotationZ': rot_z
            })
        
        # Convert doors
        doors = []
        for d in level['doors']:
            edge = get_door_edge(d['position']['x'], d['position']['y'], grid_w, grid_h)
            row, col = world_to_grid(d['position']['x'], d['position']['y'], grid_w, grid_h)
            parts = d['doorPartCount']
            
            # Adjust position for doors
            if edge in ['left', 'right']:
                col = 0 if edge == 'left' else grid_w - 1
                if abs(d['position']['y']) < 0.5:
                    row = (grid_h - parts) // 2
                else:
                    offset_y = (grid_h - 1) / 2
                    row_center = js_round(-d['position']['y'] / 2.0 + offset_y)
                    if d['position']['y'] < -2:
                        row = row_center - (parts - 1) // 2
                    else:
                        row = row_center - parts // 2
                row = max(0, min(row, grid_h - parts))
            else:
                # Для top/bottom дверей: row - це положення на межі (зовнішнє)
                row = -1 if edge == 'top' else grid_h
                if abs(d['position']['x']) < 0.5:
                    col = (grid_w - parts) // 2
                else:
                    offset_x = (grid_w - 1) / 2
                    col_center = js_round(d['position']['x'] / 2.0 + offset_x)
                    col = col_center - parts // 2
                col = max(0, min(col, grid_w - parts))
            
            doors.append({
                'blockType': d['blockType'],
                'partCount': parts,
                'edge': edge,
                'startRow': int(row),
                'startCol': int(col)
            })
        
        # Convert hidden coords
        hidden = []
        for h in level.get('hiddenCoords', []):
            hidden.append({
                'row': grid_h - 1 - h['y'],
                'col': h['x']
            })
        
        game_levels.append({
            'id': i + 1,
            'name': level['name'],
            'gridWidth': grid_w,
            'gridHeight': grid_h,
            'blocks': blocks,
            'doors': doors,
            'hiddenCells': hidden
        })
    
    # Save - go up 2 levels from ColorBlockJam_Analysis to project root
    project_root = os.path.dirname(os.path.dirname(base_dir))
    output_dir = os.path.join(project_root, 'assets', 'levels')
    os.makedirs(output_dir, exist_ok=True)
    
    output_path = os.path.join(output_dir, 'levels_27.json')
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump({'levels': game_levels}, f, indent=2, ensure_ascii=False)
    
    print(f'Exported {len(game_levels)} levels to {output_path}')
    for lvl in game_levels:
        print(f"  Level {lvl['id']}: {lvl['name']} ({lvl['gridWidth']}x{lvl['gridHeight']}, {len(lvl['blocks'])} blocks, {len(lvl['doors'])} doors)")

if __name__ == '__main__':
    main()

