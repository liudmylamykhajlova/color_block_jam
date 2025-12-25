# Color Block Jam - Technical Specification

> **Version:** 2.1.0  
> **Date:** 2025-12-23  
> **Status:** In Development

---

## 1. Overview

### 1.1 Project Name
**Color Block Jam** - Mobile puzzle game based on sliding colored blocks.

### 1.2 Platforms

| Platform | Status | Min Version |
|----------|--------|-------------|
| Android | Supported | API 21 (5.0) |
| iOS | Supported | iOS 12.0 |
| Web | Experimental | Modern browsers |
| Windows | Dev only | Windows 10+ |

### 1.3 Tech Stack

| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Flutter | 3.x |
| Language | Dart | 3.x |
| State | setState | - |
| Storage | shared_preferences | 2.2.x |
| Rendering | CustomPainter | - |

---

## 2. Architecture

### 2.1 Layer Diagram

```
+------------------------------------------+
|          Presentation Layer              |
|  +----------------+  +----------------+  |
|  | GameScreen     |  | AnimationSystem|  |
|  | (UI Widget)    |  | (Tween)        |  |
|  +----------------+  +----------------+  |
+------------------------------------------+
                    |
+------------------------------------------+
|           Domain Layer                   |
|  +----------------+  +----------------+  |
|  | LevelState     |  | Block/Door     |  |
|  | (Immutable)    |  | (Models)       |  |
|  +----------------+  +----------------+  |
|  +----------------+  +----------------+  |
|  | GameLogic      |  | CollisionSystem|  |
|  | (Pure)         |  | (Grid-based)   |  |
|  +----------------+  +----------------+  |
+------------------------------------------+
                    |
+------------------------------------------+
|            Data Layer                    |
|  +----------------+  +----------------+  |
|  | LevelLoader    |  | StorageService |  |
|  | (JSON)         |  | (Prefs)        |  |
|  +----------------+  +----------------+  |
+------------------------------------------+
```

### 2.2 Project Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── colors.dart          # Block color palette
│   │   └── block_shapes.dart    # Shape definitions
│   ├── models/
│   │   └── game_models.dart     # GameBlock, GameDoor, GameLevel
│   ├── services/
│   │   ├── storage_service.dart # Progress saving
│   │   └── audio_service.dart   # Sound & haptics
│   └── widgets/
│       └── confetti_widget.dart
├── data/
│   └── services/
│       └── level_loader.dart    # JSON level loading
└── features/
    ├── menu/
    ├── level_select/
    ├── game/
    │   └── game_screen.dart     # Main game screen
    └── settings/

assets/
└── levels/
    └── levels_27.json           # 27 levels data

res/
└── ColorBlockJam_Analysis/
    ├── tools/
    │   ├── parse_from_unity.py
    │   └── export_game_levels.py
    └── level_visualizer.html
```

### 2.3 Data Flow

```
levels.json -> LevelLoader -> GameLevel -> GameScreen -> Canvas
                                              |
                                              v
                                        StorageService
```

---

## 3. Data Models

### 3.1 GameLevel

```dart
class GameLevel {
  final int id;
  final String name;
  final int gridWidth;
  final int gridHeight;
  final List<GameBlock> blocks;
  final List<GameDoor> doors;
  final List<Point> hiddenCells;
}
```

### 3.2 GameBlock

```dart
enum MoveDirection {
  horizontal,  // 0 - only left-right
  vertical,    // 1 - only up-down
  both,        // 2 - any direction
}

class GameBlock {
  final int blockType;           // Color (0-9)
  final int blockGroupType;      // Shape (0-11)
  int gridRow;                   // Y position
  int gridCol;                   // X position
  final int rotationZ;           // Rotation (0-3)
  final MoveDirection moveDirection;
  final int innerBlockType;      // Inner layer (-1 = none)
  int iceCount;                  // Freeze count (0 = unfrozen)
  bool outerLayerDestroyed;      // Multi-layer state
  
