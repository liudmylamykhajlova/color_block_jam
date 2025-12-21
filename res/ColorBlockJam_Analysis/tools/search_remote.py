import os

# Search for remote level patterns in binary files
search_terms = [b'firebasestorage', b'RemoteLevel', b'DownloadLevel', b'LevelData', b'AllLevels', b'http', b'level_']
base_path = r'res\ColorBlockJam_Analysis\xapk_extracted\game_apk\assets\bin\Data'

print("Searching for remote level patterns...")

for root, dirs, files in os.walk(base_path):
    for fname in files:
        if fname.endswith('.assets'):
            fpath = os.path.join(root, fname)
            try:
                with open(fpath, 'rb') as f:
                    data = f.read()
                    for term in search_terms:
                        if term in data:
                            idx = data.find(term)
                            # Get context around the match
                            start = max(0, idx - 30)
                            end = min(len(data), idx + len(term) + 100)
                            context = data[start:end]
                            # Try to decode as text
                            try:
                                context_str = context.decode('utf-8', errors='replace')
                            except:
                                context_str = str(context)
                            print(f"\n{fname}: Found '{term.decode('utf-8', errors='ignore')}' at offset {idx}")
                            print(f"  Context: ...{context_str}...")
            except Exception as e:
                print(f"Error reading {fname}: {e}")


