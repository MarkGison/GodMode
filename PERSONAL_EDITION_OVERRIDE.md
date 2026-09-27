# GODMODE — PROJECT UPDATE / OVERRIDE

Update the existing GodMode project requirements with the following constraints.

These instructions **override any conflicting distribution, deployment, build-environment, App Store, TestFlight, or cloud-Mac assumptions in the existing project documentation**.

Do not discard the existing GodMode product requirements, workout systems, RPG systems, 3D systems, UI/UX direction, testing requirements, or architecture unless specifically changed below.

---

# 1. OWNER DEVELOPMENT ENVIRONMENT

The project owner has:

- a Windows PC
- an iPhone
- no physical Mac
- no paid remote/cloud Mac
- no intention to publish GodMode to the App Store at this stage
- no intention to use TestFlight at this stage
- no paid Apple Developer Program membership at this stage

Development should therefore assume:

Windows  
→ Codex  
→ Git repository  
→ automated macOS CI when available  
→ `.ipa` artifact  
→ personal sideload installation on the owner's iPhone

Do not tell the project owner to:

- open Xcode locally
- connect an iPhone to a Mac
- use a local macOS machine
- buy a cloud Mac
- publish to the App Store
- use TestFlight

unless a later requirement explicitly changes these constraints.

---

# 2. DISTRIBUTION TARGET

GodMode is currently:

**GodMode Personal Edition**

Distribution model:

**private personal sideloading**

The desired deliverable is:

`GodMode.ipa`

The app is intended for installation on the project owner's personal iPhone.

There is no App Store production requirement.

There is no public distribution requirement.

There is no TestFlight requirement.

---

# 3. DO NOT IMPLEMENT SECURITY BYPASSES

Do not:

- bypass iOS code signing
- bypass provisioning restrictions
- exploit iOS vulnerabilities
- jailbreak the device
- disable platform security
- attempt unsupported certificate tricks
- patch iOS security mechanisms
- create persistence mechanisms intended to defeat Apple's signing rules

Use legitimate personal-development/sideloading mechanisms only.

The application must remain compatible with standard iOS security expectations.

---

# 4. FREE APPLE ACCOUNT ASSUMPTION

Assume the owner may initially use a free Apple developer/personal signing workflow.

Therefore:

- signed builds may require periodic re-signing
- provisioning may expire
- the application must preserve user data across normal re-signing and reinstall/update workflows where iOS preserves the application container
- the application must include robust export/import backup support

Do not make application data dependent on:

- signing certificate identity
- provisioning profile lifetime
- cloud authentication

---

# 5. INSTALLATION TARGET

Structure the project so the intended personal deployment path can be:

Windows PC  
→ downloadable `GodMode.ipa`  
→ compatible personal sideload installer  
→ iPhone

Do not tightly couple the project to one particular third-party sideloading tool.

Instead, produce a standards-compliant `.ipa` whenever the build/signing environment supports it.

---

# 6. BUILD ARCHITECTURE

The project must support automated macOS CI builds.

The repository should be capable of being cloned on a macOS CI runner and built without manual project repair.

Required properties:

- reproducible build configuration
- deterministic dependency setup
- documented Xcode version expectations
- no local absolute paths
- no machine-specific assumptions
- no manually installed proprietary dependencies
- no required secrets committed to Git
- scripts must work from repository root
- build failures must produce useful logs

---

# 7. CI STRATEGY

Because macOS CI minutes may be limited, use them efficiently.

Do NOT trigger expensive macOS builds for every tiny documentation or cosmetic code change.

Prefer:

1. group related changes
2. perform static reasoning/review
3. run inexpensive tests where possible
4. trigger macOS build at meaningful checkpoints
5. inspect build output
6. fix failures
7. rebuild only when necessary

Create CI workflows for:

- compile validation
- unit testing
- UI smoke testing where practical
- archive validation where signing allows it
- artifact generation where possible

---

# 8. UNSIGNED VS SIGNED BUILDS

Separate these concepts clearly.

The project should support:

## CI validation build

Used to verify:

