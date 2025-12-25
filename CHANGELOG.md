# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- CI/CD pipeline with GitHub Actions
- Automatic builds for Android (APK/AAB) and Web
- GitHub Pages deployment for web version
- Dependabot for dependency updates

## [1.0.0] - 2024-12-25

### Added
- Core gameplay mechanics
  - Block movement with swipe gestures
  - Color-matching door exits
  - Multi-layer blocks
  - Frozen (ice) blocks
  - Movement direction constraints

- 4 Boosters system
  - ❄️ Freeze - stops timer for 5 seconds
  - 🚀 Rocket - destroys single cell
  - 🔨 Hammer - destroys entire block (or outer layer)
  - 🧹 Vacuum - removes all blocks of same color

- Booster special block handling
  - Frozen blocks: boosters decrease ice count
  - Multi-layer blocks: Hammer/Vacuum remove outer layer only

- UI/UX
  - Splash screen with animated loading
  - Level map with 27 levels
  - Game screen with timer and boosters bar
  - Win/Fail dialogs with animations
  - Settings screen
  - Profile screen with avatar selection

- 27 playable levels with increasing difficulty

### Technical
- Flutter 3.24.0
- Comprehensive unit test coverage
- Documentation (GAME_DESIGN.md, TECHNICAL_SPEC.md)

