#!/usr/bin/env python3
"""Check Level 33 yellow blocks for moveDirection."""

import UnityPy
import struct

def read_int32(data: bytes, offset: int) -> int:
    if offset + 4 > len(data):
        return 0
    return struct.unpack_from('<i', data, offset)[0]

def read_float(data: bytes, offset: int) -> float:
    if offset + 4 > len(data):
        return 0.0
    return struct.unpack_from('<f', data, offset)[0]

COLORS = {
    0: "blue", 1: "dark_blue", 2: "green", 3: "pink", 4: "purple",
    5: "yellow", 6: "dark_green", 7: "orange", 8: "RED", 9: "cyan"
}

def main():
    assets_path = r"D:\Work\Playcus\Flutter\color_block_jam\res\ColorBlockJam_Analysis\xapk_extracted\game_apk\assets\bin\Data\_combined_sharedassets2.assets"
    
    env = UnityPy.load(assets_path)
    
    for obj in env.objects:
        if obj.type.name == "MonoBehaviour":
            data = obj.get_raw_data()
            
            name_len = read_int32(data, 0x1C)
            if name_len <= 0 or name_len > 100:
                continue
            name = data[0x20:0x20+name_len].decode('utf-8', errors='replace')
            
            if name != "Level 33":
                continue
            
            print(f"Found {name}, size={len(data)} bytes")
            
            # Find all yellow blocks (blockType=5)
            print("\n=== Yellow blocks (blockType=5) ===")
            BLOCK_SIZE = 156
            
            for offset in range(0x200, len(data) - BLOCK_SIZE, 4):
                px = read_float(data, offset)
                py = read_float(data, offset + 4)
                
                if abs(px) > 15 or abs(py) > 15:
                    continue
                
                gt = read_int32(data, offset + 24)
                bt = read_int32(data, offset + 28)
                
                if bt != 5:  # Only yellow
                    continue
                
                if gt < 0 or gt > 11:
                    continue
                
                rz = read_float(data, offset + 20)
                off32 = read_int32(data, offset + 32)
                off40 = read_int32(data, offset + 40)
                
                print(f"  pos=({px:.1f}, {py:.1f}), gt={gt}, rot={rz:.0f}, off32={off32}, off40={off40}")

if __name__ == "__main__":
    main()


