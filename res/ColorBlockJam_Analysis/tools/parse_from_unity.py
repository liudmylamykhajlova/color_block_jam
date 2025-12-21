#!/usr/bin/env python3
"""
Parse all levels from Unity assets and save to JSON.
Uses improved door parsing logic.
"""

import UnityPy
import struct
import json
import os
import re
from typing import Dict, List, Any

# Block group type enum
BLOCK_GROUP_TYPES = {
    0: 'One', 1: 'Two', 2: 'Three', 3: 'L', 4: 'ReverseL',
    5: 'ShortL', 6: 'Plus', 7: 'TwoSquare', 8: 'ShortT',
    9: 'Z', 10: 'ReverseZ', 11: 'U'
}

BLOCK_SIZE = 44


def read_int32(data: bytes, offset: int) -> int:
    if offset + 4 > len(data):
        return 0
    return struct.unpack_from('<i', data, offset)[0]


def read_float(data: bytes, offset: int) -> float:
    if offset + 4 > len(data):
        return 0.0
    return struct.unpack_from('<f', data, offset)[0]


def read_vector3(data: bytes, offset: int) -> Dict[str, float]:
    return {
        'x': round(read_float(data, offset), 4),
        'y': round(read_float(data, offset + 4), 4),
        'z': round(read_float(data, offset + 8), 4)
    }


