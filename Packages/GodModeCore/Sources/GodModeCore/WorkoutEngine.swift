import Foundation

public enum WorkoutEngine {
    public static let maximumSteps = 512
    public static let maximumCommands = 4096

    public static func prepare(id: UUID, program: TrainingProgram, dayID: String,
                               at instant: WorkoutInstant) throws -> WorkoutSession {
        try instant.validate()
        let snapshot = try program.validated()
        guard let day = snapshot.days.first(where: { $0.id == dayID }) else { throw WorkoutError.unknownDay }
        var steps: [WorkoutStep] = []
        for block in day.blocks {
            let grouped = block.kind == .superset || block.kind == .circuit
            for round in 1...block.rounds {
                for (index, prescription) in block.prescriptions.enumerated() {
                    for ordinal in 1...prescription.sets {
                        let sides: [WorkoutSide] = prescription.sideTracking == .eachSide ? [.left, .right] : [.bilateral]
                        for (sideIndex, side) in sides.enumerated() {
                            let lastSide = sideIndex == sides.count - 1
                            let lastMember = index == block.prescriptions.count - 1
                            let rest = lastSide ? (grouped ? (lastMember ? block.roundRestSeconds : 0) : prescription.restSeconds) : 0
                            guard steps.count < maximumSteps else { throw WorkoutError.capacityExceeded }
                            steps.append(WorkoutStep(
                                id: WorkoutStepID(prescriptionID: prescription.id, ordinal: grouped ? round : ordinal, side: side),
                                blockID: block.id, round: round, prescription: prescription, restAfterSeconds: rest))
                        }
                    }
                }
            }
        }
        return WorkoutSession(id: id, program: snapshot, dayID: dayID, steps: steps,
                              createdAt: instant.date, lastInstant: instant)
    }

    public static func apply(_ command: WorkoutCommand, to original: WorkoutSession,
                             at instant: WorkoutInstant) throws -> WorkoutTransition {
        guard command.sessionID == original.id else { throw WorkoutError.wrongSession }
        // WHY: Retries after a successful save can have an old revision or arrive after completion.
        if let receipt = original.receipts[command.id] {
            guard receipt == command else { throw WorkoutError.commandConflict }
            return WorkoutTransition(session: original, events: [], isReplay: true)
        }
        guard command.expectedRevision == original.revision else { throw WorkoutError.staleRevision }
        guard !original.status.isTerminal else { throw WorkoutError.invalidState }
        let ending = command.action == .finish || command.action == .finishPartial || command.action == .abort
        // WHY: A full command journal must still allow preserving a partial session or aborting it.
        guard original.receipts.count < maximumCommands || ending else { throw WorkoutError.capacityExceeded }
        try instant.validate()
        if command.action != .reconcileClock {
            let wallDelta = instant.date.timeIntervalSince(original.lastInstant.date)
            let elapsedDelta = instant.uptime - original.lastInstant.uptime
            guard elapsedDelta >= 0, wallDelta >= 0, abs(wallDelta - elapsedDelta) <= 5 else {
                throw WorkoutError.clockDiscontinuity
            }
        }
        // WHY: Value semantics keep the caller's state intact if any validation fails.
        var session = original
        let events = try mutate(command, session: &session, at: instant)
        session.lastInstant = instant
        session.revision += 1
        session.receipts[command.id] = command
        return WorkoutTransition(session: session, events: events, isReplay: false)
    }

