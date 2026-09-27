# Personal Edition delivery checklist

Do not advance past an applicable source milestone until its CI build/tests/audit pass. Status and evidence: `STATUS.md`. Every stage includes updated specs, meaningful regression tests, senior-engineer second pass and a logical Git commit. Owner works on Windows; macOS CI is authoritative. Signing and physical-device evidence are tracked independently and never block source implementation just because signing is unconfigured. Device acceptance remains required before declaring V1 ready.

| Milestone | Scope | Required exit evidence |
| --- | --- | --- |
| 0 | Specifications, decisions, repository | All required docs coherent; source brief preserved |
| 1 | Xcode shell, DI, SwiftData, tokens, catalog, test targets | iOS build, tests, baseline store reopen, UI smoke, zero avoidable warnings |
| 2 | Workout engine incl. unilateral/AMRAP/groups/tempo/RIR | State-machine tests and command validation |
| 3 | Persistence/restoration | Termination/background/timer/partial-session and migration tests |
| 3A | Backup/import foundation | Versioned full current-schema export, integrity, safety snapshot, transactional import/reset, round-trip/failure tests; extend with every new aggregate |
| 4 | Fixed-load progression | Parameterized deterministic rule coverage |
| 5 | XP/rank/Gold/ledger/achievements | Thresholds, reward retry/crash/duplicate prevention |
| 6 | Schedule/quests | Daily/weekly occurrence correctness, recovery spacing |
| 7 | RealityKit/asset/performance foundation | Missing assets, cancellation/release, device frame baseline |
| 8 | Appearance/equipment/loadouts | Ownership validation, compatible assets, durable equip |
| 9 | Inventory/loot | Persisted outcomes, duplicate grants, equip/reveal |
| 10 | Dungeons/bosses | Committed work drives capped combat, partial end safe |
| 11 | Premium UI polish | Motion/haptics states, accessibility and failure states |
| 12 | Analytics/history/PR/calendar | Known-fixture metric and unit correctness |
| 13 | Optional HealthKit | Capability/entitlement/denial fallback, manual metrics, retry-safe export when available |
| 14 | Optional Live Activities | Rest restore and privacy when supported; in-app rest remains complete |
| 15 | Optional widgets/App Intents | Minimal snapshots and safe resume/start where supported; no required extensions |
| 16 | Photo Mode | Device capture, share/cancel/Photos denial |
| 17 | Accessibility/performance | VoiceOver/Dynamic Type, traces and thermal/energy matrix |
| 18 | Adversarial QA + diagnostics | No critical loss/duplicate/memory/state bugs; redacted diagnostics export and complete backup coverage |
| 19 | Personal install readiness | CI/tests/migrations/backup pass; standard IPA signing path; owner-device evidence and update safety |

Before personal installation: preserve the stable bundle identity in `Config/build.json`; verify iPhone OS compatibility; audit required-reason APIs/privacy descriptions for enabled modules; include original/legal assets; review workout assumptions; verify export/import and migration coverage for every aggregate; test compatible updates and expiry recovery without uninstalling; record separate compilation/tests/archive/signing/IPA states. Missing credentials are NOT CONFIGURED, not a compilation failure. Never label an unsigned package installable.

No App Store metadata, TestFlight, public distribution, paid membership or iCloud container is a V1 requirement. Future distribution changes require a new instruction. Current identity: GodMode Personal Edition; tagline Train. Level up. Evolve.; version 0.1.0 (1). Version 1.0 remains a target. Existing workout, RPG, accessibility and 60 FPS scene goals remain intact.

V1 technical readiness requires CI compilation, unit/core workout/restoration/progression/reward/migration/backup tests, offline core behavior, safe capability fallbacks, diagnostics, documentation, graceful missing-asset behavior and measured supported-device performance. Valid `GodMode.ipa` generation must be supported when legitimate signing is supplied; no publication step is required.
