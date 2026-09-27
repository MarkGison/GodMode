import Foundation
import Testing
@testable import GodModeCore

struct CatalogTests {
    @Test func bundledProgramPreservesPushPrescription() async throws {
        let program = try await BundledProgramRepository().load()
        #expect(program.days.map(\.id) == ["push", "lower", "pull", "full-body"])
        let push = try #require(program.days.first)
        let sets = push.blocks.flatMap(\.prescriptions)
        #expect(sets.map(\.sets) == [4, 4, 4, 4, 4, 3])
        #expect(sets.map(\.restSeconds) == [60, 60, 60, 45, 45, 45])
        #expect(sets.map { $0.tempo?.notation } == ["3-1-1", "3-1-1", "2-1-1", "2-1-2", "3-1-1", nil])
        #expect(sets.map(\.minimumReps) == [8, 8, 8, 12, 10, nil])
        #expect(sets.map(\.maximumReps) == [12, 12, 12, 15, 15, nil])
        #expect(sets.last?.target == .amrap)
        #expect(program.days.flatMap(\.blocks).flatMap(\.prescriptions).allSatisfy {
            $0.suggestedLoadKgPerImplement == nil
        })
    }

    @Test func groupsRetainRoundsAndSides() async throws {
        let program = try await BundledProgramRepository().load()
        let blocks = program.days.flatMap(\.blocks)
        #expect(blocks.filter { $0.kind == .circuit }.map(\.rounds) == [3, 3])
        #expect(blocks.filter { $0.kind == .superset }.count == 1)
        #expect(blocks.filter { $0.kind == .complex }.count == 2)
        #expect(blocks.filter { $0.kind == .unilateral }.allSatisfy {
            $0.prescriptions.allSatisfy { $0.sideTracking == .eachSide }
        })
    }

    @Test func missingExerciseReferenceIsRejected() async throws {
        let original = try await BundledProgramRepository().load()
        let data = try rewritten(original, key: "exerciseID", value: "missing")
        #expect(throws: CatalogError.missingExercise("missing")) {
            try JSONDecoder().decode(TrainingProgram.self, from: data).validated()
        }
    }

    @Test(arguments: [0, 2, 99])
    func unknownSchemaIsRejected(version: Int) async throws {
        let original = try await BundledProgramRepository().load()
        let data = try rewritten(original, key: "schemaVersion", value: version)
        #expect(throws: CatalogError.unsupportedVersion(version)) {
            try JSONDecoder().decode(TrainingProgram.self, from: data).validated()
        }
    }

    @Test(arguments: [0, -1, 11])
    func invalidSetCountsAreRejected(count: Int) async throws {
        let original = try await BundledProgramRepository().load()
        let data = try rewritten(original, key: "sets", value: count)
        #expect(throws: CatalogError.self) {
            try JSONDecoder().decode(TrainingProgram.self, from: data).validated()
        }
    }

    @Test func duplicateIdentityIsRejected() async throws {
        let original = try await BundledProgramRepository().load()
        let data = try rewritten(original, key: "id", value: "duplicate")
        #expect(throws: CatalogError.self) {
            try JSONDecoder().decode(TrainingProgram.self, from: data).validated()
        }
    }

    @Test func invertedRepRangeIsRejected() async throws {
        let original = try await BundledProgramRepository().load()
        let data = try rewritten(original, key: "minimumReps", value: 99)
        #expect(throws: CatalogError.self) {
            try JSONDecoder().decode(TrainingProgram.self, from: data).validated()
        }
    }

    @Test func unilateralBlockRequiresSideTracking() async throws {
        let original = try await BundledProgramRepository().load()
        let data = try rewritten(original, key: "sideTracking", value: "bilateral")
        #expect(throws: CatalogError.self) {
            try JSONDecoder().decode(TrainingProgram.self, from: data).validated()
        }
    }

    @Test(arguments: [-1, 601])
    func invalidRoundRestIsRejected(seconds: Int) async throws {
        let original = try await BundledProgramRepository().load()
        let data = try rewritten(original, key: "roundRestSeconds", value: seconds)
        #expect(throws: CatalogError.self) {
            try JSONDecoder().decode(TrainingProgram.self, from: data).validated()
        }
    }

    @Test func invalidTargetCombinationsAndLoadsAreRejected() throws {
        let baseline = ExercisePrescription(
            id: "test", exerciseID: "bench", sets: 3, target: .reps,
            minimumReps: 8, maximumReps: 12, durationSeconds: nil,
            tempo: Tempo(eccentric: 3, pause: 1, concentric: 1),
            restSeconds: 60, sideTracking: .bilateral, suggestedLoadKgPerImplement: 10
        )
        try baseline.validate()
        let invalid = [
            ExercisePrescription(id: "negative", exerciseID: "bench", sets: 3, target: .reps,
                                 minimumReps: 8, maximumReps: 12, durationSeconds: nil, tempo: nil,
                                 restSeconds: 60, sideTracking: .bilateral, suggestedLoadKgPerImplement: -1),
            ExercisePrescription(id: "nan", exerciseID: "bench", sets: 3, target: .reps,
                                 minimumReps: 8, maximumReps: 12, durationSeconds: nil, tempo: nil,
                                 restSeconds: 60, sideTracking: .bilateral, suggestedLoadKgPerImplement: .nan),
            ExercisePrescription(id: "timed", exerciseID: "plank", sets: 1, target: .timed,
                                 minimumReps: 8, maximumReps: 12, durationSeconds: 20, tempo: nil,
                                 restSeconds: 60, sideTracking: .bilateral, suggestedLoadKgPerImplement: nil),
            ExercisePrescription(id: "amrap", exerciseID: "push-up", sets: 1, target: .amrap,
                                 minimumReps: nil, maximumReps: nil, durationSeconds: 30, tempo: nil,
                                 restSeconds: 60, sideTracking: .bilateral, suggestedLoadKgPerImplement: nil)
        ]
        for prescription in invalid {
            #expect(throws: CatalogError.self) { try prescription.validate() }
        }
    }

    @Test func repositoryReturnsStableCatalog() async throws {
        let repository = BundledProgramRepository()
        let first = try await repository.load()
        let second = try await repository.load()
        #expect(first == second)
    }

    private func rewritten(_ program: TrainingProgram, key: String, value: Any) throws -> Data {
        let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(program))
        func replace(_ object: Any) -> Any {
            if let dictionary = object as? [String: Any] {
                return dictionary.mapValues { replace($0) }.merging(
                    dictionary[key] == nil ? [:] : [key: value], uniquingKeysWith: { _, new in new }
                )
            }
            if let array = object as? [Any] { return array.map(replace) }
            return object
        }
        return try JSONSerialization.data(withJSONObject: replace(json))
    }
}

struct ProfileTests {
    @Test(arguments: ["", "   ", "a\nb", String(repeating: "a", count: 41)])
    func invalidNameIsRejected(name: String) {
        let now = Date(timeIntervalSince1970: 100)
        #expect(throws: ProfileError.invalidName) {
            try TrainingProfile(displayName: name, createdAt: now, updatedAt: now)
        }
    }

    @Test func trimsNamesWithoutRejectingUnicode() throws {
        let now = Date(timeIntervalSince1970: 100)
        let profile = try TrainingProfile(displayName: "  馬克  ", createdAt: now, updatedAt: now)
        #expect(profile.displayName == "馬克")
    }

    @Test func invalidDateOrderIsRejected() {
        #expect(throws: ProfileError.invalidDates) {
            try TrainingProfile(displayName: "Hunter", createdAt: Date(timeIntervalSince1970: 2), updatedAt: Date(timeIntervalSince1970: 1))
        }
    }
}
