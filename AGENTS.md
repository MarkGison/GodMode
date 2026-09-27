# GodMode engineering contract

Read `STATUS.md`, relevant specifications, and `DESIGN_SYSTEM.md` before editing. `PERSONAL_EDITION_OVERRIDE.md` takes precedence over conflicting deployment/build/distribution requirements in the preserved `MASTER_BRIEF.md`. Decisions and implementation status live in the specifications. Parent workspace instructions also apply.

1. Use native Swift. SwiftUI owns UI; RealityKit owns real-time 3D.
2. SwiftData is primary local persistence. Core workouts work offline.
3. Never acknowledge a workout mutation before durable save. Backgrounding or termination must not lose acknowledged data. Persist input drafts; disclose save failure and retain input for retry.
4. Keep significant business logic out of views. Use domain services and injected repositories.
5. No production force unwraps, unnecessary mutable globals, detached tasks without ownership, or unchecked Sendable workarounds.
6. Use structured concurrency; isolate persistence and rendering to their owning executors.
7. Derive timers from absolute timestamps. Persist pause and extension state.
8. HealthKit and advanced integrations are capability-gated and optional. CloudKit is future scope, not required in Personal Edition V1. Neither gates training.
9. 3D degrades gracefully, including missing assets, heat, Low Power Mode, and memory pressure.
10. Accessibility is mandatory: Dynamic Type, VoiceOver, Reduce Motion/Transparency, readable contrast, large controls, optional sound/haptics.
11. Every meaningful bug gets a regression test where practical. Every major engine change gets tests.
12. A milestone is not complete until its build, tests, migration/restoration gates, and required UI checks pass. Do not substitute source inspection for execution.
13. Maintain zero avoidable compiler warnings. Use Swift 6 concurrency checks.
14. Preserve persisted data through versioned migrations; never erase a failing store automatically.
15. Original or properly licensed IP only. Record asset provenance.
16. Do not reward unsafe volume, punish rest, or sell randomized loot/Recovery Tokens. Recovery can earn progression.
17. Centralized design tokens are authoritative. No per-screen visual constants.
18. Profile CPU/GPU/memory/frame pacing; label unmeasured targets honestly.
19. Commit logical milestones. Commit incomplete scaffolding only with its gate status explicitly recorded.
20. Update specifications when behavior changes. No fake production history or enabled controls for unimplemented actions.
21. Advance in `RELEASE_CHECKLIST.md` order. Do not implement later milestones around a failing or unavailable prerequisite gate.
22. Owner uses Windows and iPhone only. Use automated macOS CI for native compilation. Do not require local Xcode, a physical/rented Mac, App Store, TestFlight or paid membership.
23. Signing is a deployment concern, not a source-code prerequisite. Report compilation, tests, archive, signing and IPA independently; unrun is never PASS.
24. Run cheap local checks first; macOS workflows run manually at meaningful checkpoints, not on each push or documentation edit.
25. Stable bundle identity is defined in `Config/build.json`; never change it casually after personal installation. No data keys tied to certificates or provisioning lifetime.
26. Versioned export/import, transactional restoration with safety snapshot, and redacted diagnostics export are V1 requirements. Do not promise data survives uninstall or a changed signing identity.
27. Standard signing and provisioning only. No bypasses, jailbreaks, certificate tricks or credentials in Git/logs/artifacts.

## Commands

Windows: `python tools/validate_repository.py` and `python -m unittest discover -s tools/tests -v`. GitHub Actions: manually dispatch **GodMode checkpoint** after grouped changes; the runner selects the pinned Xcode from `Config/build.json` and executes `tools/ci.py`. Full native tests are the M1 gate. See `WINDOWS_DEVELOPMENT.md`, `CI.md`, and `PERSONAL_INSTALLATION.md`.

## Boundaries

`Packages/GodModeCore`: Foundation-only, Sendable value types, validated catalog, deterministic engines as milestones permit. `GodMode/Data`: SwiftData schemas/repositories. `GodMode/App`: composition and lifecycle. `GodMode/Features`: presentation. `GodMode/DesignSystem`: tokens and primitives. No third-party runtime dependencies. No server, login, analytics SDK, or generative AI in V1.