  List<Point> get cells;         // Calculated cells
  bool get hasInnerLayer;
  bool get isFrozen;
  int get activeBlockType;       // Current active color
}
```

### 3.3 GameDoor

```dart
class GameDoor {
  final int blockType;           // Color
  final int partCount;           // Size (1-4)
  final String edge;             // top/bottom/left/right
  final int startRow;
  final int startCol;
}
```

### 3.4 Block Shapes (blockGroupType)

| ID | Name | Shape | Cells |
|----|------|-------|-------|
| 0 | One | `#` | 1 |
| 1 | Two | `##` | 2 |
| 2 | Three | `###` | 3 |
| 3 | L | L-shape | 4 |
| 4 | ReverseL | Mirrored L | 4 |
| 5 | ShortL | Short L | 3 |
| 6 | Plus | Cross (+) | 5 |
| 7 | TwoSquare | 2x2 | 4 |
| 8 | ShortT | T-shape | 4 |
| 9 | Z | Z-shape | 4 |
| 10 | ReverseZ | S-shape | 4 |
| 11 | U | U-shape | 5 |

---

## 4. Core Algorithms

### 4.1 Collision Detection

```dart
bool _canMove(GameBlock block, int deltaRow, int deltaCol, GameLevel level) {
  // 1. Check freeze (isFrozen) - frozen blocks can't move
  if (block.isFrozen) return false;
  
  // 2. Check movement direction restriction
  if (block.moveDirection == MoveDirection.horizontal && deltaRow != 0)
    return false;
  if (block.moveDirection == MoveDirection.vertical && deltaCol != 0)
    return false;
  
  // 3. Calculate new cell positions
  // 4. Check grid boundaries
  // 5. Check doors (allow exit if matching color)
  // 6. Check collisions with other blocks
  // 7. Check hidden cells
}
```

### 4.2 Door Exit Detection

```dart
void _checkDoorExit(GameLevel level) {
  // 1. Count cells outside grid
  // 2. If >= 50% cells outside:
  //    - Start exit animation
  //    - Remove block
  //    - Decrease ice count for all frozen blocks
  // 3. If all blocks exited -> win
}
```

### 4.3 Multi-layer Block Destruction

```dart
void _checkLayerDestruction(GameBlock block, GameLevel level) {
  // 1. If block touches door of OUTER color:
  //    - Destroy outer layer (outerLayerDestroyed = true)
  //    - Block stays on field with INNER color
  //    - Block does NOT enter door
  // 2. After outer layer destroyed:
  //    - Block can only exit through INNER color door
}
```

### 4.4 Ice/Freeze Mechanic

```dart
void _decreaseIceCountForAll() {
  // When ANY block exits through door:
  // - Decrease iceCount for ALL frozen blocks by 1
  // - When iceCount = 0, block unfreezes
}
```

### 4.5 Booster System

#### Freeze Time Booster
```dart
// State
bool _isFrozen = false;
int _freezeRemainingSeconds = 0;
Timer? _freezeTimer;

void _activateFreeze() {
  _isFrozen = true;
  _freezeRemainingSeconds = AppConstants.freezeBoosterDuration; // 5 sec
  _startFreezeTimer();
}

void _endFreeze() {
  _isFrozen = false;
  _freezeRemainingSeconds = 0;
}

// Timer behavior:
// - Main game timer STOPS when frozen
// - Freeze countdown runs independently
// - Blocks still movable during freeze
```

#### Rocket Booster
```dart
// State
bool _isRocketMode = false;
bool _isRocketAnimating = false;
Offset? _rocketStartPos;
Offset? _rocketEndPos;

void _useRocketBooster() {
  _isRocketMode = true;
  // Don't consume booster until cell tapped
}

void _onRocketCellTap(GameBlock block, Point cell, Offset tapPosition) {
  // 1. Consume booster
  // 2. Calculate animation positions
  // 3. Start rocket animation
  // 4. On animation complete: explosion animation
  // 5. On explosion complete: remove cell from block
  // 6. If block has no cells left → remove block
}

void _cancelRocketMode() {
  _isRocketMode = false;
  _isRocketAnimating = false;
}

// GameBlock.removeUnit() - uses indices for persistence across movement:
class GameBlock {
  final List<int> removedUnitIndices = []; // Store indices, not coordinates
  
  bool removeUnit(Point absoluteCell) {
    final baseCells = _baseCells;
    final indexToRemove = baseCells.indexOf(absoluteCell);
    if (indexToRemove != -1) {
      removedUnitIndices.add(indexToRemove);
    }
    return cells.isNotEmpty;
  }
  
  List<Point> get cells {
    final baseCells = _baseCells;
    return List.generate(baseCells.length, (i) => i)
        .where((i) => !removedUnitIndices.contains(i))
        .map((i) => baseCells[i])
        .toList();
  }
}
```

