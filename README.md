# GodMode Personal Edition

Native iPhone fitness RPG, iOS 26+. **TRAIN. LEVEL UP. EVOLVE.**

This repository contains the specification foundation and **Milestone 1 with passing native build, tests and boundary-device UI acceptance**. The implemented scope is profile setup, five-tab SwiftUI shell and a validated four-day program browser. Workout execution, rewards, 3D and system integrations belong to later milestones. This is not a release-ready fitness application.

## Develop from Windows

1. Edit and review with Codex on Windows, then run portable checks below.
2. Commit related changes and push to the private repository.
3. In GitHub **Actions → GodMode checkpoint → Run workflow**, choose **full** and **none** for the next native validation gate.
4. Download logs, build-status report and test results from that run's Artifacts. Fix failures before accepting a milestone. Source validation needs no signing credentials.
5. When ready, choose **full + unsigned** for a device package awaiting legitimate personal re-signing, or **full + signed** only when compatible signing secrets are supplied. Follow `PERSONAL_INSTALLATION.md`.

Owner assumptions: Windows PC, iPhone, no physical/rented Mac, no paid Apple Developer membership, no App Store/TestFlight requirement. CI uses hosted macOS within the account's available allowance. Native Swift/SwiftUI/SwiftData/RealityKit remain the stack. `Config/build.json` freezes `com.markgison.godmode` before the first installation and pins CI's Xcode/runtime; never casually change the installed identity. No runtime third-party packages or manually installed proprietary dependencies are needed.

## Portable authoring checks

```
python tools/validate_repository.py
python -m unittest discover -s tools/tests -v
python tools/generate_project.py
```

The validator checks repository/seed/project structure. It does **not** compile Swift, test SwiftData, inspect rendered UI or prove performance. The Windows authoring host cannot run Apple gates.

## Key files

- `STATUS.md`: actual delivery status and next gate.
- `MASTER_BRIEF.md`: original full request.
- `PERSONAL_EDITION_OVERRIDE.md`: authoritative deployment override.
- `PERSONAL_INSTALLATION.md`, `WINDOWS_DEVELOPMENT.md`, `CI.md`: owner workflow and artifact/signing distinctions.
- `BACKUP_SYSTEM.md`, `SYSTEM_CAPABILITIES.md`, `DIAGNOSTICS.md`: new Personal Edition contracts.
- `PRODUCT_SPEC.md`, `ARCHITECTURE.md`, `DATA_MODEL.md`: product and engineering decisions.
- `RELEASE_CHECKLIST.md`, `TEST_PLAN.md`: sequential acceptance criteria.
- `GodMode/DesignSystem/DesignTokens.swift`: authoritative UI tokens.
- `Packages/GodModeCore/Sources/GodModeCore/Resources/home-hypertrophy-v1.json`: editable seed content. Day 2–4 prescriptions are development assumptions awaiting review; loads require confirmation.

No HealthKit/iCloud permissions are requested in the foundation. The local profile uses versioned SwiftData and reports save failures without replacing the store. Preview tabs contain no simulated user history.

Backup/import and diagnostics export are V1 requirements, not yet implemented runtime features. Personal Edition settings reports versions and current capability exclusions. [Checkpoint 36354396835](https://github.com/MarkGison/GodMode/actions/runs/36354396835) passed Debug/Release builds, 31 native test executions and device archive/unsigned IPA packaging. Signing remains NOT CONFIGURED. M2 workout engine is next; see `STATUS.md` for evidence and the local artifact path.
