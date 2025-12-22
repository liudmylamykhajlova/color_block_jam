import zlib
import os
import tarfile
import io

backup_path = 'res/ColorBlockJam_Analysis/phone_cache/game_backup.ab'
output_dir = 'res/ColorBlockJam_Analysis/phone_cache/backup_extracted'

# Read the backup file
with open(backup_path, 'rb') as f:
    data = f.read()

print(f"Backup file size: {len(data)} bytes")
print(f"First 100 bytes: {data[:100]}")

# ADB backup format:
# Line 1: "ANDROID BACKUP"
# Line 2: version (1, 2, 3, 4, or 5)
# Line 3: compression flag (0 or 1)
# Line 4: encryption algorithm (none or AES-256)
# Then compressed tar data

# Find the header end
header_end = data.find(b'\n', data.find(b'\n', data.find(b'\n', data.find(b'\n') + 1) + 1) + 1) + 1
header = data[:header_end].decode('utf-8', errors='ignore')
print(f"\nHeader:\n{header}")

# Get the compressed data
compressed_data = data[header_end:]
print(f"\nCompressed data size: {len(compressed_data)} bytes")

# Try to decompress
try:
    # Try zlib decompression
    decompressed = zlib.decompress(compressed_data)
    print(f"Decompressed size: {len(decompressed)} bytes")
    
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    
    # Save decompressed tar
    tar_path = os.path.join(output_dir, 'backup.tar')
    with open(tar_path, 'wb') as f:
        f.write(decompressed)
    print(f"Saved decompressed tar to: {tar_path}")
    
    # Extract tar
    with tarfile.open(tar_path, 'r') as tar:
        tar.extractall(output_dir)
        print(f"Extracted to: {output_dir}")
        
    # List extracted files
    print("\nExtracted files:")
    for root, dirs, files in os.walk(output_dir):
        level = root.replace(output_dir, '').count(os.sep)
        indent = ' ' * 2 * level
        print(f'{indent}{os.path.basename(root)}/')
        subindent = ' ' * 2 * (level + 1)
        for file in files[:20]:  # Limit to first 20 files per directory
            filepath = os.path.join(root, file)
            size = os.path.getsize(filepath)
            print(f'{subindent}{file} ({size} bytes)')
        if len(files) > 20:
            print(f'{subindent}... and {len(files) - 20} more files')
            
except Exception as e:
    print(f"Error: {e}")
    
    # Try without header (raw zlib)
    try:
        decompressed = zlib.decompress(data)
        print(f"Raw decompression worked: {len(decompressed)} bytes")
    except:
        print("Raw decompression also failed")



