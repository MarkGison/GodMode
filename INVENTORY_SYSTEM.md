# Inventory — M9 planned

ItemDefinition is immutable versioned content: stable ID, display name, slot/type, rarity, asset reference, rig compatibility and unlock description. InventoryItem is owned state: grant ID, definition ID, acquiredAt, source transaction, favorite, new-item acknowledgement. Locked catalog entries are distinct from owned items. Equipped state derives from loadouts so two conflicting sources cannot disagree.

Rarity: Common, Uncommon, Rare, Epic, Legendary, Mythic. Never communicate rarity only with color. Filter by rarity/type/owned/new/equipped; stable sorting by acquisition/name/rarity. Paginate large catalogs. Item detail shows source and ownership truthfully; enable Equip only for owned compatible items.

Equip validates ownership and slot compatibility then persists the loadout. Unequip falls back to base clothing. Inventory grant uniqueness uses reward transaction + grant ordinal. Duplicate handling is deterministic and transactionally linked to the ledger. Do not delete grants when source workout is removed. Corrupt cosmetic definitions cannot prevent workouts.

Loot reveal reads already-saved outcome; interruption and Skip preserve item ownership. Preview assets are reference-counted separately from active character instances. Tests cover filters, stable sorting, duplicate grants, missing catalog entries, equip conflicts, cancellation and restart.