#### Hammer Booster
```dart
// State
bool _isHammerMode = false;
bool _isHammerAnimating = false;
Offset? _hammerStartPos;
Offset? _hammerEndPos;
GameBlock? _pendingHammerDestroyBlock;

void _useHammerBooster() {
  _isHammerMode = true;
  // Don't consume booster until block tapped
}

void _onHammerBlockTap(GameBlock block, Offset tapPosition) {
  // 1. Consume booster
  // 2. Calculate animation positions (from booster bar to block)
  // 3. Start hammer animation (arc trajectory, spinning)
  // 4. On animation complete: big explosion animation
  // 5. On explosion complete: remove entire block
}

void _cancelHammerMode() {
  _isHammerMode = false;
  _isHammerAnimating = false;
}

// Animation: HammerAnimation widget with:
// - Strike animation (raise up, slam down)
// - Rotation swing (tilt back, swing forward)
// - Scale on impact
// - Fade out at end

// Explosion: BigExplosionAnimation widget with:
// - Expanding circle with gradient
// - 8 flying particles
// - Size based on block cell count
```

#### Booster Lifecycle
```
Activate → Use → Deactivate

Auto-cancel triggers:
- _onPauseTap()
- didChangeAppLifecycleState(paused/inactive)
- _showWinDialog()
- _showFailDialog()
- _onTimeUp()
- _resetLevel()
```

### 4.6 Block Movement Animation

```dart
void _animateBlockMove(Block block, Point from, Point to) {
  // Duration: 200-300ms per step
  // Easing: Curves.easeOutCubic
  // Animate each step separately (not one big move)
}
```

---

## 5. Visual Design

### 5.1 Color Palette (10 colors)

| ID | Name | HEX |
|----|------|-----|
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

### 5.2 Block Visual Style

- **Shape:** 3D cubes with rounded corners (8-12px radius)
- **Shadow:** Drop shadow blur 4-6px, offset (2, 2)
- **Gradient:** Linear gradient light to dark
- **Outline:** 1-2px darker shade border
- **Stud:** LEGO-style circle in center of each cell

### 5.3 Block Animations

| Animation | Duration | Easing |
|-----------|----------|--------|
| Pickup | 50ms | easeOut |
| Move | 200-300ms | easeOutCubic |
| Drop | 100ms | bounceOut |
| Exit | 300ms | easeIn |
| Collision | 200ms | shake |

### 5.4 Special Effects

**Ice Overlay:**
- Semi-transparent cyan layer
- Diagonal crystal pattern (white lines)
- Ice count number in white circle

**Multi-layer:**
- Thick outline of outer color
- Fill with inner color
- Studs in inner color

**Movement Arrows:**
- White arrows on restricted blocks
- `↔` for horizontal only
- `↕` for vertical only

---

## 6. Services

### 6.1 StorageService

| Method | Description |
|--------|-------------|
| `init()` | Initialize SharedPreferences |
| `getCompletedLevels()` | Get completed level IDs |
| `markLevelCompleted(id)` | Mark level as complete |
| `getSoundEnabled()` | Sound toggle state (default: ON) |
| `getMusicEnabled()` | Music toggle state (default: ON) |
| `getHapticEnabled()` | Haptic toggle state (default: OFF) |
| `getLives()` | Get current lives (with time-based refill) |
| `loseLife()` | Decrease lives by 1 |
| `addLife(count)` | Add lives (e.g., from ads) |
| `refillLives()` | Set lives to max (5) |
| `hasLives()` | Check if lives > 0 |
| `getTimeUntilNextLife()` | Time until next refill |
| `resetProgress()` | Reset all progress |

