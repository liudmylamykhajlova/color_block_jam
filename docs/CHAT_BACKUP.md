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

---

## Recent Commits

```
9de888d docs: Merge TECHNICAL_SPECIFICATION_CORE_MECHANICS into TECHNICAL_SPEC v2.0
8043447 docs: Merge FULL_GAME_ANALYSIS and ORIGINAL_GAME_ANALYSIS into single GAME_ANALYSIS.md
c6743b0 docs: Rewrite GDD and UI/UX based on actual game screenshots
f2d78a8 docs: Update Game Design Document to v2.0
2445c1c docs: Complete Game Design Document v2.0 and UI/UX Design Document
b9cac40 docs: Add full game analysis with all screens and systems
d6d602d docs: Add comprehensive original game analysis
1f91be5 feat: Add frozen blocks (iceCount) - visualization and unfreezing mechanic
```

---

## Known Issues / TODO

1. **Level 15 ShortT position** - Fixed (rotZ=2 offset correction)
2. **Ice overlay bleeding** - Fixed (canvas.clipRect)
3. **All levels unlocked** - Temporary for testing

---

## Session Notes

- User prefers Ukrainian language in chat
- Documents should be in English for consistency
- Screenshots from original game used for accurate analysis
- Binary parsing tools in `res/ColorBlockJam_Analysis/tools/`
- Level visualizer at `res/ColorBlockJam_Analysis/level_visualizer.html`

---

*This file serves as a backup of chat context and project state.*