- Swift compilation
- architecture
- tests
- resources
- RealityKit assets
- SwiftData models

This may not necessarily produce an installable signed `.ipa`.

## Personal install build

Used when valid signing credentials/provisioning are supplied.

Produces:

`GodMode.ipa`

Do not treat lack of signing credentials as a source-code failure.

Report signing failures separately from compilation failures.

---

# 9. BUILD OUTPUTS

When practical, CI should produce downloadable artifacts such as:

- build logs
- test results
- coverage reports
- diagnostic logs
- `.xcarchive` when possible
- `.ipa` when valid signing configuration is available

Use clear artifact naming.

Examples:

`GodMode-v0.1.0-build.ipa`

`GodMode-v0.2.0-build.ipa`

`GodMode-ci-logs.zip`

`GodMode-test-results.zip`

---

# 10. LOCAL-FIRST DATA STORAGE

GodMode must remain fully functional without internet access.

Primary persistence:

**SwiftData**

Store locally:

- workouts
- workout history
- active workout state
- exercises
- progression state
- Hunter
- XP
- levels
- ranks
- Gold
- equipment
- inventory
- quests
- achievements
- settings
- personal records
- body metrics
- graphics preferences

Do not require CloudKit for core functionality.

---

# 11. CLOUDKIT STATUS

CloudKit/iCloud synchronization is no longer a V1 requirement.

Keep cloud synchronization behind an abstraction so it may be added later.

Architecture should allow:

`LocalRepository`

and later:

`CloudSyncService`

GodMode must not malfunction if CloudKit is completely absent.

---

# 12. HEALTHKIT STATUS

HealthKit should remain optional and modular.

If entitlement/signing restrictions prevent HealthKit from functioning in a particular personal build:

GodMode must still work.

Provide manual alternatives where appropriate.

Example:

If HealthKit body weight access is unavailable:

allow manual body-weight entry.

If workout synchronization is unavailable:

local GodMode workout history remains authoritative.

Do not remove HealthKit architecture entirely.

Keep it behind capability checks.

---

# 13. CAPABILITY DETECTION

Create a centralized system capability layer.

Conceptually:

`SystemCapabilities`

It should determine availability of features such as:

- HealthKit
- notifications
- Live Activities
- App Intents
- widgets
- iCloud
- advanced system integrations

UI must gracefully adapt.

Never crash because an entitlement/capability is unavailable.

Example:

If HealthKit is unavailable:

hide or disable Health sync controls with a clear explanation.

Do not break the workout experience.

---

# 14. CORE FEATURES MUST NOT DEPEND ON ENTITLEMENTS

The following must work independently:

- 4-day workout program
- workout logging
- RIR
- tempo
- automatic rest
- supersets
- circuits
- unilateral exercises
- session recovery
- progression engine
- XP
- levels
- Hunter ranks
- quests
- dungeons
- bosses
- achievements
- inventory
- cosmetic equipment
- 3D Hunter
- 3D character customization
- loot
- skill tree
- progress analytics
- calendar
- personal records
- offline history
- graphics controls
- local backup/import

These are the core of GodMode Personal Edition.

---

# 15. BACKUP SYSTEM — HIGH PRIORITY

Add a first-class GodMode backup system.

Settings should include:

**DATA MANAGEMENT**

- Export GodMode Backup
- Import GodMode Backup
- Backup Information
- Reset Local Data

Backup must preserve:

- UserProfile
- Hunter
- XP
- rank
- Gold
- inventory
- equipment
- character customization
- achievements
- quest progression
- workouts
- exercise history
- PRs
- progression state
- body metrics
- schedules
- settings

Use a versioned backup schema.

Suggested extension:

`.godmode`

Example:

`GodModeBackup-2026-09-27.godmode`

The backup format must support future migrations.

---

# 16. BACKUP INTEGRITY

Backups should contain:

- format version
- creation date
- application version
- schema version
- integrity metadata

Before import:

1. validate file
2. validate schema
3. verify supported version
4. create safety snapshot of existing data
5. perform migration if required
6. import transactionally
7. roll back if failure occurs

Never partially overwrite the user's data.