def read_string(data: bytes, offset: int):
    """Read Unity string, return (string, end_offset)"""
    length = read_int32(data, offset)
    if length <= 0 or length > 500:
        return ("", offset + 4)
    s = data[offset+4:offset+4+length].decode('utf-8', errors='replace')
    end = offset + 4 + length
    if end % 4 != 0:
        end = ((end // 4) + 1) * 4
    return (s, end)


def is_valid_door(pos_x: float, pos_y: float, parts: int, btype: int) -> bool:
    """Check if door data looks valid."""
    if abs(pos_x) < 0.1 and abs(pos_y) < 0.1:
        return False
    if abs(pos_x) > 30 or abs(pos_y) > 30:
        return False
    if parts < 1 or parts > 4:  # Real doors have 1-4 parts max (5+ is false positive)
        return False
    if btype < 0 or btype > 15:
        return False
    return True


def find_doors_in_region(data: bytes, start: int, end: int, expected_count: int = 0, grid_x: int = 5, grid_y: int = 6, hidden_coords: List[Dict] = None) -> List[Dict]:
    """Scan for valid door entries in a memory region."""
    doors = []
    
    # Check if edge columns are mostly hidden
    hidden_coords = hidden_coords or []
    left_col_hidden = sum(1 for h in hidden_coords if h['x'] == 0)
    right_col_hidden = sum(1 for h in hidden_coords if h['x'] == grid_x - 1)
    threshold = grid_y * 0.5
    edges_mostly_hidden = left_col_hidden >= threshold or right_col_hidden >= threshold
    
    # Calculate dynamic edge thresholds based on grid size
    side_edge_threshold = max(3.5, grid_x + 0.5)
    # If edge columns are mostly hidden, lower the threshold to catch doors at inner positions
    # Use grid_x - 1.1 to catch doors at x = grid_x - 1 (e.g., x=5 for grid_x=6)
    if edges_mostly_hidden:
        side_edge_threshold = grid_x - 1.1
    side_edge_max = grid_x + 2
    # For grids >= 9, use lower threshold to catch doors at y = grid_y - 1
    # (e.g., Level 28 has doors at y=8.999994 with grid_y=10)
    top_bottom_edge_threshold = max(5.5, grid_y - 1.1) if grid_y >= 9 else max(5.5, grid_y - 0.5)
    
    # Expand search range to find all doors (some levels have doors up to 0x870+)
    search_end = min(len(data) - 32, max(end, 0x900))
    
    # Scan through the region looking for valid door patterns
    offset = start
    while offset + 32 <= search_end:
        pos_x = read_float(data, offset)
        pos_y = read_float(data, offset + 4)
        pos_z = read_float(data, offset + 8)
        
        # Check if this could be a door position (on grid edge)
        is_side_edge = side_edge_threshold <= abs(pos_x) <= side_edge_max
        is_top_bottom_edge = abs(pos_y) >= top_bottom_edge_threshold and abs(pos_x) < side_edge_threshold
        
        # Filter out false positive: first door entry (offset 0x84) that is side edge with high Y
        # This pattern appears in some levels where binary data is misinterpreted
        is_first_entry_false_positive = (offset == start and is_side_edge and 
                                          abs(pos_y) >= top_bottom_edge_threshold and
                                          abs(pos_y) < grid_y + 0.5)  # Not at exact edge
        
        if (is_side_edge or is_top_bottom_edge) and not is_first_entry_false_positive and abs(pos_x) < 20 and abs(pos_y) < 20 and abs(pos_z) < 5:
            # Look for parts and type at expected offsets
            parts = read_int32(data, offset + 24)
            btype = read_int32(data, offset + 28)
            
            if is_valid_door(pos_x, pos_y, parts, btype):
                pos = read_vector3(data, offset)
                rot = read_vector3(data, offset + 12)
                
                # Avoid duplicates (same position)
                is_duplicate = False
                for existing in doors:
                    if abs(existing['position']['x'] - pos['x']) < 0.5 and abs(existing['position']['y'] - pos['y']) < 0.5:
                        is_duplicate = True
                        break
                
                if not is_duplicate:
                    doors.append({
                        'position': pos,
                        'rotation': rot,
                        'doorPartCount': parts,
                        'blockType': btype
                    })
                
                offset += 32  # Move past this door
                continue
        
        offset += 4  # Try next alignment
    
    return doors


GAME_BLOCK_SIZE = 0x9C  # 156 bytes per game block


def get_fully_hidden_top_rows(hidden_coords, grid_width, grid_height):
    """
    Check if top row(s) are fully hidden and should be removed.
    Returns number of rows to remove from top.
    
    In Unity coords: y=grid_height-1 is the top row.
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


def find_frame_data(data: bytes, search_start: int = 0x150) -> tuple:
    """Find frame element count and offset (decorative blocks)."""
    for offset in range(search_start, min(len(data) - 100, 0x800), 4):
        count = read_int32(data, offset)
        if 1 <= count <= 100:
            test_off = offset + 4
            if test_off + 12 > len(data):
                continue
            px = read_float(data, test_off)
            py = read_float(data, test_off + 4)
            pz = read_float(data, test_off + 8)

            if -15 < px < 15 and -15 < py < 15 and -5 < pz < 10:
                rx = read_float(data, test_off + 12)
                if abs(rx) < 0.5 or 89 < abs(rx) < 271 or abs(rx - 345) < 1:
                    if count >= 2 and test_off + BLOCK_SIZE + 12 <= len(data):
                        px2 = read_float(data, test_off + BLOCK_SIZE)
                        py2 = read_float(data, test_off + BLOCK_SIZE + 4)
                        if -15 < px2 < 15 and -15 < py2 < 15:
                            return count, offset + 4
                    elif count == 1:
                        return count, offset + 4
    return 0, 0


def find_game_blocks(data: bytes, grid_x: int, grid_y: int) -> List[Dict]:
    """Find actual game blocks by locating the block array count marker."""
    blocks = []
    
    # Game blocks are stored as: count (4 bytes) + N * 156 bytes of block data
    # The count is typically 1-20, followed immediately by position data
    
    # Search for the block array count marker
    block_array_offset = -1
    block_count = 0
    
    # Expanded search range to cover all levels (small levels have blocks earlier)
    for offset in range(0x150, min(len(data) - 200, 0x1000), 4):
        count = read_int32(data, offset)
        
        # Valid block count: 1-30 (some levels have many blocks)
        if 1 <= count <= 30:
            # Check if followed by valid position
            px = read_float(data, offset + 4)
            py = read_float(data, offset + 8)
            pz = read_float(data, offset + 12)
            
            # Position should be inside field (allow larger values for tall grids)
            if abs(px) <= 12 and abs(py) <= 12 and abs(pz) <= 3:
                # Check for valid groupType at +28 (offset + 4 + 24)
                group_type = read_int32(data, offset + 4 + 24)
                block_type = read_int32(data, offset + 4 + 28)
                
                if 0 <= group_type <= 11 and 0 <= block_type <= 10:
                    # At least one of: non-origin position OR non-zero types
                    # This filters out padding arrays where everything is 0
                    is_valid = (abs(px) > 0.5 or abs(py) > 0.5 or 
                               group_type > 0 or block_type > 0)
                    
                    if is_valid:
                        block_array_offset = offset + 4  # Skip the count
                        block_count = count
                        break
    
    if block_array_offset < 0:
        return blocks
    
    # Parse each block (156 bytes each)
    BLOCK_STRUCT_SIZE = 156  # 0x9C bytes per block
    
    for i in range(block_count):
        offset = block_array_offset + i * BLOCK_STRUCT_SIZE
        
        if offset + 32 > len(data):
            break
        
        px = read_float(data, offset)
        py = read_float(data, offset + 4)
        pz = read_float(data, offset + 8)
        
        # Skip invalid positions (allow larger values for tall grids like 8x12)
        if abs(px) > 15 or abs(py) > 15:
            continue
            
        # Read rotation
        rx = read_float(data, offset + 12)
        ry = read_float(data, offset + 16)
        rz = read_float(data, offset + 20)
        
        # Read block types (at offset +24 and +28)
        group_type = read_int32(data, offset + 24)
        block_type = read_int32(data, offset + 28)
        
        # Validate types
        if group_type < 0 or group_type > 15:
            continue
        if block_type < 0 or block_type > 15:
            continue
        
        # Read movement restriction flags (offset +32 and +40)
        off32 = read_int32(data, offset + 32)
        off40 = read_int32(data, offset + 40)
        
        # Determine moveDirection:
        # 0 = HORIZ only, 1 = VERT only, 2 = BOTH
        # Logic:
        # (1, 1) → direction SAME as block orientation (based on rotation)
        # (1, 0) → direction PERPENDICULAR to block orientation
        # (0, 0) or (0, 1) → BOTH
        rz_normalized = round(rz) % 360
        
        if off32 == 1 and off40 == 1:
            # Direction same as block orientation
            # rotation 0 or 180 = vertical block = moves vertically
            # rotation 90 or 270 = horizontal block = moves horizontally
            if rz_normalized in [0, 180]:
                move_direction = 1  # VERT
            else:
                move_direction = 0  # HORIZ
        elif off32 == 1 and off40 == 0:
            # Direction perpendicular to block orientation
            # rotation 0 or 180 = vertical block = moves horizontally
            # rotation 90 or 270 = horizontal block = moves vertically
            if rz_normalized in [0, 180]:
                move_direction = 0  # HORIZ
            else:
                move_direction = 1  # VERT
        else:
            move_direction = 2  # BOTH
        
        # Read inner layer flag (offset +96) and color (offset +100)
        # off96 = 1 means inner layer exists, 0 = no inner layer
        has_inner_flag = read_int32(data, offset + 96)
        inner_block_type = read_int32(data, offset + 100)
        
        if has_inner_flag != 1:
            inner_block_type = -1  # No inner layer
        elif inner_block_type < 0 or inner_block_type > 11:
            inner_block_type = -1  # Invalid color
        elif inner_block_type == block_type:
            inner_block_type = -1  # Same as outer, no visible inner layer
        
        block_data = {
            'position': {'x': round(px, 4), 'y': round(py, 4), 'z': round(pz, 4)},
            'rotation': {'x': round(rx, 4), 'y': round(ry, 4), 'z': round(rz, 4)},
            'blockGroupType': group_type,
            'blockType': block_type,
            'blockGroupTypeName': BLOCK_GROUP_TYPES.get(group_type, f"Unknown({group_type})"),
            'moveDirection': move_direction  # 0=HORIZ, 1=VERT, 2=BOTH
        }
        
        # Add inner layer only if present
        if inner_block_type >= 0:
            block_data['innerBlockType'] = inner_block_type
        
        blocks.append(block_data)
    
    return blocks


def find_block_data(data: bytes, search_start: int = 0x150) -> tuple:
    """Find block count and offset (kept for backwards compatibility)."""
    return find_frame_data(data, search_start)


def parse_level_data(data: bytes, name_hint: str = "") -> Dict[str, Any]:
    """Parse level binary data from MonoBehaviour."""
    result = {
        'name': '',
        'guid': '',
        'gridSize': {'x': 0, 'y': 0},
        'camera': {
            'position': {'x': 0, 'y': 0, 'z': 0},
            'rotation': {'x': 0, 'y': 0, 'z': 0},
            'fov': 60.0
        },
        'hiddenCoords': [],
        'doors': [],
        'gameBlocks': [],  # Actual game blocks inside field
        'frameElements': []  # Decorative frame elements (renamed from 'blocks')
    }

    try:
        # Read name
        offset = 0x1C
        name, offset = read_string(data, offset)
        result['name'] = name

        # Read GUID
        guid, offset = read_string(data, offset)
        result['guid'] = guid

        # Grid size
        result['gridSize']['x'] = read_int32(data, offset)
        result['gridSize']['y'] = read_int32(data, offset + 4)
        offset += 8

        # Validate grid size
        if result['gridSize']['x'] <= 0 or result['gridSize']['x'] > 20:
            return None
        if result['gridSize']['y'] <= 0 or result['gridSize']['y'] > 20:
            return None

        # Hidden coords
        hidden_count = read_int32(data, offset)
        offset += 4
        if 0 <= hidden_count < 50:
            for i in range(hidden_count):
                hx = read_int32(data, offset + i * 8)
                hy = read_int32(data, offset + i * 8 + 4)
                result['hiddenCoords'].append({'x': hx, 'y': hy})
            offset += hidden_count * 8

        # Grid color count
        color_count = read_int32(data, offset)
        offset += 4
        if 0 <= color_count < 50:
            offset += color_count * 8

        # Camera data
        if offset + 28 <= len(data):
            result['camera']['position'] = read_vector3(data, offset)
            result['camera']['rotation'] = read_vector3(data, offset + 12)
            result['camera']['fov'] = round(read_float(data, offset + 24), 2)

        # Find frame elements (decorative)
        frame_count, frame_offset = find_frame_data(data)
        
        # Read expected door count
        door_count = read_int32(data, 0x80)
        if door_count < 0 or door_count > 20:
            door_count = 0
        
        # Door region: from 0x84, search wider range to find all doors
        door_region_start = 0x84
        door_region_end = min(len(data), 0x600)  # Search up to 0x600 for doors
        
        # Find all doors (pass grid size and hidden coords for dynamic edge detection)
        result['doors'] = find_doors_in_region(data, door_region_start, door_region_end, door_count, 
                                                result['gridSize']['x'], result['gridSize']['y'], result['hiddenCoords'])

        # Find actual game blocks (inside playing field)
        result['gameBlocks'] = find_game_blocks(data, result['gridSize']['x'], result['gridSize']['y'])

        # Parse frame elements (decorative blocks)
        if frame_count > 0:
            for b in range(frame_count):
                boff = frame_offset + b * BLOCK_SIZE
                if boff + 44 > len(data):
                    break
                block = {
                    'position': read_vector3(data, boff),
                    'rotation': read_vector3(data, boff + 12),
                    'scale': read_vector3(data, boff + 24),
                    'blockGroupType': read_int32(data, boff + 36),
                    'blockType': read_int32(data, boff + 40)
                }
                block['blockGroupTypeName'] = BLOCK_GROUP_TYPES.get(
                    block['blockGroupType'],
                    f"Unknown({block['blockGroupType']})"
                )
                result['frameElements'].append(block)

        # Check for fully hidden top rows
        # Store original grid height and number of removed rows for export script
        grid_w = result['gridSize']['x']
        grid_h = result['gridSize']['y']
        top_rows_to_remove = get_fully_hidden_top_rows(result['hiddenCoords'], grid_w, grid_h)
        
        # Store original grid height for world->grid conversion
        result['originalGridHeight'] = grid_h
        result['removedTopRows'] = top_rows_to_remove
        
        if top_rows_to_remove > 0:
            # Adjust grid height
            result['gridSize']['y'] = grid_h - top_rows_to_remove
            
            # Filter out hidden coords from removed rows (y >= grid_h - top_rows_to_remove)
            result['hiddenCoords'] = [
                h for h in result['hiddenCoords'] 
                if h['y'] < grid_h - top_rows_to_remove
            ]
            
            # DO NOT modify world coordinates of blocks/doors!
            # The export script will use originalGridHeight for conversion
            # and then apply row offset based on removedTopRows

    except Exception as e:
        result['error'] = str(e)
        return None

    return result


def main():
    data_path = r'D:\Work\Playcus\Flutter\color_block_jam\res\ColorBlockJam_Analysis\xapk_extracted\game_apk\assets\bin\Data'
    combined_path = os.path.join(data_path, '_combined_sharedassets2.assets')
    output_path = r'D:\Work\Playcus\Flutter\color_block_jam\res\ColorBlockJam_Analysis\level_data\parsed_levels_complete.json'
    
    print(f"Loading Unity assets from: {combined_path}")
    env = UnityPy.load(combined_path)
    
    levels = []
    # Match "Level X", "Level XX", "Level XXX" etc., or variants like "Derin Level X"
    level_pattern = re.compile(r'Level \d+$')
    
    print("Parsing levels...")
    for obj in env.objects:
        if obj.type.name == 'MonoBehaviour':
            raw = obj.get_raw_data()
            
            # Quick check for level name pattern
            try:
                name_len = struct.unpack('<i', raw[0x1c:0x20])[0]
                if 5 <= name_len <= 30:
                    name = raw[0x20:0x20+name_len].decode('utf-8', errors='ignore')
                    if level_pattern.search(name):  # Use search instead of match
                        level_data = parse_level_data(raw, name)
                        if level_data:
                            levels.append(level_data)
            except:
                pass
    
    # Sort by level number (extract number from name)
    def get_level_num(level):
        try:
            # Extract the last number from the name
            match = re.search(r'(\d+)$', level['name'])
            if match:
                return int(match.group(1))
            return 9999
        except:
            return 9999
    
    levels.sort(key=get_level_num)
    
    print(f"\nParsed {len(levels)} levels")
    
    # Statistics
    door_counts = {}
    for level in levels:
        dc = len(level.get('doors', []))
        door_counts[dc] = door_counts.get(dc, 0) + 1
    
    print("\nDoor count distribution:")
    for dc, count in sorted(door_counts.items()):
        print(f"  {dc} doors: {count} levels")
    
    # Sample check: Level 1 and Level 2 doors
    for level in levels[:5]:
        print(f"\n{level['name']}:")
        print(f"  Grid: {level['gridSize']['x']}x{level['gridSize']['y']}")
        print(f"  Doors ({len(level['doors'])}):")
        for door in level['doors']:
            pos = door['position']
            print(f"    pos=({pos['x']:.1f}, {pos['y']:.1f}), parts={door['doorPartCount']}, type={door['blockType']}")
    
    # Save to file
    print(f"\nSaving to {output_path}...")
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(levels, f, indent=2, ensure_ascii=False)
    
    print("Done!")


if __name__ == "__main__":
    main()

