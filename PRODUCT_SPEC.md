# Product specification

GodMode — **TRAIN. LEVEL UP. EVOLVE.** A native iPhone workout tracker whose original fantasy character advances through real training and recovery. iOS 26 minimum, portrait, English initially, structurally localizable. Two 10 kg dumbbells and an adjustable bench are the initial equipment. The product must remain useful without internet, HealthKit, cloud, audio, or 3D.

## Authoritative scope

The complete requested experience and screen inventory are retained in `MASTER_BRIEF.md` §§9–10, 22–68, 75. `PERSONAL_EDITION_OVERRIDE.md` supersedes its deployment requirements. Current product is **GodMode Personal Edition**, private personal sideloading on the owner's iPhone, authored from Windows. No local/rented Mac, paid membership, App Store or TestFlight is required. No subscriptions, social backend, multiplayer, Watch app, or AI coach in V1. CloudKit moves to future optional scope. HealthKit and system surfaces remain modular and unavailable-capability states are valid.

## User flow and hierarchy

Launch → brief Awakening → setup (equipment, experience, training days, accessibility preferences) → Hunter creation → System. No login or permission wall. System presents today's scheduled Main Quest, recovery when scheduled, or a persisted Resume card. Quest details show exercise sequence, prescriptions, substitutions, and dungeon. Start saves the session before presenting exercise controls. Complete Set saves once, starts rest, and emits an optional visual attack. Completion saves workout results before issuing rewards or playing skippable cinematics. Progress shows actual saved history only.

Five native tabs: System, Quests, Hunter, Arsenal, Progress. Settings accessible from System/Hunter. Nested navigation preserves active workout independently of tab selection. Training hierarchy: exercise, set, reps/load, tempo, RIR, rest, completion; decoration never covers these controls. At accessibility sizes use vertical rows, scrolling and reachable primary actions rather than truncating metrics.

## Delivery boundary

M1 provides the native shell, durable basic profile setup, real read-only program catalog, repository boundaries, design tokens and tests. Training execution starts in M2; schedule/onboarding expansion belongs with dependent engines. M1's System says “Your program,” never invents today's scheduled quest. Empty Hunter/Arsenal/Progress surfaces disclose availability without fake rewards, charts or characters. No Start button until durable workout execution exists.

## Product invariants

- No paid randomized loot. No benefit from uncontrolled extra exercise.
- Corrections to fitness logs are allowed and never reissue rewards.
- No diagnostic claims or promises of body transformation from cosmetic presets.
- No optional integration can block save. A primary-store failure is an explicit blocking error with retry, never an in-memory replacement pretending to be durable.
- All celebratory motion is skippable; rest is valid progression.

## Assumptions and resolutions

One local owner, initially thousands of sessions over years, modest catalog, no concurrent server writers. Main access patterns: frequent active-session writes, bounded history reads, immutable catalog reads and reward eligibility transactions. Calendar dates use a stored training time zone; timestamps use absolute instants. Future cloud sync needs explicit conflict policy; it is absent in Personal Edition V1.

The brief's progression example permits slower tempo before all sets reach the upper bound; the stricter ladder wins: no automatic tempo escalation for 12/12/11/10. Safe substitutions use bench-supported movements rather than unverified improvised anchors. Unspecified Day 2–4 targets are editable developer assumptions requiring program review before release; 10 kg availability is not a requirement to use that load for every movement. Default draft load is unconfirmed.

Acceptance is sequential, per `RELEASE_CHECKLIST.md`. A source scaffold is not a released product or a passed milestone.

## Personal Edition additions

Settings → Data Management: Export GodMode Backup, Import GodMode Backup, Backup Information, Reset Local Data. Settings → GodMode Personal Edition: app/build/schema versions, graphics mode, capabilities, developer information and Export Diagnostics. Reset/import require clear confirmation and a durable safety snapshot; no silent partial replacement. Backup/export/import is core functionality independent of entitlements. Full contracts: `BACKUP_SYSTEM.md`, `SYSTEM_CAPABILITIES.md`, `DIAGNOSTICS.md`.

The desired final artifact is a legitimately signed `GodMode.ipa`. A CI validation build or unsigned re-signing package is not an installable signed build. Signing not configured never prevents source development/testing. Re-sign/update attempts preserve data only where iOS retains the container; export outside the app before updates. Deleting the app may delete its local data.