---

# 17. UPGRADE SAFETY

Future GodMode `.ipa` versions must use a stable bundle identifier.

Do not casually change the bundle identifier.

Plan SwiftData schema migrations from the beginning.

Upgrading:

GodMode v0.5  
→ GodMode v0.6

must preserve:

- Hunter
- inventory
- XP
- workout history
- achievements
- settings

Database destruction is unacceptable.

---

# 18. ACTIVE WORKOUT SAFETY

Persist active workout state aggressively enough that interruptions do not destroy progress.

Support recovery after:

- app termination
- iPhone lock
- backgrounding
- crash
- forced restart of the UI
- application update where compatible

Use absolute timestamps for timers.

---

# 19. GODMODE 3D REQUIREMENTS REMAIN

Do not downgrade the 3D requirements because distribution is personal.

GodMode still requires:

- real-time 3D Hunter
- RealityKit
- original dark supernatural presentation
- 3D equipment
- 3D wardrobe
- character customization
- 3D loot preview
- boss presentation
- dungeon scenes
- level-up presentation
- rank-up presentation
- optimized effects
- stable frame pacing
- adaptive graphics
- thermal awareness

The personal distribution method should not reduce visual ambition.

---

# 20. PERFORMANCE TARGET

Maintain:

**60 FPS target during normal interactive 3D scenes**

Allow adaptive quality.

Priority:

1. workout reliability
2. UI responsiveness
3. frame stability
4. memory stability
5. thermal stability
6. battery efficiency
7. graphics quality

Do not chase visual quality at the expense of application stability.

---

# 21. PERSONAL EDITION SETTINGS

Add a Settings section such as:

**GODMODE PERSONAL EDITION**

Information may include:

- App Version
- Build Number
- Data Schema Version
- Export Backup
- Import Backup
- Graphics Mode
- System Capabilities
- Developer Information
- Diagnostics

Do not expose signing credentials.

---

# 22. DIAGNOSTICS

Because the owner cannot use local Xcode, create strong diagnostics.

Development/debug builds should support exporting:

- app version
- build number
- device model
- iOS version
- graphics mode
- recent application logs
- active workout state metadata
- database schema version
- asset loading failures
- capability state

Provide a:

**Export Diagnostics**

function where practical.

Never export unnecessary private health/workout information without explicit user action.

---

# 23. ERROR REPORTING

Use structured internal error logging.

Examples:

- persistence
- 3D asset loading
- reward calculation
- workout restoration
- migration
- backup
- HealthKit
- notifications
- Live Activities

Production UI should provide understandable messages.

Debug builds may expose more detail.

---

# 24. PERSONAL DISTRIBUTION DOCUMENTATION

Create:

`PERSONAL_INSTALLATION.md`

Document:

- supported distribution model
- CI build process
- how `.ipa` artifacts are generated
- signing requirements
- personal sideload assumptions
- update procedure
- backup-before-update recommendation
- common installation errors
- troubleshooting

Do NOT document exploits or security bypasses.

---

# 25. WINDOWS DEVELOPMENT DOCUMENTATION

Create:

`WINDOWS_DEVELOPMENT.md`

Explain:

- repository workflow
- Codex workflow
- Git commands where useful
- how CI is triggered
- where artifacts are downloaded
- how test failures are inspected
- how build failures are reported
- what tasks require macOS CI
- what can be edited from Windows

The project owner should not need local Xcode knowledge for routine Codex-driven development.

---

# 26. CODEX WORKFLOW UPDATE

For every significant task:

1. Read `AGENTS.md`.
2. Read relevant specification files.
3. Inspect current implementation.
4. Plan the change.
5. Implement the smallest coherent change.
6. Add/update tests.
7. Perform local/static checks available in the environment.
8. Commit related changes logically.
9. Trigger macOS CI only when appropriate.
10. Inspect CI result.
11. Fix compilation/test failures.
12. Update documentation if behavior changed.

Do not assume that code is valid merely because it looks correct.

macOS CI is the authoritative compilation environment.

---

# 27. DO NOT BLOCK DEVELOPMENT ON SIGNING

