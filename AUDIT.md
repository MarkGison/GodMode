# Foundation second-pass audit — 2026-09-27

Scope: M0 specifications and M1 source. Initial method: source review, project-reference/seed/plist/XML validation, Python syntax compilation and Git whitespace inspection on Windows. Native evidence was added on 2026-09-28 below.

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

1. Native sources, generated project, boundary-device layout and contrast passed acceptance in checkpoint 36354396835. M2 may proceed.
2. SwiftData reopen, save failure and presentation tests passed. No historical schema migration has been exercised; V2 must retain and test V1 fixtures.
3. No real-device timing, thermal, energy, memory or render claims are supported. No RealityKit code/assets are included in M1.
4. Day 2–4 seed prescriptions need program review before release. Catalog notes are not a full exercise coaching library yet.
5. CloudKit is future scope outside V1. Optional HealthKit permissions/export and other system surfaces remain planned. Local transactions alone will not ensure future cross-device reward uniqueness.
6. Corrected low-contrast filled-button text and the name-field prompt using semantic tokens. Final small/large screenshots were inspected, including largest-text primary actions above the keyboard; physical VoiceOver remains unverified.
7. Superseded by Personal Edition override: bundle identity is now frozen in Config/build.json. App icon, personal signing, capability checks and privacy re-audit remain pending; TestFlight and App Store are outside current scope.

M0 and M1 source acceptance are complete. Later milestones and physical-device V1 acceptance remain open.

## Personal Edition override audit

Reviewed all project specifications against the preserved override. Updated deployment assumptions, stable identity, build/signing separation, future CloudKit scope, optional capability behavior, backup/import and diagnostics gates. Kept workout/program, progression/RPG, accessibility and original RealityKit scope. Foundation UI now exposes a capability status/settings surface; no unimplemented backup/export actions are presented as working.

Changed macOS CI from automatic push builds to manual checkpoints with cheap Ubuntu preflight. Pinned Xcode/runtime rather than silently choosing a runner default. Added actual device-archive/unsigned-package path and optional standard signed export. Python tests validate reporting/packaging/provisioning input boundaries; they do not prove Apple compilation, code signing or device install. Valid signing configuration has not been supplied.

Security review: unsigned packages cannot be labeled installable; simulator payloads are rejected; signed export requires matching unexpired device profile and valid identity; no security bypasses. Export keys/profiles are temporary, protected-environment secrets; no raw signing command output or secrets in artifacts. Signed IPA necessarily contains its embedded public provisioning profile. Backup hashes detect corruption, not authenticity. Profiles/data never derive identity from certificate lifetime.

First full native checkpoint 36323283081 passed: 17 core tests, 7 app persistence/presentation tests and 3 UI tests; default iPhone 17 Pro and accessibility-text screenshots inspected. No Swift source compiler warnings were found. Xcode emitted tool notices for AppIntents metadata without that framework and stripping signed XCTest libraries. Explicit simulator architecture now removes the avoidable ambiguous-destination notice.

Boundary-test investigation: runs 36353009206, 36353552448 and 36353997890 compiled successfully but failed the new maximum-text Continue visibility assertion. Screenshots and synthesized-event logs showed broad scroll-view queries selecting the keyboard suggestion strip (a 44-point-high area), rather than the page. The correction gives Page a stable `page.content` identifier and bounds test gestures above the keyboard. Interactive keyboard dismissal remains native. The test continues to require a hittable Continue button and successful profile completion; it is not skipped or relaxed. Owner confirmed iPhone 16 / iOS 26, matching the deployment minimum.

Final checkpoint 36354396835 at source 418e09e passed: 17 core + 7 app + 7 UI executions, Debug/Release compilation and device archive. Windows package verification confirmed version 0.1.0 (1), stable bundle ID, iPhoneOS platform and minimum OS 26.0. Inspected final SE/Pro Max default, maximum-text, program and settings screenshots. No clipped primary action or unreadable prompt remains in those inspected states. Unsigned IPA is generated; standard signed export and physical-device install remain unverified.

Remaining: implement M2 and later milestones, test complete backup/diagnostics at their gates, verify personal installer compatibility and compatible updates on the owner's iPhone. The temporary automatic approval-review usage limit cleared; normal authenticated upload succeeded without an alternate channel.

## M2 candidate source audit — 2026-09-28

- Pure Foundation command/state reducer preserves the original value on error; no persistence/UI side effects before commit.
- Validated immutable program snapshot and unique step keys preserve group/side/round order. Explicit beginSet closes actual rest before set work starts.
- Session ID + revision guard stale/foreign commands; retained exact command receipts make retries effect-free after completion/undo. Conflicting ID reuse is rejected.
- Partial drafts survive rejected input and pause/abort; full completion rejects skipped work. Undo retains reversed records and excludes intervening rest from active-set duration.
- Canonical explicit load convention, bounded finite inputs, unknown pain/RIR retained; estimates are labeled and cannot generate work.
- Absolute deadline, pause/extension and wall-versus-monotonic discontinuity checks avoid tick-dependent timing. Clock reconciliation conservatively freezes the unknown interval.
- Capacity errors preserve state and receipts; one terminal command remains allowed at the ordinary journal limit. M3 must debounce draft writes and provide actionable errors.
- No synthesized session decoder or changed V1 SwiftData schema. Validated DTO restoration, atomic persistence/receipt commit, one active session, crash recovery and post-commit event delivery remain M3 responsibilities; rewards remain M5.
- Tests and source reviewed; 374 structural checks and 14 Python tests passed. Swift compilation/native tests remain pending until the M2 checkpoint succeeds. Existing M1 render evidence applies because no UI layout changed.
