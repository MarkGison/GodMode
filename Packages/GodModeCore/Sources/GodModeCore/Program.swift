import Foundation

public struct TrainingProgram: Codable, Sendable, Equatable {
    public let schemaVersion: Int
    public let id: String
    public let name: String
    public let revision: Int
    public let reviewNotice: String
    public let exercises: [ExerciseDefinition]
    public let days: [WorkoutDay]

    public func exercise(id: String) -> ExerciseDefinition? {
        exercises.first { $0.id == id }
    }

    public func validated() throws -> Self {
        guard schemaVersion == 1 else { throw CatalogError.unsupportedVersion(schemaVersion) }
        guard !id.isEmpty, !name.isEmpty, revision > 0, !days.isEmpty else {
            throw CatalogError.invalid("Program identity or days")
        }
        try Self.requireUnique(exercises.map(\.id), field: "exercise")
        try Self.requireUnique(days.map(\.id), field: "day")
        try Self.requireUnique(days.flatMap(\.blocks).map(\.id), field: "block")
        try Self.requireUnique(days.flatMap(\.blocks).flatMap(\.prescriptions).map(\.id), field: "prescription")
        let exerciseIDs = Set(exercises.map(\.id))
        for exercise in exercises {
            guard !exercise.name.isEmpty, !exercise.safetyNote.isEmpty,
                  !exercise.equipment.isEmpty else { throw CatalogError.invalid(exercise.id) }
        }
        for day in days {
            guard !day.name.isEmpty, !day.blocks.isEmpty else { throw CatalogError.invalid(day.id) }
            for block in day.blocks {
                guard (1...10).contains(block.rounds), !block.prescriptions.isEmpty,
                      (0...600).contains(block.roundRestSeconds) else { throw CatalogError.invalid(block.id) }
                switch block.kind {
                case .straight, .unilateral, .complex:
                    guard block.prescriptions.count == 1, block.rounds == 1 else {
                        throw CatalogError.invalid(block.id)
                    }
                case .superset:
                    guard block.prescriptions.count == 2 else { throw CatalogError.invalid(block.id) }
                case .circuit:
                    guard block.prescriptions.count >= 2 else { throw CatalogError.invalid(block.id) }
                }
                for prescription in block.prescriptions {
                    guard exerciseIDs.contains(prescription.exerciseID) else {
                        throw CatalogError.missingExercise(prescription.exerciseID)
                    }
                    try prescription.validate()
                    if block.kind == .unilateral && prescription.sideTracking != .eachSide {
                        throw CatalogError.invalid(prescription.id)
                    }
                    if [.superset, .circuit].contains(block.kind) && prescription.sets != 1 {
                        throw CatalogError.invalid("Grouped prescriptions use one set per round")
                    }
                }
            }
        }
        return self
    }

    private static func requireUnique(_ ids: [String], field: String) throws {
        guard ids.allSatisfy({ !$0.isEmpty }), Set(ids).count == ids.count else {
            throw CatalogError.invalid("Duplicate or empty \(field) ID")
        }
    }
}

public struct ExerciseDefinition: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let equipment: [String]
    public let safetyNote: String
}

public struct WorkoutDay: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let name: String
    public let focus: String
    public let dungeon: String
    public let blocks: [WorkoutBlock]

    public var exerciseCount: Int { blocks.reduce(0) { $0 + $1.prescriptions.count } }
}

public struct WorkoutBlock: Codable, Sendable, Equatable, Identifiable {
    public enum Kind: String, Codable, Sendable { case straight, unilateral, superset, circuit, complex }
    public let id: String
    public let kind: Kind
    public let rounds: Int
    public let roundRestSeconds: Int
    public let prescriptions: [ExercisePrescription]
}

public struct Tempo: Codable, Sendable, Equatable {
    public let eccentric: Int
    public let pause: Int
    public let concentric: Int
    public init(eccentric: Int, pause: Int, concentric: Int) {
        self.eccentric = eccentric; self.pause = pause; self.concentric = concentric
    }
    public var notation: String { "\(eccentric)-\(pause)-\(concentric)" }
}

public struct ExercisePrescription: Codable, Sendable, Equatable, Identifiable {
    public enum Target: String, Codable, Sendable { case reps, amrap, timed }
    public enum SideTracking: String, Codable, Sendable { case bilateral, eachSide }
    public let id: String
    public let exerciseID: String
    public let sets: Int
    public let target: Target
    public let minimumReps: Int?
    public let maximumReps: Int?
    public let durationSeconds: Int?
    public let tempo: Tempo?
    public let restSeconds: Int
    public let sideTracking: SideTracking
    /// nil means the user must confirm a suitable load; equipment availability is not a prescription.
    public let suggestedLoadKgPerImplement: Double?

    public func validate() throws {
        guard (1...10).contains(sets), (0...600).contains(restSeconds) else {
            throw CatalogError.invalid(id)
        }
        if let load = suggestedLoadKgPerImplement, !load.isFinite || load < 0 || load > 500 {
            throw CatalogError.invalid(id)
        }
        switch target {
        case .reps:
            guard let lower = minimumReps, let upper = maximumReps,
                  lower > 0, upper >= lower, upper <= 100, durationSeconds == nil else {
                throw CatalogError.invalid(id)
            }
        case .amrap:
            guard minimumReps == nil, maximumReps == nil, durationSeconds == nil else {
                throw CatalogError.invalid(id)
            }
        case .timed:
            guard let duration = durationSeconds, (1...3600).contains(duration),
                  minimumReps == nil, maximumReps == nil else { throw CatalogError.invalid(id) }
        }
        if let tempo {
            guard (0...10).contains(tempo.eccentric), (0...10).contains(tempo.pause),
                  (0...10).contains(tempo.concentric), tempo.eccentric + tempo.pause + tempo.concentric > 0 else {
                throw CatalogError.invalid(id)
            }
        }
    }
}

public enum CatalogError: Error, Equatable, Sendable {
    case resourceMissing
    case unsupportedVersion(Int)
    case invalid(String)
    case missingExercise(String)
}
