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
        grid_h = level['gridSize']['y']
        
        # Use original grid height for world->grid conversion, then apply row offset
        original_grid_h = level.get('originalGridHeight', grid_h)
        removed_top_rows = level.get('removedTopRows', 0)
        
        # Convert blocks - зберігаємо ЦЕНТР блоку (як у візуалізаторі)
        has_hidden_cells = len(level.get('hiddenCoords', [])) > 0
        blocks = []
        for b in level['gameBlocks']:
            # Use original grid height for world->grid conversion
            center_row, center_col = world_to_grid(b['position']['x'], b['position']['y'], grid_w, original_grid_h)
            rot_z = round(b.get('rotation', {}).get('z', 0) / 90) % 4
            world_y = b['position']['y']
            
            # Для L блоків (groupType=3) з rotZ=1 на високих гридах,
            # коли row_calc закінчується на .5, використовуємо floor замість round
            if b['blockGroupType'] == 3 and rot_z == 1 and original_grid_h >= 12:
                offset_y = (original_grid_h - 1) / 2
                row_calc = -world_y / 2.0 + offset_y
                if row_calc % 1 == 0.5:
                    center_row = int(row_calc)  # floor
            
            # Apply row offset for removed top rows
            center_row -= removed_top_rows
            
            # Прапорець для спеціальної обробки ShortL rotZ=2 в hidden levels
            # Застосовується тільки якщо worldY < -2 (далеко від центру)
            needs_row_offset = False
            if b['blockGroupType'] == 5 and rot_z == 2:  # ShortL rotZ=2
                if has_hidden_cells and world_y < -2:
                    needs_row_offset = True
            
            blocks.append({
                'blockType': b['blockType'],
                'blockGroupType': b['blockGroupType'],
                'gridRow': center_row,
                'gridCol': center_col,
                'rotationZ': rot_z,
                'needsRowOffset': needs_row_offset,
                'moveDirection': b.get('moveDirection', 2),  # 0=HORIZ, 1=VERT, 2=BOTH
                'innerBlockType': b.get('innerBlockType', -1)  # -1 = no inner layer
            })
        
        # Get edge column hidden info for this level (use original grid height for calculation)
        edge_info = get_edge_column_hidden_info(level.get('hiddenCoords', []), grid_w, original_grid_h)
        
        # Convert doors
        doors = []
        for d in level['doors']:
            world_x = d['position']['x']
            world_y = d['position']['y']
            
            # Filter out doors that are too far from the grid bounds
            # Normal side doors should be at approximately grid_w for right, -grid_w for left
            # With some tolerance (1.5 units)
            max_side_x = grid_w + 1.5
            if abs(world_x) > max_side_x:
                # Door is too far from the grid - skip it
                continue
            
            edge = get_door_edge(world_x, world_y, grid_w, original_grid_h, edge_info)
            row, col = world_to_grid(world_x, world_y, grid_w, original_grid_h)
            parts = d['doorPartCount']
            
            # Adjust position for doors
            if edge in ['left', 'right']:
                col = 0 if edge == 'left' else grid_w - 1
                offset_y = (original_grid_h - 1) / 2
                if abs(world_y) < 0.5:
                    row = (original_grid_h - parts) // 2
                else:
                    row_center = js_round(-world_y / 2.0 + offset_y)
                    # Поріг залежить від offset_y - двері нижче центру позиціонуються інакше
                    if world_y < -offset_y:
                        row = row_center - (parts - 1) // 2
                    else:
                        row = row_center - parts // 2
                row = max(0, min(row, original_grid_h - parts))
                
                # Apply row offset for removed top rows
                row -= removed_top_rows
                row = max(0, min(row, grid_h - parts))
                
                # Use inner boundary if edge columns are mostly hidden
                if edge == 'left' and edge_info['leftHidden']:
                    col = edge_info['leftCol']
                elif edge == 'right' and edge_info['rightHidden']:
                    col = edge_info['rightCol']
            else:
                # Для top/bottom дверей: row - це положення на межі (зовнішнє)
                row = -1 if edge == 'top' else grid_h
                if abs(world_x) < 0.5:
                    col = (grid_w - parts) // 2
                else:
                    offset_x = (grid_w - 1) / 2
                    col_center = js_round(world_x / 2.0 + offset_x)
                    col = col_center - parts // 2
                col = max(0, min(col, grid_w - parts))
            
            doors.append({
                'blockType': d['blockType'],
                'partCount': parts,
                'edge': edge,
                'startRow': int(row),
                'startCol': int(col)
            })
        
        # Convert hidden coords (use current grid_h since hiddenCoords already filtered)
        hidden = []
        for h in level.get('hiddenCoords', []):
            hidden.append({
                'row': grid_h - 1 - h['y'],  # grid_h is already adjusted
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

