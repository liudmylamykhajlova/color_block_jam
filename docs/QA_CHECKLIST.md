# Color Block Jam - QA Checklist

> **Version:** 1.0.0  
> **Date:** 2025-12-23  
> **Status:** Active

---

## 📋 Summary

| Category | Total | Done | Remaining |
|----------|-------|------|-----------|
| Critical | 2 | 2 | 0 |
| High Priority | 7 | 7 | 0 |
| Medium Priority | 12 | 12 | 0 |
| Low Priority | 8 | **2** | **6** |
| **TOTAL** | **29** | **23** | **6** |

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

### Fixed ✅ (2025-12-23)

- [x] **Timer paused on app background**
  - File: `lib/features/game/game_screen.dart`
  - Added: `WidgetsBindingObserver` to pause/resume timer
  - Timer subtracts background time when app resumes

- [x] **Input validation in LevelLoader**
  - File: `lib/core/models/game_models.dart`
  - Added: try-catch for JSON parsing, type validation
  - Added: `LevelLoadException` class
  - Added: `getLevel()`, `clearCache()`, `isCached`, `cachedCount`

- [x] **Lives refill now persisted**
  - File: `lib/core/services/storage_service.dart`
  - Fixed: `_persistLivesUpdate()` saves calculated lives
  - Added: Null safety checks for `_prefs`

---

## 🟡 Medium Priority

### Documentation ✅ (2025-12-23)

- [x] **ROADMAP progress updated**
  - File: `docs/ROADMAP.md`
  - Fixed: Progress 60% → 75%, added Phase 1.5

- [x] **Version consistency fixed**
  - Files: All docs + README.md
  - Synced: ROADMAP v1.6.0, TECHNICAL_SPEC v2.1.0

- [x] **Music toggle already documented**
  - File: `docs/GAME_DESIGN.md`
  - Verified: Section 4.6 + Section 8.1

- [x] **Audio placeholder note added**
  - File: `docs/TECHNICAL_SPEC.md`
  - Added: MVP Note in AudioService section

### Code Quality ✅ (2025-12-23)

- [x] **AppColors class created**
  - File: `lib/core/constants/colors.dart`
  - Added: 25+ semantic color constants

- [x] **Error handling in StorageService**
  - File: `lib/core/services/storage_service.dart`
  - Added: `_ensureInitialized()`, `isInitialized` getter

- [x] **AppConstants class created**
  - File: `lib/core/constants/app_constants.dart`
  - Added: Timer, lives, animation, board constants

- [x] **Loading/error state for level select**
  - File: `lib/features/level_select/level_select_screen.dart`
  - Added: Loading spinner, error UI with retry

### Performance ✅ (2025-12-23)

- [x] **LevelLoader.clearCache() added**
  - File: `lib/core/models/game_models.dart`
  - Done: Earlier with input validation

- [x] **Timer uses Timer.periodic**
  - File: `lib/features/game/game_screen.dart`
  - Fixed: Replaced Future.delayed loop

- [x] **RepaintBoundary added**
  - File: `lib/features/game/game_screen.dart`
  - Done: Wrapped CustomPaint, TODO for full split

- [x] **Shape 11 (U) cell count fixed**
  - Files: All docs updated to 5 cells
  - Verified: Code has 5 cells, works correctly

---

## 🟢 Low Priority

### Code Cleanup ✅ (2025-12-23)

- [x] **Duplicate model files deleted**
  - Removed: `block.dart`, `door.dart`, `level.dart`, `grid_position.dart`
  - Removed: `lib/data/services/level_loader.dart`

- [x] **Empty folders deleted**
  - Removed: `lib/core/utils/`, `lib/game/`, `lib/screens/`, `lib/data/`

- [ ] **No dartdoc comments** (deferred)
  - Files: All `.dart` files
  - Add: `///` documentation for public APIs

- [ ] **Const/imports cleanup** (run locally)
  - Run: `dart fix --apply` when Flutter in PATH

### Testing (deferred to post-MVP)

- [ ] **No unit tests**
  - Add: `test/core/models/game_block_test.dart`

- [ ] **No widget tests**
  - Add: `test/features/settings/settings_screen_test.dart`

- [ ] **No integration tests**
  - Add: `integration_test/level_completion_test.dart`

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


