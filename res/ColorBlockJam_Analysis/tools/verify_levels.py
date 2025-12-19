#!/usr/bin/env python3
"""
Verifies that parser changes don't break verified levels.
Compares current parsed output with reference snapshot.
"""

import json
import os
import sys

VERIFIED_LEVELS = 27  # Levels 1-27 are verified

def load_reference():
    """Load reference snapshot of verified levels."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    base_dir = os.path.dirname(script_dir)
    ref_path = os.path.join(base_dir, 'level_data/verified_levels_snapshot.json')
    
    if not os.path.exists(ref_path):
        return None
    
    with open(ref_path, 'r', encoding='utf-8') as f:
        return json.load(f)

def save_reference(levels):
    """Save current state as reference snapshot."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    base_dir = os.path.dirname(script_dir)
    ref_path = os.path.join(base_dir, 'level_data/verified_levels_snapshot.json')
    
    with open(ref_path, 'w', encoding='utf-8') as f:
        json.dump(levels, f, indent=2)
    print(f"Saved reference snapshot: {len(levels)} levels")

def load_current():
    """Load current game levels."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(os.path.dirname(os.path.dirname(script_dir)))
    levels_path = os.path.join(project_root, 'assets/levels/levels_27.json')
    
    with open(levels_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    return {lvl['id']: lvl for lvl in data['levels'] if lvl['id'] <= VERIFIED_LEVELS}

def compare_levels(ref, current):
    """Compare reference and current levels, return differences."""
    differences = []
    
    for level_id in range(1, VERIFIED_LEVELS + 1):
        ref_level = ref.get(str(level_id)) or ref.get(level_id)
        cur_level = current.get(level_id)
        
        if not ref_level or not cur_level:
            differences.append(f"Level {level_id}: missing in {'reference' if not ref_level else 'current'}")
            continue
        
        # Compare key fields
        fields_to_check = ['gridWidth', 'gridHeight', 'name']
        for field in fields_to_check:
            if ref_level.get(field) != cur_level.get(field):
                differences.append(f"Level {level_id}: {field} changed: {ref_level.get(field)} -> {cur_level.get(field)}")
        
        # Compare blocks count
        ref_blocks = len(ref_level.get('blocks', []))
        cur_blocks = len(cur_level.get('blocks', []))
        if ref_blocks != cur_blocks:
            differences.append(f"Level {level_id}: blocks count changed: {ref_blocks} -> {cur_blocks}")
        
        # Compare doors count
        ref_doors = len(ref_level.get('doors', []))
        cur_doors = len(cur_level.get('doors', []))
        if ref_doors != cur_doors:
            differences.append(f"Level {level_id}: doors count changed: {ref_doors} -> {cur_doors}")
        
        # Compare each door
        if ref_doors == cur_doors:
            for idx, (ref_door, cur_door) in enumerate(zip(ref_level.get('doors', []), cur_level.get('doors', []))):
                door_diffs = []
                for key in ['blockType', 'partCount', 'edge', 'startRow', 'startCol']:
                    if ref_door.get(key) != cur_door.get(key):
                        door_diffs.append(f"{key}: {ref_door.get(key)} -> {cur_door.get(key)}")
                if door_diffs:
                    differences.append(f"Level {level_id}, Door {idx+1}: {', '.join(door_diffs)}")
        
        # Compare each block position
        if ref_blocks == cur_blocks:
            for idx, (ref_block, cur_block) in enumerate(zip(ref_level.get('blocks', []), cur_level.get('blocks', []))):
                block_diffs = []
                for key in ['blockType', 'gridRow', 'gridCol', 'rotationZ']:
                    if ref_block.get(key) != cur_block.get(key):
                        block_diffs.append(f"{key}: {ref_block.get(key)} -> {cur_block.get(key)}")
                if block_diffs:
                    differences.append(f"Level {level_id}, Block {idx+1}: {', '.join(block_diffs)}")
    
    return differences

def main():
    if len(sys.argv) > 1 and sys.argv[1] == '--save':
        # Save current state as reference
        current = load_current()
        save_reference({str(k): v for k, v in current.items()})
        return 0
    
    # Compare with reference
    ref = load_reference()
    if not ref:
        print("No reference snapshot found. Run with --save to create one.")
        return 1
    
    current = load_current()
    differences = compare_levels(ref, current)
    
    if differences:
        print(f"[FAIL] VERIFICATION FAILED! {len(differences)} differences found:")
        for diff in differences[:20]:  # Show first 20
            print(f"  - {diff}")
        if len(differences) > 20:
            print(f"  ... and {len(differences) - 20} more")
        print("\n[!] Parser changes broke verified levels! Please revert.")
        return 1
    else:
        print(f"[OK] All {VERIFIED_LEVELS} verified levels unchanged.")
        return 0

if __name__ == '__main__':
    sys.exit(main())