    private static func mutate(_ command: WorkoutCommand, session: inout WorkoutSession,
                               at instant: WorkoutInstant) throws -> [WorkoutEvent] {
        let now = instant.date
        switch command.action {
        case .start:
            guard session.status == .ready else { throw WorkoutError.invalidState }
            session.status = .active; session.startedAt = now
            return [.started]
        case .beginSet(let id):
            let step = try activeStep(id, in: session)
            guard session.setStart == nil else { throw WorkoutError.invalidState }
            closeRest(in: &session, at: now, reason: .nextSetBegan)
            session.setStart = WorkoutSetStart(stepID: step.id, startedAt: now, segmentStartedAt: now)
            session.undoPoint = nil
            return [.setBegan(id)]
        case .editDraft(let id, let input):
            let step = try activeStep(id, in: session)
            try input.validate(for: step.prescription, complete: false)
            session.draft = input; session.undoPoint = nil
            return [.draftChanged]
        case .completeSet(let id, let input):
            let step = try activeStep(id, in: session)
            guard let start = session.setStart, start.stepID == id else { throw WorkoutError.invalidState }
            try input.validate(for: step.prescription, complete: true)
            saveUndoPoint(in: &session, at: now)
            let record = WorkoutSetResult(commandID: command.id, stepID: id, exerciseID: session.exerciseID(for: step),
                                          outcome: .completed, input: input, startedAt: start.startedAt,
                                          resolvedAt: now, activeSeconds: start.elapsed(at: now))
            session.results.append(record); session.draft = nil; session.setStart = nil
            if session.currentStep != nil {
                session.rest = WorkoutRest(after: id, seconds: step.restAfterSeconds, at: now)
            }
            return [.setCompleted(record)]
        case .skipSet(let id, let reason):
            let step = try activeStep(id, in: session)
            let note = try validReason(reason)
            saveUndoPoint(in: &session, at: now)
            appendSkipped(step, reason: note, commandID: command.id, session: &session, at: now)
            session.draft = nil; session.setStart = nil
            return [.stepsSkipped([id])]
        case .skipExercise(let prescriptionID, let reason):
            guard session.status == .active, session.currentStep?.id.prescriptionID == prescriptionID else {
                throw WorkoutError.wrongStep
            }
            let note = try validReason(reason)
            let resolved = Set(session.results.map(\.stepID))
            let remaining = session.steps.filter { $0.id.prescriptionID == prescriptionID && !resolved.contains($0.id) }
            saveUndoPoint(in: &session, at: now)
            for step in remaining { appendSkipped(step, reason: note, commandID: command.id, session: &session, at: now) }
            session.draft = nil; session.setStart = nil
            return [.stepsSkipped(remaining.map(\.id))]
        case .undoSet:
            guard session.status == .active, let undo = session.undoPoint else { throw WorkoutError.noUndo }
            let reversed = Array(session.results.dropFirst(undo.resultCount))
            session.undoHistory.append(WorkoutUndo(commandID: command.id, date: now, reversed: reversed))
            session.results = Array(session.results.prefix(undo.resultCount))
            session.rest = undo.rest
            session.draft = reversed.count == 1 ? (reversed.first?.input ?? undo.draft) : undo.draft
            session.setStart = undo.setStart
            if session.setStart != nil { session.setStart?.segmentStartedAt = now }
            session.undoPoint = nil
            return [.resolutionUndone(reversed.map(\.stepID))]
        case .substitute(let prescriptionID, let exerciseID, let reason):
            guard session.status == .active, let step = session.currentStep,
                  step.id.prescriptionID == prescriptionID else { throw WorkoutError.wrongStep }
            guard session.program.exercise(id: exerciseID) != nil else { throw WorkoutError.unknownExercise }
            guard !session.results.contains(where: { $0.stepID.prescriptionID == prescriptionID }),
                  session.setStart == nil, session.draft == nil else { throw WorkoutError.substitutionTooLate }
            session.substitutions[prescriptionID] = WorkoutSubstitution(commandID: command.id,
                originalExerciseID: step.prescription.exerciseID, replacementExerciseID: exerciseID,
                reason: try validReason(reason), date: now)
            session.undoPoint = nil
            return [.substituted(prescriptionID)]
        case .pause:
            guard session.status == .active else { throw WorkoutError.invalidState }
            session.rest?.pause(at: now); session.setStart?.freeze(at: now)
            session.status = .paused; session.pausedAt = now; session.undoPoint = nil
            return [.paused]
        case .resume:
            guard session.status == .paused else { throw WorkoutError.invalidState }
            session.pausedSeconds += session.pausedAt.map { max(0, now.timeIntervalSince($0)) } ?? 0
            session.pausedAt = nil; session.rest?.resume(at: now)
            if session.setStart != nil { session.setStart?.segmentStartedAt = now }
            session.status = .active
            return [.resumed]
        case .extendRest(let seconds):
            guard [.active, .paused].contains(session.status), session.rest != nil else { throw WorkoutError.invalidState }
            try session.rest?.extend(seconds: seconds, at: now)
            return [.restChanged]
        case .skipRest:
            guard [.active, .paused].contains(session.status), session.rest != nil else { throw WorkoutError.invalidState }
            session.rest?.skip(at: now)
            return [.restChanged]
        case .finish:
            guard session.status == .active, session.currentStep == nil,
                  session.results.allSatisfy({ $0.outcome == .completed }) else { throw WorkoutError.invalidState }
            finish(&session, as: .completed, at: now)
            return [.finished(.completed)]
        case .finishPartial:
            guard [.active, .paused].contains(session.status),
                  session.results.contains(where: { $0.outcome == .completed }) else { throw WorkoutError.invalidState }
            finish(&session, as: .partial, at: now)
            return [.finished(.partial)]
        case .abort:
            finish(&session, as: .aborted, at: now)
            return [.finished(.aborted)]
        case .updateNotes(let notes):
            guard notes.count <= 2000 else { throw WorkoutError.invalidInput }
            session.notes = notes
            return [.notesChanged]
        case .reconcileClock:
            // WHY: Unknown wall-clock jumps cannot manufacture elapsed work or rewards.
            // An explicit acknowledgement preserves only elapsed/remaining time last observed.
            let old = session.lastInstant.date
            session.rest?.reconcile(from: old, to: now)
            session.setStart?.freeze(at: old)
            if session.status == .active, session.setStart != nil { session.setStart?.segmentStartedAt = now }
            if let pausedAt = session.pausedAt {
                session.pausedSeconds += max(0, old.timeIntervalSince(pausedAt)); session.pausedAt = now
            }
            session.undoPoint = nil
            return [.clockReconciled]
        }
    }