Signing must be treated as a deployment concern.

Continue building/testing source code even if signing credentials have not yet been configured.

Maintain these independent states:

Compilation:
PASS / FAIL

Tests:
PASS / FAIL

Archive:
PASS / FAIL / NOT CONFIGURED

Signing:
PASS / FAIL / NOT CONFIGURED

IPA:
GENERATED / NOT GENERATED

This distinction must be visible in CI output/documentation.

---

# 28. MOCK / PLACEHOLDER 3D ASSETS

If final custom character or environment artwork does not yet exist:

use legal placeholder/development assets.

Do not block application architecture.

All asset systems should support later replacement of:

- Hunter
- clothing
- armor
- weapons
- bosses
- environments
- animations
- effects

without rewriting workout/game logic.

---

# 29. FUTURE PAID DEVELOPER MODE

Architect so that if the owner later joins the Apple Developer Program, GodMode can enable additional capabilities without architectural rewrite.

Potential future modules:

- full HealthKit support
- iCloud/CloudKit
- richer Live Activities
- additional App Intents
- extended widgets
- Apple Watch
- TestFlight
- App Store distribution

Do not require them now.

---

# 30. V1 PERSONAL EDITION PRIORITY

Prioritize V1 in this order:

1. Core project architecture
2. Local data reliability
3. 4-day workout engine
4. Workout state restoration
5. Progression engine
6. GodMode design system
7. XP / levels / ranks
8. Quest system
9. Character system
10. Inventory and items
11. 3D Hunter
12. Character customization
13. Dungeons and bosses
14. Loot/rewards
15. Skill tree
16. Analytics
17. Personal Records
18. Backup/import
19. Diagnostics
20. Optional iOS system capabilities
21. visual polish
22. performance hardening
23. `.ipa` deployment pipeline

---

# 31. MODIFIED DEFINITION OF DONE

GodMode Personal Edition V1 is considered technically ready when:

- macOS CI compilation succeeds
- unit tests pass
- core workout tests pass
- state restoration tests pass
- progression tests pass
- RPG reward tests pass
- SwiftData migration tests pass
- backup/export/import tests pass
- RealityKit scenes fail gracefully if assets are missing
- common 3D scenes meet performance targets on supported hardware
- no core workout functionality requires internet
- unavailable Apple capabilities do not crash the app
- diagnostics exist
- documentation exists
- valid `.ipa` can be produced once legitimate signing configuration is supplied

App Store publication is explicitly NOT part of the definition of done.

---

# 32. PROJECT IDENTITY

The application remains:

**GODMODE**

A premium native iPhone fitness RPG where:

**real training drives character progression.**

The application remains:

- native
- 3D
- offline-first
- fitness-first
- RPG-driven
- smooth
- cinematic
- reliable
- private
- personal

Do not turn it into a website or PWA merely because development occurs on Windows.

---

# 33. IMMEDIATE ACTION

Apply this update to the current repository.

First:

1. Read existing `AGENTS.md`.
2. Read all GodMode project specifications.
3. Identify every requirement conflicting with this update.
4. Update those documents.
5. Add `PERSONAL_INSTALLATION.md`.
6. Add `WINDOWS_DEVELOPMENT.md`.
7. Update architecture diagrams as necessary.
8. Update CI strategy.
9. Remove App Store/TestFlight as V1 requirements.
10. Make CloudKit optional rather than mandatory.
11. Add backup/import as a V1 requirement.
12. Add diagnostics/export as a V1 requirement.
13. Keep HealthKit and advanced Apple integrations modular.
14. Preserve all existing workout, RPG, UI/UX, RealityKit, performance, testing, accessibility, and safety requirements that do not conflict with this update.

After specifications are updated, continue from the current development milestone rather than restarting the project unnecessarily.

Do not delete valid completed work.

Refactor only where required to satisfy the updated architecture.

At the end, report:

- specifications changed
- architecture changes
- features moved out of V1
- newly added V1 requirements
- CI changes
- signing/build assumptions
- current next milestone

Then continue implementation according to the updated GodMode Personal Edition plan.