# Foundation second-pass audit — 2026-09-27

Scope: M0 specifications and M1 source. Method: source review, project-reference/seed/plist/XML validation, Python syntax compilation and Git whitespace inspection on Windows. This is not compiler, device or accessibility execution evidence.

## Findings addressed

- **Persistence acknowledgement:** repository saves explicitly before updating the observable profile. Failed writes roll back context changes and retain entered text; startup never replaces a failed persistent store with memory.
- **False product states:** no fabricated workout metrics, rewards or active Start action. Tabs for later milestones explain their status. M1 program is not mislabeled as a scheduled quest.
- **Load assumptions:** all draft loads are nil until user confirmation. Available 10 kg equipment is not silently imposed on lateral raises, fly movements or other exercises.
- **Progression contradiction:** all-set upper-target criterion documented as authoritative over the permissive example. No progression code added ahead of its gate.
- **Catalog invariants:** IDs/references, group cardinality, rounds, set/target/side/tempo/load validity checked before rendering. Added bounded round-rest validation and a regression test source during audit.
- **Accessibility testing:** combined exercise rows now expose a stable row identifier; UI smoke test uses that identifier instead of relying on hidden child text. Primary actions use native large control sizing. Actual assistive-technology behavior remains unverified.
- **Test isolation:** DEBUG-only UI-test argument uses an in-memory container; Release has no storage-reset switch. Persistence tests use unique temporary stores.
- **Architecture:** no SwiftUI/SwiftData/RealityKit imports in domain; profile context is MainActor isolated; catalog reads use an actor; no production force casts, forced tries or fatalError constructs found by structural check.
- **Project membership:** all current app and test Swift files/resources are referenced; all PBX object and scheme references resolve structurally. Repeated generation produces the same project files.

## Remaining gates and risks

1. Native sources and generated project have not been accepted by Xcode. Compile/concurrency/API or test errors may remain. Run the documented Mac gate before adding M2.
2. SwiftData reopen, save failure and presentation tests are authored but unrun. No historical schema migration has been exercised; V2 must retain and test V1 fixtures.
3. No real-device timing, thermal, energy, memory or render claims are supported. No RealityKit code/assets are included in M1.
4. Day 2–4 seed prescriptions need program review before release. Catalog notes are not a full exercise coaching library yet.
5. CloudKit distributed reward reconciliation, HealthKit permissions/export and all external system surfaces remain planned. Local transactions alone will not ensure cross-device reward uniqueness.
6. UI is foundation styling; small/large layouts, contrast and VoiceOver need rendered inspection. English catalog extraction should be reviewed after the first Xcode build.
7. Superseded by Personal Edition override: bundle identity is now frozen in Config/build.json. App icon, personal signing, capability checks and privacy re-audit remain pending; TestFlight and App Store are outside current scope.

No milestone beyond M0 is certified complete. Source work is saved so automated macOS CI can reproduce and finish the next gate from the Windows workflow.

## Personal Edition override audit

Reviewed all project specifications against the preserved override. Updated deployment assumptions, stable identity, build/signing separation, future CloudKit scope, optional capability behavior, backup/import and diagnostics gates. Kept workout/program, progression/RPG, accessibility and original RealityKit scope. Foundation UI now exposes a capability status/settings surface; no unimplemented backup/export actions are presented as working.

Changed macOS CI from automatic push builds to manual checkpoints with cheap Ubuntu preflight. Pinned Xcode/runtime rather than silently choosing a runner default. Added actual device-archive/unsigned-package path and optional standard signed export. Python tests validate reporting/packaging/provisioning input boundaries; they do not prove Apple compilation, code signing or device install. Valid signing configuration has not been supplied.

Security review: unsigned packages cannot be labeled installable; simulator payloads are rejected; signed export requires matching unexpired device profile and valid identity; no security bypasses. Export keys/profiles are temporary, protected-environment secrets; no raw signing command output or secrets in artifacts. Signed IPA necessarily contains its embedded public provisioning profile. Backup hashes detect corruption, not authenticity. Profiles/data never derive identity from certificate lifetime.

Remaining: execute full native CI, inspect exported screenshots, implement and test complete backup/diagnostics at their gates, verify personal installer compatibility and compatible updates on the owner's iPhone. Network upload was interrupted by automatic approval review's usage-limit failure; no workaround upload was attempted.
