import Foundation
import Testing
@testable import GodModeCore

struct WorkoutValidationTests {
    @Test(arguments: [WorkoutSetInput(reps: -1), WorkoutSetInput(reps: 1001),
        WorkoutSetInput(rir: -1), WorkoutSetInput(rir: 5), WorkoutSetInput(rpe: .nan),
        WorkoutSetInput(rpe: 11), WorkoutSetInput(durationSeconds: 30),
        WorkoutSetInput(load: .perImplement(kilograms: 10, count: 0)),
        WorkoutSetInput(load: .totalExternal(kilograms: -.infinity)),
        WorkoutSetInput(load: .bodyweight(addedKilograms: -1)),
        WorkoutSetInput(actualTempo: Tempo(eccentric: 0, pause: 0, concentric: 0)),
        WorkoutSetInput(notes: String(repeating: "x", count: 2001))])
    func invalidDraftIsRejectedWithoutMutation(input: WorkoutSetInput) throws {
        var session = try WorkoutFixture.active()
        let step = try #require(session.currentStep)
        let before = session
        #expect(throws: WorkoutError.invalidInput) {
            try WorkoutFixture.send(.editDraft(step.id, input), to: &session, at: 0)
        }
        #expect(session == before)
    }

    @Test(arguments: [ExercisePrescription.Target.amrap, .timed])
    func amrapAndTimedWorkAcceptActualPerformanceWithoutForcingTheTarget(target: ExercisePrescription.Target) throws {
        var session = try WorkoutFixture.active(WorkoutFixture.program(sets: 1, target: target))
        let step = try #require(session.currentStep)
        try WorkoutFixture.send(.beginSet(step.id), to: &session, at: 0)
        let input = WorkoutSetInput(reps: target == .amrap ? 0 : nil,
            durationSeconds: target == .timed ? 5 : nil, load: .bodyweight(addedKilograms: 0), rir: nil)
        try WorkoutFixture.send(.completeSet(step.id, input), to: &session, at: 5)
        #expect(session.results.first?.input == input)
        #expect(session.currentStep == nil)
    }

    @Test func timedWorkRejectsRepsAndInvalidDurations() throws {
        var session = try WorkoutFixture.active(WorkoutFixture.program(target: .timed))
        let step = try #require(session.currentStep)
        for input in [WorkoutSetInput(reps: 1), WorkoutSetInput(durationSeconds: 0), WorkoutSetInput(durationSeconds: 3601)] {
            #expect(throws: WorkoutError.invalidInput) {
                try WorkoutFixture.send(.editDraft(step.id, input), to: &session, at: 0)
            }
        }
    }

    @Test func rejectsUnknownDayExerciseAndBlankSkipReason() throws {
        #expect(throws: WorkoutError.unknownDay) {
            try WorkoutEngine.prepare(id: UUID(), program: WorkoutFixture.program(), dayID: "missing", at: WorkoutFixture.instant(0))
        }
        var session = try WorkoutFixture.active()
        #expect(throws: WorkoutError.unknownExercise) {
            try WorkoutFixture.send(.substitute(prescriptionID: "p0", exerciseID: "missing", reason: "Reason"), to: &session, at: 0)
        }
        let step = try #require(session.currentStep)
        #expect(throws: WorkoutError.invalidInput) {
            try WorkoutFixture.send(.skipSet(step.id, reason: " \n"), to: &session, at: 0)
        }
    }

    @Test func rejectsNonfiniteClockAndOversizedNotes() throws {
        var session = try WorkoutFixture.active()
        let command = WorkoutCommand(id: UUID(), sessionID: session.id, expectedRevision: session.revision, action: .pause)
        #expect(throws: WorkoutError.invalidInput) {
            try WorkoutEngine.apply(command, to: session, at: WorkoutInstant(date: Date(timeIntervalSince1970: .nan), uptime: 1))
        }
        #expect(throws: WorkoutError.invalidInput) {
            try WorkoutFixture.send(.updateNotes(String(repeating: "x", count: 2001)), to: &session, at: 0)
        }
    }

    @Test func readyAndPausedSessionsRejectWorkCommands() throws {
        var session = try WorkoutFixture.ready()
        let step = try #require(session.currentStep)
        #expect(throws: WorkoutError.invalidState) { try WorkoutFixture.send(.beginSet(step.id), to: &session, at: 0) }
        #expect(throws: WorkoutError.invalidState) { try WorkoutFixture.send(.resume, to: &session, at: 0) }
        try WorkoutFixture.send(.start, to: &session, at: 0)
        #expect(throws: WorkoutError.invalidState) { try WorkoutFixture.send(.start, to: &session, at: 0) }
        try WorkoutFixture.send(.pause, to: &session, at: 0)
        #expect(throws: WorkoutError.invalidState) { try WorkoutFixture.send(.beginSet(step.id), to: &session, at: 0) }
        #expect(throws: WorkoutError.invalidState) { try WorkoutFixture.send(.editDraft(step.id, WorkoutFixture.input), to: &session, at: 0) }
        #expect(throws: WorkoutError.invalidState) { try WorkoutFixture.send(.pause, to: &session, at: 0) }
    }

    @Test func restExtensionRequiresTimerAndBoundedPositiveSeconds() throws {
        var session = try WorkoutFixture.active()
        #expect(throws: WorkoutError.invalidState) { try WorkoutFixture.send(.extendRest(seconds: 15), to: &session, at: 0) }
        let step = try #require(session.currentStep)
        try WorkoutFixture.send(.beginSet(step.id), to: &session, at: 0)
        try WorkoutFixture.send(.completeSet(step.id, WorkoutFixture.input), to: &session, at: 10)
        for seconds in [-1, 0, 601] {
            #expect(throws: WorkoutError.invalidInput) { try WorkoutFixture.send(.extendRest(seconds: seconds), to: &session, at: 10) }
        }
        try WorkoutFixture.send(.skipRest, to: &session, at: 10)
        #expect(throws: WorkoutError.invalidInput) { try WorkoutFixture.send(.extendRest(seconds: 15), to: &session, at: 10) }
    }

    @Test func planExpansionHasBoundedSize() throws {
        let blocks = (0..<52).map { index in
            WorkoutBlock(id: "b\(index)", kind: .straight, rounds: 1, roundRestSeconds: 0,
                prescriptions: [ExercisePrescription(id: "p\(index)", exerciseID: "e0", sets: 10, target: .amrap,
                    minimumReps: nil, maximumReps: nil, durationSeconds: nil, tempo: nil,
                    restSeconds: 60, sideTracking: .bilateral, suggestedLoadKgPerImplement: nil)])
        }
        let base = WorkoutFixture.program()
        let oversized = TrainingProgram(schemaVersion: 1, id: "large", name: "Large", revision: 1, reviewNotice: "Test",
            exercises: base.exercises, days: [WorkoutDay(id: "day", name: "Day", focus: "Test", dungeon: "Test", blocks: blocks)])
        #expect(throws: WorkoutError.capacityExceeded) { try WorkoutFixture.ready(oversized) }
    }

    @Test func commandCapacityFailsExplicitlyWithoutEvictingRetryHistory() throws {
        var session = try WorkoutFixture.ready()
        let original = WorkoutCommand(id: UUID(), sessionID: session.id, expectedRevision: 0, action: .updateNotes("first"))
        session = try WorkoutEngine.apply(original, to: session, at: WorkoutFixture.instant(0)).session
        for _ in 1..<WorkoutEngine.maximumCommands {
            try WorkoutFixture.send(.updateNotes("bounded"), to: &session, at: 0)
        }
        #expect(throws: WorkoutError.capacityExceeded) { try WorkoutFixture.send(.start, to: &session, at: 0) }
        #expect(try WorkoutEngine.apply(original, to: session, at: WorkoutFixture.instant(1)).isReplay)
        try WorkoutFixture.send(.abort, to: &session, at: 0)
        #expect(session.status == .aborted)
    }
}
