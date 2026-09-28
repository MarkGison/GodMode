import Foundation

public enum WorkoutError: Error, Equatable, Sendable {
    case unknownDay, invalidInput, invalidState, wrongSession, wrongStep
    case staleRevision, commandConflict, capacityExceeded, clockDiscontinuity
    case noUndo, unknownExercise, substitutionTooLate
}

public enum WorkoutStatus: String, Sendable, Equatable {
    case ready, active, paused, completed, partial, aborted
    public var isTerminal: Bool { [.completed, .partial, .aborted].contains(self) }
}

public enum WorkoutSide: String, Codable, Sendable { case bilateral, left, right }

public struct WorkoutStepID: Hashable, Codable, Sendable {
    public let prescriptionID: String
    public let ordinal: Int
    public let side: WorkoutSide
    public init(prescriptionID: String, ordinal: Int, side: WorkoutSide) {
        self.prescriptionID = prescriptionID; self.ordinal = ordinal; self.side = side
    }
}

public struct WorkoutStep: Sendable, Equatable, Identifiable {
    public let id: WorkoutStepID
    public let blockID: String
    public let round: Int
    public let prescription: ExercisePrescription
    public let restAfterSeconds: Int
}

/// A wall clock plus elapsed time since boot lets commands detect clock jumps.
public struct WorkoutInstant: Sendable, Equatable {
    public let date: Date
    public let uptime: TimeInterval
    public init(date: Date, uptime: TimeInterval) { self.date = date; self.uptime = uptime }
    func validate() throws {
        guard date.timeIntervalSinceReferenceDate.isFinite, uptime.isFinite, uptime >= 0 else {
            throw WorkoutError.invalidInput
        }
    }
}

public enum WorkoutLoad: Codable, Sendable, Equatable {
    case perImplement(kilograms: Double, count: Int)
    case totalExternal(kilograms: Double)
    case bodyweight(addedKilograms: Double)

    func validate() throws {
        let kilograms: Double
        switch self {
        case .perImplement(let amount, let count):
            guard (1...2).contains(count) else { throw WorkoutError.invalidInput }
            kilograms = amount
        case .totalExternal(let amount), .bodyweight(let amount): kilograms = amount
        }
        guard kilograms.isFinite, (0...500).contains(kilograms) else { throw WorkoutError.invalidInput }
    }
}

public struct WorkoutSetInput: Codable, Sendable, Equatable {
    public let reps: Int?
    public let durationSeconds: Int?
    public let load: WorkoutLoad?
    public let rir: Int?
    public let rpe: Double?
    public let actualTempo: Tempo?
    public let comparableFullReps: Bool
    public let painReported: Bool?
    public let notes: String

    public init(reps: Int? = nil, durationSeconds: Int? = nil, load: WorkoutLoad? = nil,
                rir: Int? = nil, rpe: Double? = nil, actualTempo: Tempo? = nil,
                comparableFullReps: Bool = false, painReported: Bool? = nil, notes: String = "") {
        self.reps = reps; self.durationSeconds = durationSeconds; self.load = load
        self.rir = rir; self.rpe = rpe; self.actualTempo = actualTempo
        self.comparableFullReps = comparableFullReps; self.painReported = painReported; self.notes = notes
    }

    public var estimatedTimeUnderTension: Int? {
        guard comparableFullReps, let reps, let tempo = actualTempo,
              (0...1000).contains(reps), tempo.isWorkoutValid else { return nil }
        return reps * (tempo.eccentric + tempo.pause + tempo.concentric)
    }

    func validate(for prescription: ExercisePrescription, complete: Bool) throws {
        guard notes.count <= 2000 else { throw WorkoutError.invalidInput }
        if let load { try load.validate() }
        if let rir, !(0...4).contains(rir) { throw WorkoutError.invalidInput }
        if let rpe, !rpe.isFinite || !(1...10).contains(rpe) { throw WorkoutError.invalidInput }
        if let actualTempo, !actualTempo.isWorkoutValid { throw WorkoutError.invalidInput }
        if let reps, !(0...1000).contains(reps) { throw WorkoutError.invalidInput }
        if let durationSeconds, !(1...3600).contains(durationSeconds) { throw WorkoutError.invalidInput }
        switch prescription.target {
        case .reps, .amrap:
            guard durationSeconds == nil, !complete || reps != nil else { throw WorkoutError.invalidInput }
        case .timed:
            guard reps == nil, !complete || durationSeconds != nil else { throw WorkoutError.invalidInput }
        }
        // WHY: Available equipment is not confirmation of the load actually used.
        guard !complete || load != nil else { throw WorkoutError.invalidInput }
    }
}

