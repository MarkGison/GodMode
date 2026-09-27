# Sequential delivery and release checklist

Do not advance past a milestone until its required build/tests/audit pass. Status and evidence: `STATUS.md`. Every stage includes updated specs, meaningful regression tests, senior-engineer second pass and a logical Git commit.

| Milestone | Scope | Required exit evidence |
| --- | --- | --- |
| 0 | Specifications, decisions, repository | All required docs coherent; source brief preserved |
| 1 | Xcode shell, DI, SwiftData, tokens, catalog, test targets | iOS build, tests, baseline store reopen, UI smoke, zero avoidable warnings |
| 2 | Workout engine incl. unilateral/AMRAP/groups/tempo/RIR | State-machine tests and command validation |
| 3 | Persistence/restoration | Termination/background/timer/partial-session and migration tests |
| 4 | Fixed-load progression | Parameterized deterministic rule coverage |
| 5 | XP/rank/Gold/ledger/achievements | Thresholds, reward retry/crash/duplicate prevention |
| 6 | Schedule/quests | Daily/weekly occurrence correctness, recovery spacing |
| 7 | RealityKit/asset/performance foundation | Missing assets, cancellation/release, device frame baseline |
| 8 | Appearance/equipment/loadouts | Ownership validation, compatible assets, durable equip |
| 9 | Inventory/loot | Persisted outcomes, duplicate grants, equip/reveal |
| 10 | Dungeons/bosses | Committed work drives capped combat, partial end safe |
| 11 | Premium UI polish | Motion/haptics states, accessibility and failure states |
| 12 | Analytics/history/PR/calendar | Known-fixture metric and unit correctness |
| 13 | Optional HealthKit | Denial/partial permission, retry-safe export |
| 14 | Live Activities | Rest restore, Island/Lock Screen, privacy |
| 15 | Widgets/App Intents | Minimal snapshots, safe resume/start, notification policy |
| 16 | Photo Mode | Device capture, share/cancel/Photos denial |
| 17 | Accessibility/performance | VoiceOver/Dynamic Type, traces and thermal/energy matrix |
| 18 | Adversarial QA | No known critical crash/loss/duplicate/memory/state bugs |
| 19 | Release | Signed TestFlight build, metadata/privacy/support, migration plan |

Before release: replace placeholder bundle ID; configure developer team, entitlements and private iCloud container; audit required-reason APIs/privacy manifest; verify purpose strings; include licensed original icon/art; review workout assumptions with qualified program reviewer; verify App Store declarations; provide support/privacy URLs and export/delete UX; capture real screenshots; set version/build; archive and validate on Mac; upload only with authorized account access. No TestFlight artifact exists until signing, archive and upload actually succeed.

Release metadata draft: Name GodMode. Subtitle Train. Level up. Evolve. Category Health & Fitness. Description centers on offline workout tracking and cosmetic progression. No medical, transformation or guaranteed performance claims. V1.0 remains a target; foundation build version 0.1.0 (1).
