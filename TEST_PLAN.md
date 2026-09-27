# Test plan

Three layers: Foundation-only Swift Testing in GodModeCore; app Swift Testing for SwiftData/presentation; XCTest/XCUITest for critical flows and measured performance. Source structure validation is a separate convenience and never replaces Swift compilation.

## M1 gates

- Catalog decodes, all four days validate, exact Push data preserved, reference IDs unique, unilateral/superset/circuit/AMRAP/timed structures represented.
- Reject malformed targets, duplicate IDs, dangling references, negative/nonfinite load, incomplete groups, inconsistent side semantics and unsupported catalog versions.
- Profile validates/normalizes name, persists/reopens on disk, repeated save updates one record, failed save preserves user input; no fake history.
- App opens without sign-in, setup saves, catalog navigates, all five tabs appear, validation/error/retry states work.
- Build for iOS 26 simulator in Swift 6; warnings as errors. UI tests on configured simulator. Inspect small/large screens and huge type manually.

## Later milestone gates

M2–3: every command transition and group order; timestamp pause/extension; interrupted atomic writes; relaunch at each set/rest phase; draft/substitution/notes restoration; migration fixtures. M4: parameterized deterministic progression edges and unsafe escalation rejection. M5–6: nonlinear XP thresholds, rank criteria, ledger retry/concurrency/crash boundaries, quests, weekly membership, schedule shifts/DST. M7–11: scene load failure, cancellation, missing equipment, background release, thermal policy, skippable effects. M12: compare analytics with known real fixtures and unit conventions. M13–15: denied permissions, export retries, extension privacy and deep link reconciliation. M16: photo export cancellation and permission denial. M17–19: accessibility and measured performance matrix, release/privacy/signing gates.

## Reproducibility

Tests inject clocks, RNG, repositories and UUIDs where nondeterminism matters. Temporary disk stores live in unique test directories and are removed after tests. Production containers are never opened by UI tests. Keep test fixtures separate from production resources. Every meaningful fix adds a regression test. CI uploads xcresult even on failure. Do not claim tests ran when toolchain is absent.

## Host constraints

Windows authoring can validate JSON, XML/plist, paths, project membership, docs and source invariants. It cannot build SwiftUI/SwiftData/RealityKit or run iOS Simulator. `tools/check-macos.sh` is the required next gate. Record actual results in `STATUS.md`. V1 schema has no prior version: reopening coverage is not advertised as a completed migration suite.
