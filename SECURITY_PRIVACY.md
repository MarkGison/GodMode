# Security and privacy

One local owner; no required login, server, advertising, tracking or third-party analytics. Native app sandbox owns the local store. Do not log workout metrics, notes, body data, display name, HealthKit samples or identifiers. No secrets or signing credentials in Git. Original/licensed assets only; provenance required.

HealthKit (M13): explain and request only data needed for an enabled feature. Denial/partial authorization never gates training. Read denial cannot reliably be inferred from missing data; display no available data without claiming permission state. Save workouts only after local completion, using persisted export identifiers to prevent duplicate retries. Do not fabricate calories/heart rate. Review supported metadata and authorization APIs on implementation.

CloudKit: off in M1, opt-in private owner database planned. Local writes remain authoritative for UX; explicit pending/error status. Account changes, record conflicts, deletion propagation and ledger reconciliation need tests before enabling. Health data must not leak into public records or RPG diagnostics. Define export/delete behavior and retained reward tombstones with clear disclosure before release.

Notifications/Live Activities/widgets expose minimal exercise/rest metadata by default; provide privacy controls. App Groups use least scope. Photo Mode uses share sheet or explicit add-only permission. No permission descriptions until the related capability exists; add precise purpose strings with integration. Privacy manifest currently declares no tracking, collected data or required-reason API use; re-audit when features/API usage change.

Data protection must be tested while locked before choosing store protection attributes for Live Activities. Core logging runs foreground; extensions use sanitized read models. Never weaken protection just to animate a widget. Protect exports and backups; user confirmation for destructive reset. DEBUG-only launch switches cannot affect Release storage.

Foot-guns: a local ledger is tamperable and not a server anti-cheat system; distributed duplicate prevention is unresolved until sync; automatic database reset risks permanent loss and is forbidden. Mitigate retries locally with serialized transactions and stable operation keys. No security or performance certification is claimed by source inspection.