public enum WorkoutAction: Codable, Sendable, Equatable {
    case start
    case beginSet(WorkoutStepID)
    case editDraft(WorkoutStepID, WorkoutSetInput)
    case completeSet(WorkoutStepID, WorkoutSetInput)
    case skipSet(WorkoutStepID, reason: String)
    case skipExercise(prescriptionID: String, reason: String)
    case undoSet
    case substitute(prescriptionID: String, exerciseID: String, reason: String)
    case pause, resume, extendRest(seconds: Int), skipRest
    case finish, finishPartial, abort, updateNotes(String)
    case reconcileClock
}

public struct WorkoutCommand: Codable, Sendable, Equatable {
    public let id: UUID
    public let sessionID: UUID
    public let expectedRevision: Int
    public let action: WorkoutAction
    public init(id: UUID, sessionID: UUID, expectedRevision: Int, action: WorkoutAction) {
        self.id = id; self.sessionID = sessionID; self.expectedRevision = expectedRevision; self.action = action
    }
}

public struct WorkoutSetResult: Sendable, Equatable {
    public enum Outcome: Sendable, Equatable { case completed, skipped(reason: String) }
    public let commandID: UUID
    public let stepID: WorkoutStepID
    public let exerciseID: String
    public let outcome: Outcome
    public let input: WorkoutSetInput?
    public let startedAt: Date?
    public let resolvedAt: Date
    public let activeSeconds: TimeInterval?
}

public struct WorkoutSubstitution: Sendable, Equatable {
    public let commandID: UUID
    public let originalExerciseID: String
    public let replacementExerciseID: String
    public let reason: String
    public let date: Date
}

public struct WorkoutUndo: Sendable, Equatable {
    public let commandID: UUID
    public let date: Date
    public let reversed: [WorkoutSetResult]
}

public struct WorkoutSetStart: Sendable, Equatable {
    public let stepID: WorkoutStepID
    public let startedAt: Date
    var elapsedBeforeSegment: TimeInterval = 0
    var segmentStartedAt: Date?
    public func elapsed(at date: Date) -> TimeInterval {
        elapsedBeforeSegment + (segmentStartedAt.map { max(0, date.timeIntervalSince($0)) } ?? 0)
    }
    mutating func freeze(at date: Date) { elapsedBeforeSegment = elapsed(at: date); segmentStartedAt = nil }
}

struct WorkoutUndoPoint: Sendable, Equatable {
    let resultCount: Int
    let rest: WorkoutRest?
    let draft: WorkoutSetInput?
    let setStart: WorkoutSetStart?
}

/// Domain state only. M3 must commit a transition atomically before exposing its events.
/// No synthesized Codable: untrusted/restored snapshots require a validated M3 storage adapter.
public struct WorkoutSession: Sendable, Equatable, Identifiable {
    public let id: UUID
    public let program: TrainingProgram
    public let dayID: String
    public let steps: [WorkoutStep]
    public let createdAt: Date
    public internal(set) var status: WorkoutStatus = .ready
    public internal(set) var revision: Int = 0
    public internal(set) var startedAt: Date?
    public internal(set) var finishedAt: Date?
    public internal(set) var pausedAt: Date?
    public internal(set) var pausedSeconds: TimeInterval = 0
    public internal(set) var results: [WorkoutSetResult] = []
    public internal(set) var draft: WorkoutSetInput?
    public internal(set) var setStart: WorkoutSetStart?
    public internal(set) var rest: WorkoutRest?
    public internal(set) var restHistory: [WorkoutClosedRest] = []
    public internal(set) var substitutions: [String: WorkoutSubstitution] = [:]
    public internal(set) var undoHistory: [WorkoutUndo] = []
    public internal(set) var notes = ""
    public internal(set) var lastInstant: WorkoutInstant
    var receipts: [UUID: WorkoutCommand] = [:]
    var undoPoint: WorkoutUndoPoint?

    public var currentStep: WorkoutStep? {
        guard !status.isTerminal else { return nil }
        let resolved = Set(results.map(\.stepID))
        return steps.first { !resolved.contains($0.id) }
    }
    public var canUndo: Bool { status == .active && undoPoint != nil }
    public func exerciseID(for step: WorkoutStep) -> String {
        substitutions[step.id.prescriptionID]?.replacementExerciseID ?? step.prescription.exerciseID
    }
}

public enum WorkoutEvent: Sendable, Equatable {
    case started, paused, resumed, draftChanged, restChanged, notesChanged, clockReconciled
    case setBegan(WorkoutStepID), setCompleted(WorkoutSetResult), stepsSkipped([WorkoutStepID])
    case resolutionUndone([WorkoutStepID]), substituted(String), finished(WorkoutStatus)
}

public struct WorkoutTransition: Sendable, Equatable {
    public let session: WorkoutSession
    public let events: [WorkoutEvent]
    public let isReplay: Bool
}
