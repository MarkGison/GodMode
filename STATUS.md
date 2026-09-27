# Delivery status

Updated 2026-09-27. Authoring host: Windows; Swift and Xcode unavailable.

- Milestone 0: specification foundation authored and reviewed. Master brief preserved verbatim in `MASTER_BRIEF.md`.
- Milestone 1: implementation in progress; Apple build/test/render acceptance is pending. Do not mark complete or advance to M2 until the gate runs successfully on a Mac.
- Milestones 2–19: planned, not implemented. No working workout tracker, 3D character, cloud/HealthKit integration or release build is claimed.

## Decisions recorded

Local owner, no server/account, local repository pattern, bundled validated catalog, versioned SwiftData profile foundation, Swift 6, iOS 26, original assets only. Strict progression ladder supersedes permissive example. Undefined Day 2–4 prescriptions are reviewable seed assumptions. M1 exposes actual catalog and profile behavior only.

## Next gate

On a Mac with Xcode 26 and an installed iOS 26 simulator, run `tools/check-macos.sh`. Fix compilation/test failures and inspect small/large iPhone + accessibility type. Record xcresult and audit evidence, then complete M1 and start M2. See `TEST_PLAN.md` and `RELEASE_CHECKLIST.md`.
