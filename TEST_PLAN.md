# Test plan

Three layers: Foundation-only Swift Testing in GodModeCore; app Swift Testing for SwiftData/presentation; XCTest/XCUITest for critical flows and measured performance. Source structure validation is a separate convenience and never replaces Swift compilation.

## M1 gates

- Catalog decodes, all four days validate, exact Push data preserved, reference IDs unique, unilateral/superset/circuit/AMRAP/timed structures represented.
- Reject malformed targets, duplicate IDs, dangling references, negative/nonfinite load, incomplete groups, inconsistent side semantics and unsupported catalog versions.
- Profile validates/normalizes name, persists/reopens on disk, repeated save updates one record, failed save preserves user input; no fake history.
- App opens without sign-in, setup saves, catalog navigates, all five tabs appear, validation/error/retry states work.
- Build for iOS 26 simulator in Swift 6; warnings as errors. UI tests on configured simulator. Inspect small/large screens and huge type manually.

## Later milestone gates

M2–3: every command transition and group order; timestamp pause/extension; interrupted atomic writes; relaunch at each set/rest phase; draft/substitution/notes restoration; migration fixtures and compatible app updates. M3A: backup round-trip/integrity/unsupported-version/size/dangling-ID/migration failure, safety snapshot failure, transaction rollback and reset confirmation. Extend exports/tests with every new model. M4: deterministic progression and unsafe escalation rejection. M5–6: XP/ranks/ledger/quests/scheduling plus backup restoration without duplicate rewards. M7–11: load failure/cancellation/release/thermal/skip effects. M12: known metrics/units. M13–15: build capability absent, missing entitlements, OS unsupported, denied/revoked permission, export retry and manual fallback. M16: capture/share/denial. M17–19: device performance, diagnostics redaction/size limits, migration/re-sign/update/backup recovery and standard personal signing.

## Reproducibility

Tests inject clocks, RNG, repositories and UUIDs where nondeterminism matters. Temporary disk stores live in unique test directories and are removed after tests. Production containers are never opened by UI tests. Keep test fixtures separate from production resources. Every meaningful fix adds a regression test. CI uploads xcresult even on failure. Do not claim tests ran when toolchain is absent.

## Host constraints

Windows authoring validates JSON/XML/plist, project membership, documentation and build orchestration tests. macOS CI is authoritative for native compilation, unit tests and simulator UI tests. Dispatch **GodMode checkpoint**, full suite, at milestones; compile-only/unit runs are useful diagnostics but do not satisfy the full gate. Signing is independent. CI screenshots can be reviewed from Windows; physical-device checks wait for a legitimate personal installation without halting source development. Record actual results in `STATUS.md`. V1 schema has no predecessor: reopening coverage is not historical migration coverage.

Build orchestration regression tests cover compilation failure vs test failure, missing signing credentials, archive/export failure, not-run states and unsafe package/suite combinations. No tests may read actual signing credentials. Reports must remain available when a command fails. On force-cancel/runner loss, the last persisted NOT RUN/RUNNING state is incomplete, not PASS.
