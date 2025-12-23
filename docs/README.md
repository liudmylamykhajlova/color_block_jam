# 📚 Color Block Jam Documentation

> Documentation hub for the project

---

## 📋 Documents Overview

| Document | Description | Version |
|----------|-------------|---------|
| [🎮 GAME_DESIGN.md](./GAME_DESIGN.md) | Game Design Document - gameplay, mechanics, economy, monetization | v3.0.0 |
| [🎨 UI_UX_DESIGN.md](./UI_UX_DESIGN.md) | UI/UX Design - all screens, components, animations, style guide | v2.0.0 |
| [🔧 TECHNICAL_SPEC.md](./TECHNICAL_SPEC.md) | Technical Specification - architecture, models, algorithms, services | v2.0.0 |
| [🔍 GAME_ANALYSIS.md](./GAME_ANALYSIS.md) | Original Game Analysis - App Store data, XAPK reverse-engineering, binary offsets | v1.0.0 |
| [🗺️ ROADMAP.md](./ROADMAP.md) | Development Roadmap - phases, milestones, timeline | v1.5.0 |

---

## 📖 Document Details

### 🎮 GAME_DESIGN.md (GDD)
**Purpose:** What to build and how it should work

Contains:
- Core gameplay rules
- Block types (12 shapes, 10 colors)
- Game mechanics (movement, frozen, multi-layer)
- Economy (coins, lives, timer)
- Monetization (ads, IAP)
- Audio design
- Visual style
- Localization plan

### 🎨 UI_UX_DESIGN.md
**Purpose:** How screens look and behave

Contains:
- Design system (colors, typography)
- 9 screen specifications with ASCII mockups
- Component library (buttons, dialogs, toggles)
- Animation specifications
- Accessibility guidelines
- Implementation notes

### 🔧 TECHNICAL_SPEC.md
**Purpose:** How to implement technically

Contains:
- Architecture diagram
- Project structure
- Data models (GameBlock, GameDoor, GameLevel)
- Core algorithms (collision, door exit, mechanics)
- Services (Storage, Audio)
- Performance requirements
- Testing checklist

### 🔍 GAME_ANALYSIS.md
**Purpose:** Reference from original game

Contains:
- App Store data (publisher, ratings, prices)
- Binary structure (block 156 bytes, door 40 bytes)
- Binary offsets for all properties
- Color palette (exact HEX codes)
- Level statistics (1557 total)
- Mechanics not yet implemented
- Comparison table (original vs our game)

### 🗺️ ROADMAP.md
**Purpose:** Development timeline

Contains:
- Phase definitions
- Milestone tracking
- Task status
- Version history

---

## 🚀 Quick Links

### Current Status
- **Phase 1:** Core Gameplay ✅ DONE
- **Phase 2:** Economy (Next)
- **Levels:** 27 exported, verified
- **Mechanics:** moveDirection, iceCount, innerBlockType

### Tech Stack
| Component | Technology |
|-----------|------------|
| Framework | Flutter 3.x |
| Language | Dart 3.x |
| State | setState |
| Storage | SharedPreferences |
| Rendering | CustomPainter |

### Commands
```bash
# Run game
flutter run -d windows
flutter run -d chrome

# Parse levels
python res/ColorBlockJam_Analysis/tools/parse_from_unity.py
python res/ColorBlockJam_Analysis/tools/export_game_levels.py

# Open visualizer
res/ColorBlockJam_Analysis/level_visualizer.html
```

---

## 📁 Project Structure

```
color_block_jam/
├── docs/                    # Documentation
│   ├── GAME_DESIGN.md       # What to build
│   ├── UI_UX_DESIGN.md      # How it looks
│   ├── TECHNICAL_SPEC.md    # How to implement
│   ├── GAME_ANALYSIS.md     # Original game reference
│   ├── ROADMAP.md           # Timeline
│   └── README.md            # This file
├── lib/                     # Flutter source code
│   ├── core/                # Models, services, constants
│   ├── data/                # Level loader
│   └── features/            # Screens (menu, game, etc.)
├── assets/                  # Game assets
│   └── levels/              # Level JSON files
└── res/                     # Analysis & tools
    └── ColorBlockJam_Analysis/
        ├── tools/           # Python parsing scripts
        └── level_visualizer.html
```

---

## 📝 Documentation Rules

1. **Language:** English for all documents
2. **Format:** Markdown with tables and code blocks
3. **Versioning:** Semantic versioning (MAJOR.MINOR.PATCH)
4. **Updates:** Update relevant docs when making changes
5. **Commits:** Include doc updates in feature commits

---

*Last sync: 2025-12-23*
