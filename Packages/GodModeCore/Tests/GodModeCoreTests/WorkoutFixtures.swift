import Foundation
@testable import GodModeCore

enum WorkoutFixture {
    static func instant(_ seconds: Double) -> WorkoutInstant {
        WorkoutInstant(date: Date(timeIntervalSince1970: 1000 + seconds), uptime: 100 + seconds)
    }
    static let input = WorkoutSetInput(reps: 10, load: .perImplement(kilograms: 10, count: 2), rir: 2)
    static func program(kind: WorkoutBlock.Kind = .straight, sets: Int = 2, rounds: Int = 1,
                        target: ExercisePrescription.Target = .reps, eachSide: Bool = false) -> TrainingProgram {
        let count = kind == .superset ? 2 : (kind == .circuit ? 3 : 1)
        let prescriptions = (0..<count).map { index in
            ExercisePrescription(id: "p\(index)", exerciseID: "e\(index)", sets: sets, target: target,
                minimumReps: target == .reps ? 8 : nil, maximumReps: target == .reps ? 12 : nil,
                durationSeconds: target == .timed ? 30 : nil, tempo: Tempo(eccentric: 3, pause: 1, concentric: 1),
                restSeconds: 60, sideTracking: eachSide ? .eachSide : .bilateral, suggestedLoadKgPerImplement: nil)
        }
        return TrainingProgram(schemaVersion: 1, id: "test", name: "Test", revision: 1, reviewNotice: "Fixture",
            exercises: (0...count).map { ExerciseDefinition(id: "e\($0)", name: "Exercise \($0)", equipment: ["dumbbell"], safetyNote: "Control movement") },
            days: [WorkoutDay(id: "day", name: "Day", focus: "Fixture", dungeon: "Fixture",
                blocks: [WorkoutBlock(id: "block", kind: kind, rounds: rounds, roundRestSeconds: 90, prescriptions: prescriptions)])])
    }
    static func ready(_ program: TrainingProgram = WorkoutFixture.program()) throws -> WorkoutSession {
        try WorkoutEngine.prepare(id: UUID(), program: program, dayID: "day", at: instant(0))
    }
    @discardableResult
    static func send(_ action: WorkoutAction, to session: inout WorkoutSession, at seconds: Double,
                     id: UUID = UUID()) throws -> WorkoutTransition {
        let command = WorkoutCommand(id: id, sessionID: session.id, expectedRevision: session.revision, action: action)
        let result = try WorkoutEngine.apply(command, to: session, at: instant(seconds))
        session = result.session
        return result
    }
    static func active(_ program: TrainingProgram = WorkoutFixture.program()) throws -> WorkoutSession {
        var session = try ready(program)
        try send(.start, to: &session, at: 0)
        return session
    }
}