**Lives Constants:**
- `maxLives`: 5
- `lifeRefillMinutes`: 30

**Audio Defaults (per original game):**
- Sound: ON
- Music: ON
- Vibration: OFF

### 6.2 AudioService

> **⚠️ MVP Note:** Current implementation uses **haptic feedback only**. 
> Sound effects (`play*` methods) trigger vibration patterns, not actual audio.
> Real audio files will be added in Phase 2 using `audioplayers` package.

| Method | Description |
|--------|-------------|
| `lightTap()` | Light haptic (buttons) |
| `mediumTap()` | Medium haptic (pickup) |
| `heavyTap()` | Heavy haptic (drop) |
| `success()` | Win haptic pattern |
| `error()` | Error/fail vibration |
| `playPickup()` | Block pickup → haptic |
| `playDrop()` | Block drop → haptic |
| `playExit()` | Block exit → haptic |
| `playWin()` | Win → haptic pattern |
| `playLevelFail()` | Level fail → error haptic |
| `playTap()` | Button tap → light haptic |
| `setSoundEnabled(value)` | Toggle sound/haptic |
| `setMusicEnabled(value)` | Toggle music (stub) |
| `setHapticEnabled(value)` | Toggle vibration |
| `setMusicEnabled(value)` | Toggle music |
| `setHapticEnabled(value)` | Toggle vibration |

---

## 7. Performance Requirements

| Metric | Target |
|--------|--------|
| Startup time | < 2s |
| Frame rate | 60 FPS |
| Memory usage | < 100 MB |
| APK size | < 20 MB |
| Frame time | < 16.67ms |

### 7.1 Optimizations

- Use `RepaintBoundary` for isolated repaints
- Cache `Paint` objects
- Minimize allocations in paint methods
- Use `shouldRepaint` for conditional repaints
- Keep coordinate maps/sets for fast lookups

---

## 8. Testing

### 8.1 Unit Tests
- [ ] GameBlock.cells calculation
- [ ] Collision detection
- [ ] Door matching
- [ ] Multi-layer destruction
- [ ] Ice count decrease

### 8.2 Widget Tests
- [ ] Menu navigation
- [ ] Level selection
- [ ] Win dialog

### 8.3 Integration Tests
- [ ] Complete level flow
- [ ] Progress saving/loading
- [ ] All mechanics combined

---

## 9. Acceptance Criteria

### Functionality
- [x] Blocks move on swipe
- [x] Blocks stop at collisions
- [x] Blocks exit through matching doors
- [x] Win detection works
- [x] Movement direction restrictions
- [x] Frozen blocks mechanic
- [x] Multi-layer blocks mechanic
- [x] Timer system (countdown, color change on low time)
- [x] Lives system (5 max, 30 min refill, lose on fail)

### Visual
- [x] Blocks have 3D appearance
- [x] Doors visually distinct
- [x] Smooth animations (60 FPS)
- [x] Ice overlay effect
- [x] Multi-layer visualization
- [ ] UI doesn't overlap game

### Performance
- [x] Stable 60 FPS
- [x] No memory leaks
- [x] Fast level loading (< 1s)

---

## 10. Future Integrations

### Planned
- [ ] Firebase Analytics
- [ ] Firebase Crashlytics
- [ ] AdMob (rewarded + interstitial)
- [ ] In-App Purchases
- [ ] Push Notifications

---

## Change History

| Version | Date | Changes |
|---------|------|---------|
| 2.1.0 | 2025-12-23 | Added MVP audio note (haptic-only), music settings |
| 2.0.0 | 2025-12-23 | Merged with CORE_MECHANICS, added visual design |
| 1.5.0 | 2025-12-23 | Added iceCount (frozen blocks) |
| 1.4.0 | 2025-12-21 | Multi-layer block mechanics |
| 1.3.0 | 2025-12-21 | Added innerBlockType |
| 1.2.0 | 2025-12-21 | Added MoveDirection |
| 1.0.0 | 2025-12-17 | Initial version |
