# GodMode

Native iPhone fitness RPG, iOS 26+. **TRAIN. LEVEL UP. EVOLVE.**

This repository currently contains the specification foundation and **Milestone 1 source awaiting Apple build/test validation**. The implemented scope is profile setup, five-tab SwiftUI shell and a validated four-day program browser. Workout execution, rewards, 3D and system integrations belong to later milestones. This is not a release-ready fitness application.

## Open on a Mac

1. Install Xcode 26+ with an iOS 26+ simulator and select its developer directory.
2. Open `GodMode.xcodeproj`, choose the shared **GodMode** scheme and an iPhone simulator.
3. Run `bash tools/check-macos.sh` for domain tests, iOS unit/UI tests, Debug test build and Release simulator build. Optionally set `GODMODE_SIMULATOR_ID` to choose a device.
4. Run from Xcode and inspect small/large iPhone layouts plus large accessibility text. Record results in `STATUS.md` before advancing to M2.

The simulator does not require a development team. Device installation and TestFlight require your team and a real bundle identifier; `com.example.godmode` is a deliberate placeholder. No runtime third-party packages or project-generation installation is needed. The checked-in project is ready to open; a small standard-library Python generator keeps target membership reproducible when files change.

## Portable authoring checks

```
python tools/validate_repository.py
python tools/generate_project.py
```

The validator checks repository/seed/project structure. It does **not** compile Swift, test SwiftData, inspect rendered UI or prove performance. The Windows authoring host cannot run Apple gates.

## Key files

- `STATUS.md`: actual delivery status and next gate.
- `MASTER_BRIEF.md`: original full request.
- `PRODUCT_SPEC.md`, `ARCHITECTURE.md`, `DATA_MODEL.md`: product and engineering decisions.
- `RELEASE_CHECKLIST.md`, `TEST_PLAN.md`: sequential acceptance criteria.
- `GodMode/DesignSystem/DesignTokens.swift`: authoritative UI tokens.
- `Packages/GodModeCore/Sources/GodModeCore/Resources/home-hypertrophy-v1.json`: editable seed content. Day 2–4 prescriptions are development assumptions awaiting review; loads require confirmation.

No HealthKit/iCloud permissions are requested in the foundation. The local profile uses versioned SwiftData and reports save failures without replacing the store. Preview tabs contain no simulated user history.
