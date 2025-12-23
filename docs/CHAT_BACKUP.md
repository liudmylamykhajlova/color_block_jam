# Color Block Jam - Chat Backup

> **Last Updated:** 2025-12-23  
> **Session:** Documentation & Analysis

---

## Project Status

### Implemented Features (Phase 1 - DONE)
- [x] Core gameplay (drag & drop blocks)
- [x] 27 levels from original game
- [x] 12 block shapes, 10 colors
- [x] Movement direction restrictions (horizontal/vertical/both)
- [x] Frozen blocks (iceCount mechanic)
- [x] Multi-layer blocks (outer/inner color)
- [x] Level visualizer (HTML)
- [x] All levels unlocked for testing

### Next Phase (Economy)
- [ ] Timer system
- [ ] Lives system (5 lives, 30min refill)
- [ ] Coins system
- [ ] Boosters (time, hammer)
- [ ] Fail/Win dialogs

---

## Documentation Status

| File | Version | Status |
|------|---------|--------|
| `GAME_DESIGN.md` | 2.1.0 | Updated from screenshots |
| `UI_UX_DESIGN.md` | 2.0.0 | Updated from screenshots |
| `GAME_ANALYSIS.md` | 1.0.0 | Merged (FULL + ORIGINAL) |
| `TECHNICAL_SPEC.md` | 2.0.0 | Merged (+ CORE_MECHANICS) |
| `ROADMAP.md` | 1.5.0 | Exists |

### Deleted/Merged Files
- `FULL_GAME_ANALYSIS.md` → merged into `GAME_ANALYSIS.md`
- `ORIGINAL_GAME_ANALYSIS.md` → merged into `GAME_ANALYSIS.md`
- `TECHNICAL_SPECIFICATION_CORE_MECHANICS.md` → merged into `TECHNICAL_SPEC.md`
- `chat_backup_level28_investigation.md` → merged into this file

---

## Key Technical Findings

### Binary Offsets (from XAPK)
| Property | Offset | Description |
|----------|--------|-------------|
| moveDirection flag 1 | +32 | Movement restriction |
| moveDirection flag 2 | +40 | Movement restriction |
| isFrozen | +44 | Freeze flag (0/1) |
| iceCount | +48 | Blocks to unfreeze |
| hasInnerLayer | +96 | Inner layer flag |
| innerBlockType | +100 | Inner color ID |

### Color Palette (Correct)
| ID | Color | HEX |
|----|-------|-----|
| 0 | Blue | #03a5ef |
| 1 | Dark Blue | #143cf6 |
| 2 | Green | #48aa1a |
| 3 | Pink | #b844c8 |
| 4 | Purple | #7343db |
| 5 | Yellow | #fbb32d |
| 6 | Dark Green | #09521d |
| 7 | Orange | #f2772b |
| 8 | Red | #b8202c |
| 9 | Cyan | #0facae |

---

## Mechanics Implementation Summary

### 1. Movement Direction (moveDirection)
- Logic: `(off32=1, off40=1)` = same as rotation, `(1,0)` = perpendicular, `(0,*)` = both
- Visual: White arrows on blocks (↔ or ↕)
- Code: `MoveDirection` enum in `game_models.dart`

### 2. Frozen Blocks (iceCount)
- Parsing: `offset +44` = isFrozen flag, `offset +48` = count
- Visual: Cyan overlay + diagonal lines + number
- Mechanic: Each exited block decreases all frozen blocks' count by 1
- Code: `_decreaseIceCountForAll()` in `game_screen.dart`

### 3. Multi-layer Blocks (innerBlockType)
- Parsing: `offset +96` = hasInnerLayer, `offset +100` = innerBlockType
- Visual: Thick outline (outer) + fill (inner)
- Mechanic: Touch outer door = destroy layer, then exit through inner door
- Code: `_checkLayerDestruction()` in `game_screen.dart`

---

## Level Verification System

### Verification Rules
1. User reports what needs to change in level
2. Modify parsing algorithm, **but ensure verified levels don't change**
3. Find solution that doesn't break existing work
4. If changes affect verified levels - **don't modify, ask user first**

### After Parser Changes
1. Re-parse levels (`python res/ColorBlockJam_Analysis/tools/parse_from_unity.py`)
2. Update visualizer (`level_visualizer.html`)
3. Update game (`python res/ColorBlockJam_Analysis/tools/export_game_levels.py`)
4. Run verification (`python res/ColorBlockJam_Analysis/tools/verify_levels.py`)
5. Update documentation
6. Commit and push

### Verification Commands
```bash
# Save snapshot of verified levels
python res/ColorBlockJam_Analysis/tools/verify_levels.py --save

# Check if verified levels are unchanged
python res/ColorBlockJam_Analysis/tools/verify_levels.py
```

### Level Status
- ✅ Levels 1-27: Verified and exported
- ❌ Levels 28-31: Missing in APK (loaded from server)
- ⏳ Levels 32+: Not checked

