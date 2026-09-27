# Delivery status

Updated 2026-09-27. Authoring host: Windows; Swift and Xcode unavailable.

- Milestone 0: complete. Specification foundation authored, reviewed and committed as `e10f441`. Master brief preserved verbatim in `MASTER_BRIEF.md`.
- Milestone 1: foundation source authored and reviewed; Apple build/test/render acceptance is pending. Do not mark complete or advance to M2 until the gate runs successfully on a Mac.
- Milestones 2–19: planned, not implemented. No working workout tracker, 3D character, cloud/HealthKit integration or release build is claimed.

## Decisions recorded

Local owner, no server/account, local repository pattern, bundled validated catalog, versioned SwiftData profile foundation, Swift 6, iOS 26, original assets only. Strict progression ladder supersedes permissive example. Undefined Day 2–4 prescriptions are reviewable seed assumptions. M1 exposes actual catalog and profile behavior only.

## Next gate

On a Mac with Xcode 26 and an installed iOS 26 simulator, run `tools/check-macos.sh`. Fix compilation/test failures and inspect small/large iPhone + accessibility type. Record xcresult and audit evidence, then complete M1 and start M2. See `TEST_PLAN.md` and `RELEASE_CHECKLIST.md`.

## Implemented foundation source

- Native Xcode project with app, Swift Testing unit and XCUITest targets; shared scheme; Swift 6 checks; iOS 26 minimum; Debug and Release configurations.
- Profile setup with validation, explicit SwiftData commit, rollback on save failure, baseline VersionedSchema and MigrationPlan, preserved store on startup failure.
- Five-tab SwiftUI shell, centralized semantic tokens, native scrolling/navigation/controls, accessibility identifiers and initial English string catalog.
- Read-only four-day catalog backed by a local Swift package; exact Push targets, editable remaining prescriptions, safety notes, group/side/tempo/target validation, no fabricated history.
- Foundation-only domain tests; Apple persistence/reopen, presentation failure/retry and UI smoke/launch-performance test sources.
- Reproducible project generator, portable validator, Mac build script and GitHub Actions workflow. No remote repository or CI run has been created.

## Validation performed on Windows

`python tools/validate_repository.py`: **347/347 structural checks passed**. `python -m py_compile tools/generate_project.py tools/validate_repository.py`: passed. Git whitespace check: passed. Xcode project regenerated and checked for stable output. These checks validate content/references, not native runtime behavior.

Swift and xcodebuild are absent from the host PATH. Swift tests, iOS builds, simulator tests, migration execution, rendered layout/contrast, VoiceOver, signing, 3D performance and TestFlight are **not run**. The M1 test sources must not be reported as passing tests. Baseline schema reopening coverage is authored; no historical migration exists yet.

Git author is configured for this repository only using the identity supplied by the user. See `AUDIT.md` for the second-pass findings and remaining risks.
