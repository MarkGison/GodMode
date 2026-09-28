# Workout engine contract — M2 implemented, native acceptance pending; M3 planned

Pure state transitions accept a command, current snapshot, and injected clock, then return validated state/events. Repository commits before presentation acknowledgement. State: ready → active ↔ paused → completed/partial/aborted. Terminal sessions cannot receive new sets; history corrections use an explicit edit operation. Exactly one active session per local owner. Resume uses stored snapshot, never a newly edited catalog.

Commands: start, beginSet, editDraft, completeSet, undoSet, skipSet, skipExercise, substitute, pause, resume, extendRest, skipRest, finishPartial, finish, abort, updateNotes, reconcileClock. Every mutating command carries an ID, session ID and expected revision; retry is safe. Undo marks/reverses the prior record with audit metadata and recalculates cursor; it does not create additional rewards. M3 must commit completion and cursor advancement in one save.

## Prescription structure

Blocks are straight/unilateral/superset/circuit/complex, with ordered exercise prescriptions. `rounds` supplies block repeats; each prescription has sets/target/tempo/rest/side tracking. M1 supports data representation; execution semantics arrive with tests in M2. A superset is A→B then round rest; a circuit completes all members before round rest. A complex is an ordered linked movement, not independent set credit for each submovement. Unilateral tracking stores left/right distinctly and advances only after both are completed or explicitly skipped. Timed work records seconds; AMRAP has no forced rep goal and stops at safe technique.

The supplied Push targets are preserved. Days 2–4 are editable seed assumptions. Draft loads require confirmation; heavy lateral raises/fly movements must permit lighter load or a regression. Substitutions retain original prescription and reason and must not suggest unsafe furniture anchors.

## Rest and tempo

Persist start instant, deadline, prescribed seconds, accumulated pause and paused remaining. Remaining = max(0, deadline − now); +15 extends deadline, paused extension adds to remaining. Pause captures remaining; resume writes a new deadline. Refresh ticks only render time. Handle significant system clock changes by detecting discontinuity, preserving records and offering correction; never mint rewards from elapsed time. Rest begins from committed set completion even if optional animation fails. Actual rest is measured to next set start, not set finish.

Tempo phases lower/hold/lift derive from an absolute phase start; no background audio/timer promises beyond OS support. Coaching optional; prescription remains visible. Estimated TUT = reps × phase sum only for comparable full reps and explicitly labeled an estimate.

## Validation/acceptance

Reject negative/nonfinite load, impossible ordinals, conflicting reuse of command IDs, unknown IDs, invalid RIR/RPE, reps for timed-only entries and duration for rep-only records. An exact command retry returns current state with no new events, even after completion or undo. Missing optional RIR is valid. M3 adds draft autosave plus immediate persistence on primary actions; save failures keep input and prevent false completion. Tests cover transitions, group order, each side, repeats, skip/undo/substitute and clock shifts. Termination, disk draft restoration and storage failures are M3 gates. No workout UI may claim durability before M3 restoration tests pass.

## M2 public domain boundary

`WorkoutEngine.prepare(id:program:dayID:at:)` validates and copies the catalog, then creates a ready session with a stable ordered step plan. `apply(command:to:at:)` returns a proposed immutable-to-callers `WorkoutTransition` with state, events and retry disposition. The caller owns UUIDs and supplies wall time plus monotonic uptime. No service login, network, UIKit, SwiftData or timer scheduler is needed. The existing app remains a catalog viewer until M3.

| Operation | Preconditions and effect |
| --- | --- |
| Start / begin set | Start only a ready session; begin only the current unresolved step in active state. Begin closes actual rest, even if its countdown has not expired. Starting early records the true rest rather than falsifying it. |
| Draft / complete | Drafts may be incomplete; completion requires beginSet, explicit load convention and reps or duration. Invalid input leaves the original state untouched. |
| Skip | Requires a nonblank reason; skipExercise resolves only remaining steps of the current prescription, including its later group rounds. Skips earn no completed-set event and start no new recovery countdown; existing rest continues until the next beginSet. |
| Undo | Reverses the most recent completion/skip batch, retains an audit record, restores cursor and input. Available until new work/draft, substitution, pause or clock reconciliation; terminal history edits are future scope. Time spent between completion and undo is excluded from the restored active-set duration. |
| Substitute | Before any result, active set or draft for the current prescription; replacement must exist in the copied catalog. Original prescription, original exercise and reason remain available. This is explicit user choice, not an automatic exercise recommendation. |
| Finish | Full completion requires every planned step completed; skipped work requires partial completion. Partial requires at least one completed set. Abort preserves existing records/draft without completion credit. |
| Reconcile clock | Explicit acknowledgement after clock discontinuity/reboot. Preserve elapsed and remaining time at the last accepted command; exclude the unknowable gap and anchor future timing to the new sample. No work/reward is inferred from the jump. |

Grouped prescriptions execute one set per member per round, with left/right pairs adjacent. Only the final side/member receives prescribed round rest. A zero-second inter-member rest still records the real interval until the next set begins. Complexes are single linked-movement prescriptions and generate one set result per set. Final-step completion creates no unnecessary rest. Tempo cues are read-only lower/hold/lift phases; zero-length phases are skipped. Estimated TUT requires explicitly comparable full reps and an actual recorded tempo; it is never measured TUT or a rep counter.

Canonical loads use kilograms with explicit per-implement/count, total external or bodyweight-added convention. RIR is nil or 0–4 (4 means 4+); RPE is nil or finite 1–10. Actual reps may fall below or exceed target (0–1000); timed work is 1–3600 seconds. Missing pain information remains unknown. Draft/notes cap at 2000 characters, reasons at 500, expanded plans at 512 steps, and command receipts at 4096 ordinary mutations plus one terminal command. Never evict retry history mid-session; M3 must debounce drafts and surface capacity errors with a safe partial-finish/abort path. A terminal command still uses a valid clock sample. No reward engine is implemented in M2.

`WorkoutSession` deliberately has no synthesized Codable conformance. M3 will define validated storage DTOs and V1→V2 migration, commit state and command receipts atomically, enforce one active session per local owner, and publish domain events only after save. Codable commands are available for that adapter; command serialization alone is not session restoration evidence.

Personal Edition adds compatible app-update restoration and backup coverage of active workout/draft/cursor/rest state. Import serializes against logging and requires ending or explicitly preserving an active session before replacement. Neither personal-signing expiry nor missing optional entitlements changes the workout state machine. Timer deadlines remain absolute after update or import; stale notifications/Live Activities are rebuilt only after committed recovery.