---

## Levels 28-31 Investigation

### Problem
Levels 28-31 are not in local APK files. They have GUIDs but data is loaded from server.

### Missing Level GUIDs
- **Game Index 28:** `3a21dc2a-95ed-42b1-aa96-24af7ffae92a`
- **Game Index 29:** `648d6ef2-8c27-4583-8fca-4e03d8e16557`
- **Game Index 30:** `7bf81a57-669f-4969-a86f-44e1c99a4c72`
- **Game Index 31:** `ad8c6c0e-f2cf-41b9-b6e8-fcf8008c481e`

### Findings
- Firebase Storage: `color-block-jam.firebasestorage.app`
- Classes: `NewLevelDataWithAdditionals`, `_newAddedLevelsWithAdditionals`
- Remote Config has metadata (duration, hardness) but NOT level data
- Level 28 internal name: `Level mix Derin 19`

### Options to Get Data
1. **Charles Proxy** (recommended) - intercept network traffic
2. **Root phone** - access internal storage (risky)
3. **Newer APK version** - may have levels locally

---

## Original Game Data (from screenshots)

### Monetization (UAH prices)
| Coins | Price |
|-------|-------|
| 1,000 | 79.99 |
| 5,000 | 284.99 |
| 10,000 | 549.99 |
| 25,000 | 1,099.99 |
| 50,000 | 1,949.99 |
| 100,000 | 3,649.99 |
| No Ads | 284.99 |

### Boosters (from game screen)
- Clock: +15 seconds
- Hammer: Destroy block
- Drill: Unknown
- Pause: Pause game

### Social Rewards
- Instagram: +100 coins
- Facebook: +100 coins
- TikTok: +100 coins

---

## Tools & Files

### Parsing Tools
| Tool | Purpose |
|------|---------|
| `parse_from_unity.py` | Parse Unity binary assets |
| `export_game_levels.py` | Export to game JSON format |
| `verify_levels.py` | Verify levels unchanged |

### Phone Cache (from investigation)
| File | Description |
|------|-------------|
| `ELEPHANT_REMOTE_CONFIG_DATA` | Remote Config (571KB) |
| `CACHED_OPEN_RESPONSE` | Server response (685KB) |
| `Save.dat` | Game save file |

### ADB Commands
```bash
# Check connection
adb devices

# List game files
adb shell "ls -la /sdcard/Android/data/com.GybeGames.ColorBlockJam/"

# Pull save file
adb pull "/sdcard/Android/data/com.GybeGames.ColorBlockJam/files/Save.dat" ./

# Backup game
adb backup -f game_backup.ab -noapk com.GybeGames.ColorBlockJam
```

---

## Files Modified This Session

### Created
- `docs/GAME_ANALYSIS.md` (merged)
- `docs/CHAT_BACKUP.md` (this file)

### Updated
- `docs/GAME_DESIGN.md` (v2.1.0)
- `docs/UI_UX_DESIGN.md` (v2.0.0)
- `docs/TECHNICAL_SPEC.md` (v2.0.0)

### Deleted
- `docs/FULL_GAME_ANALYSIS.md`
- `docs/ORIGINAL_GAME_ANALYSIS.md`
- `docs/TECHNICAL_SPECIFICATION_CORE_MECHANICS.md`
- `docs/chat_backup_level28_investigation.md`

---

## Recent Commits

```
f15de2c docs: Add CHAT_BACKUP.md for session context preservation
9de888d docs: Merge TECHNICAL_SPECIFICATION_CORE_MECHANICS into TECHNICAL_SPEC v2.0
8043447 docs: Merge FULL_GAME_ANALYSIS and ORIGINAL_GAME_ANALYSIS into single GAME_ANALYSIS.md
c6743b0 docs: Rewrite GDD and UI/UX based on actual game screenshots
f2d78a8 docs: Update Game Design Document to v2.0
2445c1c docs: Complete Game Design Document v2.0 and UI/UX Design Document
```

---

## Known Issues / Fixed

| Issue | Status |
|-------|--------|
| Level 15 ShortT position | ✅ Fixed (rotZ=2 offset) |
| Ice overlay bleeding | ✅ Fixed (canvas.clipRect) |
| All levels unlocked | ⚠️ Temporary for testing |
| Levels 28-31 missing | ❌ Server-loaded, not in APK |

---

## Session Notes

- User prefers Ukrainian language in chat
- Documents should be in English for consistency
- Screenshots from original game used for accurate analysis
- Binary parsing tools in `res/ColorBlockJam_Analysis/tools/`
- Level visualizer at `res/ColorBlockJam_Analysis/level_visualizer.html`
- Verified levels snapshot: `res/ColorBlockJam_Analysis/level_data/verified_levels_snapshot.json`

---

*This file serves as a backup of chat context and project state.*
