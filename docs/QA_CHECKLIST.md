# Color Block Jam - QA Checklist

> **Version:** 1.0.0  
> **Date:** 2025-12-23  
> **Status:** Active

---

## 📋 Summary

| Category | Total | Done | Remaining |
|----------|-------|------|-----------|
| Critical | 2 | 2 | 0 |
| High Priority | 7 | 4 | 3 |
| Medium Priority | 12 | 0 | 12 |
| Low Priority | 8 | 0 | 8 |
| **TOTAL** | **29** | **6** | **23** |

---

## 🔴 Critical Issues (Fixed)

- [x] Bottom boosters HUD missing → **Documented as Phase 2**
- [x] Coins display missing → **Documented as Phase 2**

---

## 🟠 High Priority

### Fixed ✅

- [x] Block Shape 6 documentation (was ReverseShortL, now Plus)
- [x] Vibration default OFF (was ON)
- [x] Music toggle missing in Settings
- [x] Level fail sound (playLevelFail added)

### To Do 🔧

- [ ] **Timer not paused on app background**
  - File: `lib/features/game/game_screen.dart`
  - Add: `WidgetsBindingObserver` to pause/resume timer

- [ ] **No input validation in LevelLoader**
  - File: `lib/data/services/level_loader.dart`
  - Add: try-catch for JSON parsing errors

- [ ] **Lives refill not persisted**
  - File: `lib/core/services/storage_service.dart`
  - Fix: Save calculated lives back to storage

---

## 🟡 Medium Priority

### Documentation

- [ ] **ROADMAP progress outdated**
  - File: `docs/ROADMAP.md`
  - Fix: Update progress bar from 60% to 70%

- [ ] **Version inconsistency**
  - Files: All docs
  - Fix: Sync versions (ROADMAP v1.5.0 vs GAME_DESIGN v3.0)

- [ ] **Music toggle not documented**
  - File: `docs/GAME_DESIGN.md`
  - Add: Music toggle in Settings section (4.6)

- [ ] **Audio placeholder note missing**
  - File: `docs/TECHNICAL_SPEC.md`
  - Add: Note that audio is haptic-only for MVP

### Code Quality

- [ ] **Hardcoded colors in game_screen**
  - File: `lib/features/game/game_screen.dart`
  - Fix: Move colors to `GameColors` or theme

- [ ] **No error handling in StorageService**
  - File: `lib/core/services/storage_service.dart`
  - Add: Null checks for `_prefs`

- [ ] **Magic numbers scattered**
  - Files: Various
  - Fix: Extract to `lib/core/constants/app_constants.dart`

- [ ] **No loading state for level select**
  - File: `lib/features/level_select/level_select_screen.dart`
  - Add: Shimmer/loading indicator while fetching levels

### Performance

- [ ] **Memory: cached levels never cleared**
  - File: `lib/core/models/game_models.dart` (LevelLoader)
  - Add: `clearCache()` method

- [ ] **Timer uses Future.delayed loop**
  - File: `lib/features/game/game_screen.dart`
  - Fix: Use `Timer.periodic` or `Ticker`

- [ ] **Full repaint on every frame**
  - File: `lib/features/game/game_screen.dart`
  - Add: `RepaintBoundary` for static elements

- [ ] **Shape 11 (U) cell count mismatch**
  - Files: `docs/*.md` vs `game_models.dart`
  - Verify: Docs say 6 cells, code has 5 - check original game

---

## 🟢 Low Priority

### Code Cleanup

- [ ] **Duplicate model files**
  - Location: `lib/core/models/`
  - Action: Remove unused `block.dart`, `door.dart`, `level.dart`, `grid_position.dart`

- [ ] **Empty folders**
  - Locations: `lib/core/utils/`, `lib/game/logic/`, `lib/screens/`
  - Action: Delete or add .gitkeep

- [ ] **No dartdoc comments**
  - Files: All `.dart` files
  - Add: `///` documentation for public APIs

- [ ] **Missing const constructors**
  - Files: Widget classes
  - Add: `const` keyword where possible

- [ ] **Unused imports**
  - Files: Various
  - Run: `dart fix --apply`

### Testing

- [ ] **No unit tests**
  - Add: `test/core/models/game_block_test.dart`
  - Cover: `GameBlock.cells`, collision detection

- [ ] **No widget tests**
  - Add: `test/features/settings/settings_screen_test.dart`
  - Cover: Toggle states, dialog interactions

- [ ] **No integration tests**
  - Add: `integration_test/level_completion_test.dart`
  - Cover: Full level flow from start to win

---

## 🔒 Security & Quality

- [ ] **GameLogger may log too much in release**
  - File: `lib/core/services/game_logger.dart`
  - Add: `kReleaseMode` check to disable verbose logging

- [ ] **No bounds checking for level IDs**
  - File: `lib/features/game/game_screen.dart`
  - Add: Validate levelId before loading

- [ ] **No global error handler**
  - File: `lib/main.dart`
  - Add: `ErrorWidget.builder` for graceful error handling

---

## 📱 Pre-Release Checklist

### Before Soft Launch

- [ ] Timer background handling (High)
- [ ] Input validation (High)
- [ ] Lives persistence fix (High)
- [ ] Test on low-end Android device
- [ ] Test on iOS simulator/device
- [ ] Check memory usage < 100MB
- [ ] Verify 60 FPS gameplay

### Before Store Submission

- [ ] App icon (1024x1024)
- [ ] Splash screen
- [ ] Screenshots (5-8)
- [ ] Store description (EN)
- [ ] Privacy policy URL
- [ ] Age rating questionnaire
- [ ] Release build signed

---

## 📊 Test Coverage Targets

| Module | Current | Target |
|--------|---------|--------|
| `game_models.dart` | 0% | 80% |
| `storage_service.dart` | 0% | 90% |
| `audio_service.dart` | 0% | 50% |
| `game_screen.dart` | 0% | 60% |
| **Overall** | **0%** | **70%** |

---

## 🗓️ Recommended Fix Order

### Week 1 (Pre-Release)
1. Timer background handling
2. Input validation
3. Lives persistence
4. Update ROADMAP progress

### Week 2 (Post-Release)
5. Extract constants
6. Add error handling
7. Clean up unused files
8. Performance optimizations

### Week 3+ (Ongoing)
9. Write unit tests
10. Add dartdoc comments
11. Widget tests
12. Integration tests

---

## Change History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-12-23 | Initial QA checklist |


