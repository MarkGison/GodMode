# Data model and migration contract

## M1 persisted schema

`GodModeSchemaV1` version 1.0.0 contains `ProfileRecord`: stable local key, display name, createdAt and updatedAt. ProfileRepository exposes immutable `TrainingProfile` values. MainActor owns context access; save failure rolls back and leaves the input form intact. One local profile, deterministic key, fetch limited to two so accidental duplicates are reported rather than silently picked. No cloud entitlements. No personal information seeded.

Program catalog is versioned bundled JSON decoded into immutable `TrainingProgram`, `WorkoutDay`, `WorkoutBlock`, `ExercisePrescription`, `ExerciseDefinition`, and `Tempo`. IDs are stable strings. Validate unique IDs, references, positive targets, legal group sizes, unilateral sides, and load/target semantics before display. Catalog reload never overwrites a user's session; M2 copies prescriptions into session snapshots. Future editable programs live in SwiftData with source/version metadata.

## Planned normalized aggregates

| Aggregate | Records and relationships | Invariants |
| --- | --- | --- |
| User | UserProfile, UserPreferences, NotificationPreferences, GraphicsPreferences | One local owner; explicit preferences; no mandatory account |
| Program | TrainingProgram → WorkoutTemplate/WorkoutDay → ExercisePrescription; Exercise/ExerciseVariant | Stable IDs; revisions; owned edits separate from bundled source |
| Schedule | TrainingSchedule → scheduled occurrences | Occurrence UUID survives moving/skipping; time zone stored |
| Workout | WorkoutSession → ExerciseSession → SetRecord; RestPeriod | Atomic cursor/set/rest write; immutable prescription snapshot |
| Progression | ProgressionRule, Recommendation, PersonalRecord | Comparable exercise variant/load/tempo history; acceptance tracked |
| Metrics | BodyMetric | Explicit source, unit and timestamp; optional data |
| Hunter | Hunter, HunterStats, HunterRank, ExperienceState | Derived totals from ledger, no health diagnosis |
| Character | CharacterAppearance, CharacterLoadout, EquipmentSlot | Owned compatible items; missing asset fallback |
| Inventory | ItemDefinition, InventoryItem | Stable grant ID, source, acquired date, favorite and slot |
| Quests | Quest, QuestObjective, QuestProgress | Unique occurrence + objective; reward-once semantics |
| Rewards | RewardDefinition, RewardTransaction | Persisted deterministic transaction key; append-only grants |
| Achievements/skills | Achievement/Progress, SkillDefinition/Progress | Monotonic unlocks, versioned criteria |
| World | DungeonDefinition, BossDefinition | Cosmetic definitions reference assets; combat derived from sets |

SetRecord fields: ID, command ID, session/exercise/prescription IDs, ordinal, type, side, reps or duration, load and unit, load convention (per implement/total/bodyweight), implement count, RIR (nil or 0–4 where 4 means 4+), optional RPE, actual tempo phases, estimated TUT, prescribed/actual rest, completedAt, notes, editedAt, reward contribution reference, progression metadata. Keep estimates distinct from measured data.

## Migration and recovery

M1 supplies VersionedSchema + SchemaMigrationPlan with only V1, so no migration stage exists yet. A baseline disk-store reopening test is required; it is not a historical migration test. Before V2, freeze V1 types, retain a populated V1 fixture, add a real migration stage and assertions for every user field and relationship. No destructive reset on failure. Back up/export before any irreversible migration. Store URLs and encryption/protection behavior need device verification before release.

CloudKit-compatible future schema avoids relying on local unique constraints for distributed correctness; defaults/optional relationships and inverse relationships reviewed per Apple requirements. Synchronization remains off until conflict and migration tests pass. Histories page by time/ID (e.g. 50 rows); analytics aggregate incrementally. Raw HealthKit samples are minimized and never copied to public cloud records.

## Personal Edition durability

CloudKit is outside V1. All listed mutable aggregates, preferences and active-session state persist locally in SwiftData. Backup envelope version and database schema version are independent. `BACKUP_SYSTEM.md` defines export coverage, validation, integrity and atomic restoration. Every new persisted aggregate must be added to backup round-trip tests before its feature is complete. Preserve reward ledger/tombstones and session command IDs across imports; import must never replay completion or external export events.

Stable bundle identity is centralized in `Config/build.json`; data IDs and store keys must not use signing certificate identity. Normal same-container app updates use SwiftData migrations. Uninstall, changed identity, or installer container replacement can remove data; only an external backup makes recovery possible. Compatible active-session updates resume from absolute timestamps.
