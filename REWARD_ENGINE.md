# Reward ledger — M5/M9 planned

Workout save is authoritative and precedes reward processing. Persist a completion event/outbox entry with the session. A serialized use case reads eligibility and inserts RewardTransaction + inventory grants + event-consumed marker in one local transaction. Animation, HealthKit export and network retry cannot issue rewards.

Key = owner + stable scheduled occurrence + reward category + ruleset version. Session ID alone is insufficient: deleting/recreating a session must not reset occurrence eligibility. Keep reward tombstones on workout deletion. Editing a log updates fitness history; it does not reroll loot or multiply XP. Derived Hunter totals fold the ledger. Apply reconciliation corrections as compensating entries instead of rewriting history invisibly.

Eligibility: one base scheduled training reward per training day, prescribed work cap, unique quest occurrence, terminal eligible session. Additional voluntary logging remains available without farming rewards. Partial sessions never receive full-completion loot. Recovery grants have their own bounded objectives. Save accepted random outcomes once; retries return the same result. Use an injected RNG for deterministic tests, not UI time/frame count.

Loot tables are versioned, free, bounded and cosmetic; show rarity labels in addition to color. Duplicate cosmetics convert to defined Gold or another documented harmless policy; persist conversion atomically. No purchased randomized rewards. Post-completion UI can reopen results from the ledger after interruption.

Tests: repeated finish taps, concurrent commands, crash before/after each transaction boundary, delete/recreate session, edited history, daily cap, missing catalog item, duplicate grants, overflow, weighted table boundaries and deterministic outcomes. Backup import restores ledger identities and tombstones without replaying rewards. CloudKit reconciliation is a future-module gate outside V1; local transactions do not guarantee global once-only issuance across devices.
