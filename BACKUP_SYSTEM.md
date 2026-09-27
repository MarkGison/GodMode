# GodMode backup contract — required in V1, implementation at M3A

## User flow

Settings → DATA MANAGEMENT → Export GodMode Backup / Import GodMode Backup / Backup Information / Reset Local Data. Export writes a consistent snapshot to an app temporary file then offers the native document exporter/share sheet. Save it outside the app container. Cancel does not delete data. Backup Information shows format/schema/app version, creation date, included categories and last successful export. Import previews metadata/counts, explains replacement, and requests confirmation. Reset requires confirmation and a successful safety export before deleting records; keep safety backups outside the data being reset.

## Format

Extension `.godmode`, suggested filename `GodModeBackup-YYYY-MM-DD.godmode`. Single bounded JSON envelope: formatVersion, createdAt (UTC ISO 8601), appVersion, buildNumber, dataSchemaVersion, payloadEncoding, payloadByteCount, payloadSHA256, payload (base64 exact UTF-8 JSON bytes). Hash the exact decoded bytes to avoid JSON reserialization ambiguity. SHA-256 via CryptoKit detects corruption, not authenticity. Initial backup is not encrypted and the UI must say it contains personal data. No device ID, signing certificate, Apple account, provisioning profile, keychain secrets or HealthKit authorization tokens.

Payload has stable domain IDs, explicit units/dates and aggregate versions. Include profile/preferences, Hunter/XP/rank/Gold/stats, inventory/grants/loadouts/appearance, achievements/skills, quests/objectives/reward ledger/tombstones, programs/exercises/variants/prescriptions, workout sessions/exercise sessions/sets/rest/drafts/notes, PRs/progression, body metrics, schedules/time zones and settings/graphics preferences. Catalog content IDs/revisions must resolve after restoration; include user edits and needed prescription snapshots. Exclude bundled meshes/textures; record referenced asset definition IDs. Only already implemented models are initially exported, with a coverage manifest; never pretend a profile-only export is a complete workout backup.

## Atomic import

1. Acquire security-scoped access; enforce initial 64 MiB envelope and 32 MiB decoded payload bounds before allocation-heavy work. Version these limits and revisit using measured histories.
2. Decode and validate envelope fields, supported format/schema, byte count and digest.
3. Decode payload into value types; validate finite numbers, bounded counts/strings, unique IDs, references, unit/date semantics and active-session invariants.
4. Apply pure sequential backup migrations in memory; reject unknown newer versions without touching storage.
5. Pause mutation use cases and produce a verified safety snapshot of existing data. If snapshot creation fails, stop import.
6. Replace current records inside one SwiftData transaction/save boundary. Preserve existing context on failure with rollback; do not batch partial commits or swap a live SQLite/WAL file.
7. Reload presentation only after commit; rebuild optional timers/system surfaces from restored facts. Do not replay rewards or HealthKit exports. Cancellation before commit has no effect; after commit reports success accurately.

For histories too large for a bounded transaction, stop and design/test a staged-store migration before increasing limits. Default is replace, not merge. Merge requires a future explicit conflict policy.

## Options and why this approach

| Pattern | Fit | Tradeoff |
| --- | --- | --- |
| Repository snapshot + versioned Codable envelope | Chosen: portable owner-controlled export/import of related aggregates | Explicit validation/migrations and transactional import required; no server cost |
| Raw SQLite file copy | Simpler for a stopped development database only | Live WAL coherence and SwiftData version coupling make it unsuitable for user backups |
| Cloud synchronization | Future convenience across devices | Requires capabilities/account/conflict logic and is not a substitute for an independent backup |

**Why this approach:** the local repository snapshot pattern preserves relationships without binding data to a certificate or OS database implementation. `BackupService.export()` returns a file only after snapshot verification; `import(validatedSnapshot)` returns only after commit. The device owner initiates both actions through native document access.

**Simpler alternative:** raw JSON profile export suffices only while profile is the sole persisted aggregate. Every introduced model must join the coverage manifest and tests before completion.

Security/scaling foot-guns: backups reveal personal data, hashes are not signatures, malicious large files can exhaust memory, and partial writes can destroy histories. Mitigate with explicit export, bounded parsing, reference validation, safety snapshots and one transaction. Do not guarantee survival of uninstall or changed signing identity.

**Concepts used here:** A snapshot is a consistent copy of related data at one point in time. Integrity checking detects changed/corrupt bytes. A migration translates an older format into the current one. Atomic replacement either commits the whole import or preserves the prior state.
