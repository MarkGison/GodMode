# Workout engine contract — M2/M3 planned

Pure state transitions accept a command, current snapshot, and injected clock, then return validated state/events. Repository commits before presentation acknowledgement. State: ready → active ↔ paused → completed/partial/aborted. Terminal sessions cannot receive new sets; history corrections use an explicit edit operation. Exactly one active session per local owner. Resume uses stored snapshot, never a newly edited catalog.

Commands: start, editDraft, completeSet, undoSet, skipSet, skipExercise, substitute, pause, resume, extendRest, skipRest, finishPartial, finish, abort, updateNotes. Every mutating command carries an ID; retry is safe. Undo marks/reverses the prior record with audit metadata and recalculates cursor; it does not create additional rewards. Completion and cursor advancement are one save.

## Prescription structure

Blocks are straight/unilateral/superset/circuit/complex, with ordered exercise prescriptions. `rounds` supplies block repeats; each prescription has sets/target/tempo/rest/side tracking. M1 supports data representation; execution semantics arrive with tests in M2. A superset is A→B then round rest; a circuit completes all members before round rest. A complex is an ordered linked movement, not independent set credit for each submovement. Unilateral tracking stores left/right distinctly and advances only after both are completed or explicitly skipped. Timed work records seconds; AMRAP has no forced rep goal and stops at safe technique.

The supplied Push targets are preserved. Days 2–4 are editable seed assumptions. Draft loads require confirmation; heavy lateral raises/fly movements must permit lighter load or a regression. Substitutions retain original prescription and reason and must not suggest unsafe furniture anchors.

## Rest and tempo

Persist start instant, deadline, prescribed seconds, accumulated pause and paused remaining. Remaining = max(0, deadline − now); +15 extends deadline, paused extension adds to remaining. Pause captures remaining; resume writes a new deadline. Refresh ticks only render time. Handle significant system clock changes by detecting discontinuity, preserving records and offering correction; never mint rewards from elapsed time. Rest begins from committed set completion even if optional animation fails. Actual rest is measured to next set start, not set finish.

Tempo phases lower/hold/lift derive from an absolute phase start; no background audio/timer promises beyond OS support. Coaching optional; prescription remains visible. Estimated TUT = reps × phase sum only for comparable full reps and explicitly labeled an estimate.

## Validation/acceptance

Reject negative/nonfinite load, impossible ordinals, duplicate commands, unknown IDs, invalid RIR/RPE, reps for timed-only entries and duration for rep-only records. Missing optional RIR is valid. Draft autosave plus immediate persistence on primary actions; save failures keep input and prevent false completion. Tests cover all transitions, group order, each side, repeats, skip/undo/substitute, termination, draft restoration, clock shifts and storage failures. No workout UI may claim durability before M3 restoration tests pass.
