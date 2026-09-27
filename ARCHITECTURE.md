# Architecture

## Pattern and ownership

Feature-oriented Clean Architecture with MVVM presentation and a **local repository pattern**. Views → observable MainActor presentation models → use cases/domain services → protocol repositories → SwiftData/system adapters. Domain values are Sendable; persistent objects never escape their context. UI and rendering do not decide rewards or progression.

```
GodMode.xcodeproj/              app, unit tests, UI tests, shared scheme
GodMode/App/                   composition root and launch failure handling
GodMode/DesignSystem/          semantic tokens and shared primitives
GodMode/Features/              shell, setup, catalog; later workout/RPG features
GodMode/Data/                  versioned schemas, local repositories
GodMode/Resources/             privacy manifest, localization, assets
Packages/GodModeCore/          Foundation-only domain and bundled catalog
GodModeTests/                  Apple persistence and presentation tests
GodModeUITests/                accessibility-aware critical flow tests
tools/                        portable structural validator, Mac build gate
.github/workflows/             Apple build/test CI
```

## Persistence options considered

| Option | Reads/writes and ownership | Cost and limits |
| --- | --- | --- |
| Local repository + normalized SwiftData | Owner edits profile/session/set records; transactions and bounded indexed history queries | Chosen. No service operation cost; explicit migrations and later sync reconciliation needed |
| Local repository + opaque Codable session blobs in SwiftData | Owner replaces an entire session snapshot | Simpler for a disposable single-session demo; poor set analytics, large rewrites and harder conflict merging |
| Local repository + private CloudKit mirroring | Same local writes plus asynchronous replication to owner's iCloud | Planned opt-in; entitlement/schema/conflict testing required; unsuitable as M1 dependency |

**Why this approach:** local repositories keep training responsive and testable without network or Apple rendering frameworks. `profileRepository.save(profile)` returns only after save; catalog reads decode/validate a bundled immutable resource. Local owner isolation uses the device sandbox. There are no REST routes, server auth, or account credentials to operate.

**Simpler alternative:** JSON files suffice for a catalog-only viewer. They give up SwiftData queries and planned migration support for mutable training data.

## Composition and failure handling

App composition constructs one versioned local ModelContainer, one profile repository and one catalog repository. M1 explicitly opts out of automatic CloudKit discovery. Load the catalog on an async task; errors render Retry. Store-open failures preserve the store and present Retry; never use `try!`, delete the database, or silently fall back to memory. UI tests use a distinct ephemeral container through a DEBUG-only launch switch; production has no reset/sample-data switches.

M2/M3: serialize active-session commands; idempotent command identifiers; persist set and cursor/rest state together; apply observable UI after successful commit. Cancellation is not rollback after a successful write. Separate game transactions consume committed workout facts. External effects use persisted outbox entries and retry, not awaited remote calls in a workout transaction.

## Planned modules

Workout/Schedule/Progression/Analytics are fitness domain services. RPGProgression/Quest/Reward/Achievement/Character/Inventory consume fitness facts. AssetManager and PerformanceManager own scene resources/adaptation. HealthKit, CloudKit, LiveActivity, Notification, Haptic and AppIntent adapters are optional. App extensions receive minimal read models through a protected App Group only when implemented.

## Security/scaling foot-guns

CloudKit sync is not a globally serial transaction boundary: a UUID alone cannot prevent two devices rewarding the same scheduled occurrence. Use deterministic occurrence keys and reconcile a ledger; keep this unresolved until sync is tested. Avoid full-history fetches and storing models/textures inside SwiftData. Device compromise can alter a local game ledger; V1 makes no competitive anti-cheat claim. No secrets, workout values or HealthKit samples in logs.

**Concepts used here:** Dependency injection passes services explicitly so tests can replace them. A repository hides storage details behind domain operations. A transaction commits related writes together. Idempotency makes a retry have the same effect as a single successful command.

## Platform references

- [Apple Xcode requirements](https://developer.apple.com/xcode/system-requirements)
- [Xcode 26 release notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-26-release-notes)
- [SwiftData VersionedSchema](https://developer.apple.com/documentation/swiftdata/versionedschema)
- [SwiftData SchemaMigrationPlan](https://developer.apple.com/documentation/swiftdata/schemamigrationplan)