    private static func activeStep(_ id: WorkoutStepID, in session: WorkoutSession) throws -> WorkoutStep {
        guard session.status == .active else { throw WorkoutError.invalidState }
        guard let step = session.currentStep, step.id == id else { throw WorkoutError.wrongStep }
        return step
    }
    private static func validReason(_ reason: String) throws -> String {
        let text = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, text.count <= 500 else { throw WorkoutError.invalidInput }
        return text
    }
    private static func saveUndoPoint(in session: inout WorkoutSession, at date: Date) {
        var start = session.setStart
        start?.freeze(at: date)
        session.undoPoint = WorkoutUndoPoint(resultCount: session.results.count, rest: session.rest,
                                            draft: session.draft, setStart: start)
    }
    private static func appendSkipped(_ step: WorkoutStep, reason: String, commandID: UUID,
                                      session: inout WorkoutSession, at date: Date) {
        let start = session.setStart?.stepID == step.id ? session.setStart : nil
        session.results.append(WorkoutSetResult(commandID: commandID, stepID: step.id,
            exerciseID: session.exerciseID(for: step), outcome: .skipped(reason: reason), input: nil,
            startedAt: start?.startedAt, resolvedAt: date, activeSeconds: start?.elapsed(at: date)))
    }
    private static func closeRest(in session: inout WorkoutSession, at date: Date, reason: WorkoutClosedRest.EndReason) {
        if let rest = session.rest {
            session.restHistory.append(WorkoutClosedRest(period: rest, endedAt: date,
                                                        elapsedSeconds: rest.elapsed(at: date), reason: reason))
            session.rest = nil
        }
    }
    private static func finish(_ session: inout WorkoutSession, as status: WorkoutStatus, at date: Date) {
        closeRest(in: &session, at: date, reason: .sessionEnded)
        if let pausedAt = session.pausedAt { session.pausedSeconds += max(0, date.timeIntervalSince(pausedAt)) }
        session.setStart?.freeze(at: date)
        session.pausedAt = nil; session.status = status; session.finishedAt = date; session.undoPoint = nil
        // Retain an unfinished draft/start as audit context; it earns no completed-set event.
    }
}
