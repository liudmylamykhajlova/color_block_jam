#!/usr/bin/env python3
"""Exports levels to game-friendly JSON format with hardness and duration."""

import json
import os

import math

def load_hardness_data(base_dir):
    """Load hardness and duration data from level_hardness.json."""
    hardness_path = os.path.join(base_dir, 'level_data', 'level_hardness.json')
    if os.path.exists(hardness_path):
        with open(hardness_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {}

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

def get_edge_column_hidden_info(hidden_coords, grid_width, grid_height):
    """Check if edge columns are mostly hidden."""
    if not hidden_coords:
        return {'leftHidden': False, 'rightHidden': False, 'leftCol': 0, 'rightCol': grid_width - 1}
    
    # Count hidden cells in leftmost and rightmost columns
    left_col_hidden = sum(1 for h in hidden_coords if h['x'] == 0)
    right_col_hidden = sum(1 for h in hidden_coords if h['x'] == grid_width - 1)
    
    # If more than 50% of cells in a column are hidden, consider it mostly hidden
    threshold = grid_height * 0.5
    left_mostly_hidden = left_col_hidden >= threshold
    right_mostly_hidden = right_col_hidden >= threshold
    
    # Determine inner boundary columns
    left_inner_col = 1 if left_mostly_hidden else 0
    right_inner_col = grid_width - 2 if right_mostly_hidden else grid_width - 1
    
    return {
        'leftHidden': left_mostly_hidden,
        'rightHidden': right_mostly_hidden,
        'leftCol': left_inner_col,
        'rightCol': right_inner_col
    }


def get_fully_hidden_top_rows(hidden_coords, grid_width, grid_height):
    """
    Check if top row(s) are fully hidden and should be removed.
    Returns number of rows to remove from top.
    
    In Unity coords: y=grid_height-1 is the top row (row 0 in game coords).
    """
    if not hidden_coords:
        return 0
    
    rows_to_remove = 0
    for check_y in range(grid_height - 1, -1, -1):  # Start from top (y=grid_h-1)
        # Count hidden cells in this row
        row_hidden = sum(1 for h in hidden_coords if h['y'] == check_y)
        
        if row_hidden == grid_width:
            # Entire row is hidden
            rows_to_remove += 1
        else:
            # Found a row that's not fully hidden, stop
            break
    
    return rows_to_remove

def get_door_edge(world_x, world_y, grid_width, grid_height, edge_info=None):
    """Determine which edge a door is on."""
    side_threshold = max(3.5, grid_width + 0.5)
    
    # If edge columns are mostly hidden, lower the threshold
    # Use grid_width - 1.1 to catch doors at x = grid_width - 1
    if edge_info and (edge_info['leftHidden'] or edge_info['rightHidden']):
        side_threshold = grid_width - 1.1
    
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
    
    # Load hardness data
    hardness_data = load_hardness_data(base_dir)
    
    guids = guids_data['level_guids']
    guid_to_level = {level['guid']: level for level in levels_data}
    
    # Convert levels
    game_levels = []
    for i in range(27):
        level = guid_to_level.get(guids[i])
        if not level:
            continue
        
        grid_w = level['gridSize']['x']
        grid_h_original = level['gridSize']['y']
        hidden_coords_original = level.get('hiddenCoords', [])
        
        # Check for fully hidden top rows that should be removed
        top_rows_to_remove = get_fully_hidden_top_rows(hidden_coords_original, grid_w, grid_h_original)
        
        # Adjust grid height and filter hidden coords
        grid_h = grid_h_original - top_rows_to_remove
        
        # Filter out hidden coords from removed rows and adjust remaining
        # Unity y=grid_h_original-1 is top row (removed), so filter those out
        hidden_coords = []
        for h in hidden_coords_original:
            if h['y'] < grid_h_original - top_rows_to_remove:
                hidden_coords.append(h)
        
        if top_rows_to_remove > 0:
            print(f"    Level {i+1} ({level['name']}): Removing {top_rows_to_remove} fully hidden top row(s), grid {grid_w}x{grid_h_original} -> {grid_w}x{grid_h}")
        
        # Convert blocks - зберігаємо ЦЕНТР блоку (як у візуалізаторі)
        # IMPORTANT: Use original grid_h for world_to_grid conversion, then adjust row
        has_hidden_cells = len(hidden_coords) > 0
        blocks = []
        for b in level['gameBlocks']:
            center_row, center_col = world_to_grid(b['position']['x'], b['position']['y'], grid_w, grid_h_original)
            rot_z = round(b.get('rotation', {}).get('z', 0) / 90) % 4
            world_y = b['position']['y']
            
            # Для L блоків (groupType=3) з rotZ=1 на високих гридах,
            # коли row_calc закінчується на .5, використовуємо floor замість round
            if b['blockGroupType'] == 3 and rot_z == 1 and grid_h_original >= 12:
                offset_y = (grid_h_original - 1) / 2
                row_calc = -world_y / 2.0 + offset_y
                if row_calc % 1 == 0.5:
                    center_row = int(row_calc)  # floor
            
            # Прапорець для спеціальної обробки ShortL rotZ=2 в hidden levels
            # Застосовується тільки якщо worldY < -2 (далеко від центру)
            needs_row_offset = False
            if b['blockGroupType'] == 5 and rot_z == 2:  # ShortL rotZ=2
                if has_hidden_cells and world_y < -2:
                    needs_row_offset = True
            
            # Adjust row for removed top rows
            adjusted_row = center_row - top_rows_to_remove
            
            blocks.append({
                'blockType': b['blockType'],
                'blockGroupType': b['blockGroupType'],
                'gridRow': adjusted_row,
                'gridCol': center_col,
                'rotationZ': rot_z,
                'needsRowOffset': needs_row_offset
            })
        
        # Get edge column hidden info for this level (using adjusted values)
        edge_info = get_edge_column_hidden_info(hidden_coords, grid_w, grid_h)
        
        # Convert doors
        # IMPORTANT: Use original grid_h for world_to_grid conversion
        doors = []
        for d in level['doors']:
            edge = get_door_edge(d['position']['x'], d['position']['y'], grid_w, grid_h_original, edge_info)
            row, col = world_to_grid(d['position']['x'], d['position']['y'], grid_w, grid_h_original)
            parts = d['doorPartCount']
            
            # Adjust position for doors
            # Use original grid_h for world coordinate calculations
            if edge in ['left', 'right']:
                col = 0 if edge == 'left' else grid_w - 1
                offset_y = (grid_h_original - 1) / 2
                if abs(d['position']['y']) < 0.5:
                    row = (grid_h_original - parts) // 2
                else:
                    row_center = js_round(-d['position']['y'] / 2.0 + offset_y)
                    # Поріг залежить від offset_y - двері нижче центру позиціонуються інакше
                    if d['position']['y'] < -offset_y:
                        row = row_center - (parts - 1) // 2
                    else:
                        row = row_center - parts // 2
                row = max(0, min(row, grid_h_original - parts))
                
                # Use inner boundary if edge columns are mostly hidden
                if edge == 'left' and edge_info['leftHidden']:
                    col = edge_info['leftCol']
                elif edge == 'right' and edge_info['rightHidden']:
                    col = edge_info['rightCol']
            else:
                # Для top/bottom дверей: row - це положення на межі (зовнішнє)
                # Use original grid_h, adjustment will be applied later
                row = -1 if edge == 'top' else grid_h_original
                if abs(d['position']['x']) < 0.5:
                    col = (grid_w - parts) // 2
                else:
                    offset_x = (grid_w - 1) / 2
                    col_center = js_round(d['position']['x'] / 2.0 + offset_x)
                    col = col_center - parts // 2
                col = max(0, min(col, grid_w - parts))
            
            # Adjust row for removed top rows
            adjusted_row = int(row) - top_rows_to_remove
            
            doors.append({
                'blockType': d['blockType'],
                'partCount': parts,
                'edge': edge,
                'startRow': adjusted_row,
                'startCol': int(col)
            })
        
        # Convert hidden coords (using filtered list without removed top rows)
        hidden = []
        for h in hidden_coords:
            # Convert Unity y to game row (y=0 is bottom in Unity, row=0 is top in game)
            # With adjusted grid_h, the formula stays the same
            hidden.append({
                'row': grid_h - 1 - h['y'],
                'col': h['x']
            })
        
        # Get hardness and duration for this level
        level_guid = guids[i]
        hardness_info = hardness_data.get(level_guid, {})
        duration = hardness_info.get('duration', 120)  # Default 2 minutes
        hardness = hardness_info.get('hardness', 0)  # 0=Normal, 1=Hard, 2=VeryHard
        
        game_levels.append({
            'id': i + 1,
            'name': level['name'],
            'gridWidth': grid_w,
            'gridHeight': grid_h,
            'blocks': blocks,
            'doors': doors,
            'hiddenCells': hidden,
            'duration': duration,
            'hardness': hardness
        })
    
    # Save - go up 2 levels from ColorBlockJam_Analysis to project root
    project_root = os.path.dirname(os.path.dirname(base_dir))
    output_dir = os.path.join(project_root, 'assets', 'levels')
    os.makedirs(output_dir, exist_ok=True)
    
    output_path = os.path.join(output_dir, 'levels_27.json')
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump({'levels': game_levels}, f, indent=2, ensure_ascii=False)
    
    print(f'Exported {len(game_levels)} levels to {output_path}')
    hardness_names = {0: 'Normal', 1: 'Hard', 2: 'VeryHard'}
    for lvl in game_levels:
        h_name = hardness_names.get(lvl['hardness'], 'Normal')
        h_marker = '[H]' if lvl['hardness'] == 1 else '[VH]' if lvl['hardness'] == 2 else '   '
        print(f"  {h_marker} Level {lvl['id']:2d}: {lvl['name'][:20]:20s} ({lvl['gridWidth']}x{lvl['gridHeight']}, {len(lvl['blocks'])} blocks, {lvl['duration']:3d}s {h_name})")

if __name__ == '__main__':
    main()

