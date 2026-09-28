import Foundation
import Testing
@testable import GodModeCore

struct WorkoutEngineTests {
    @Test func preparesEveryBundledDayWithoutChangingPrescription() async throws {
        let program = try await BundledProgramRepository().load()
        for day in program.days {
            let session = try WorkoutEngine.prepare(id: UUID(), program: program, dayID: day.id, at: WorkoutFixture.instant(0))
            #expect(session.program == program)
            #expect(!session.steps.isEmpty)
            #expect(Set(session.steps.map(\.id)).count == session.steps.count)
            #expect(session.status == .ready)
            for step in session.steps {
                #expect(day.blocks.flatMap(\.prescriptions).contains(step.prescription))
            }
        }
    }

    @Test func straightWorkoutFinishesOnlyAfterAllSets() throws {
        var session = try WorkoutFixture.active()
        #expect(throws: WorkoutError.invalidState) { try WorkoutFixture.send(.finish, to: &session, at: 0) }
        for index in 0..<2 {
            let step = try #require(session.currentStep)
            let time = Double(index * 100)
            try WorkoutFixture.send(.beginSet(step.id), to: &session, at: time)
            try WorkoutFixture.send(.completeSet(step.id, WorkoutFixture.input), to: &session, at: time + 10)
        }
        #expect(session.currentStep == nil)
        #expect(session.rest == nil)
        #expect(session.status == .active)
        let result = try WorkoutFixture.send(.finish, to: &session, at: 120)
        #expect(result.events == [.finished(.completed)])
        #expect(session.status == .completed)
        #expect(session.results.count == 2)
        #expect(throws: WorkoutError.invalidState) { try WorkoutFixture.send(.updateNotes("late"), to: &session, at: 121) }
    }

    @Test func retryAfterCompletionDoesNotRepeatAnyEffect() throws {
        var session = try WorkoutFixture.active(WorkoutFixture.program(sets: 1))
        let step = try #require(session.currentStep)
        try WorkoutFixture.send(.beginSet(step.id), to: &session, at: 0)
        let command = WorkoutCommand(id: UUID(), sessionID: session.id, expectedRevision: session.revision,
                                     action: .completeSet(step.id, WorkoutFixture.input))
        session = try WorkoutEngine.apply(command, to: session, at: WorkoutFixture.instant(10)).session
        try WorkoutFixture.send(.finish, to: &session, at: 11)
        let retried = try WorkoutEngine.apply(command, to: session, at: WorkoutFixture.instant(999))
        #expect(retried.isReplay)
        #expect(retried.events.isEmpty)
        #expect(retried.session == session)
        let conflicting = WorkoutCommand(id: command.id, sessionID: session.id, expectedRevision: command.expectedRevision, action: .abort)
        #expect(throws: WorkoutError.commandConflict) {
            try WorkoutEngine.apply(conflicting, to: session, at: WorkoutFixture.instant(12))
        }
    }

    @Test func staleOrForeignCommandsLeaveOriginalUntouched() throws {
        let session = try WorkoutFixture.active()
        let stale = WorkoutCommand(id: UUID(), sessionID: session.id, expectedRevision: 0, action: .abort)
        #expect(throws: WorkoutError.staleRevision) { try WorkoutEngine.apply(stale, to: session, at: WorkoutFixture.instant(1)) }
        let foreign = WorkoutCommand(id: UUID(), sessionID: UUID(), expectedRevision: session.revision, action: .abort)
        #expect(throws: WorkoutError.wrongSession) { try WorkoutEngine.apply(foreign, to: session, at: WorkoutFixture.instant(1)) }
        #expect(session.status == .active)
        #expect(session.revision == 1)
    }

    @Test func requiresExplicitSetStartAndExactCurrentStep() throws {
        var session = try WorkoutFixture.active()
        let step = try #require(session.currentStep)
        #expect(throws: WorkoutError.invalidState) {
            try WorkoutFixture.send(.completeSet(step.id, WorkoutFixture.input), to: &session, at: 0)
        }
        let wrong = WorkoutStepID(prescriptionID: step.id.prescriptionID, ordinal: 99, side: .bilateral)
        #expect(throws: WorkoutError.wrongStep) { try WorkoutFixture.send(.beginSet(wrong), to: &session, at: 0) }
        try WorkoutFixture.send(.beginSet(step.id), to: &session, at: 0)
        #expect(throws: WorkoutError.invalidState) { try WorkoutFixture.send(.beginSet(step.id), to: &session, at: 0) }
    }

    @Test func draftCanBeIncompleteButCompletionRequiresConfirmedLoad() throws {
        var session = try WorkoutFixture.active()
        let step = try #require(session.currentStep)
        let draft = WorkoutSetInput(reps: 7, notes: "Retain this input")
        try WorkoutFixture.send(.editDraft(step.id, draft), to: &session, at: 0)
        try WorkoutFixture.send(.beginSet(step.id), to: &session, at: 1)
        let before = session
        #expect(throws: WorkoutError.invalidInput) {
            try WorkoutFixture.send(.completeSet(step.id, draft), to: &session, at: 2)
        }
        #expect(session == before)
        #expect(session.draft == draft)
    }

    @Test(arguments: [WorkoutBlock.Kind.superset, .circuit])
    func groupedWorkRunsMembersInRoundOrder(kind: WorkoutBlock.Kind) throws {
        var session = try WorkoutFixture.active(WorkoutFixture.program(kind: kind, sets: 1, rounds: 3))
        let memberCount = kind == .superset ? 2 : 3
        #expect(session.steps.count == memberCount * 3)
        for index in 0..<session.steps.count {
            let step = try #require(session.currentStep)
            #expect(step.id.prescriptionID == "p\(index % memberCount)")
            #expect(step.round == index / memberCount + 1)
            #expect(step.id.ordinal == step.round)
            try WorkoutFixture.send(.beginSet(step.id), to: &session, at: Double(index * 20))
            try WorkoutFixture.send(.completeSet(step.id, WorkoutFixture.input), to: &session, at: Double(index * 20 + 10))
            if session.currentStep != nil {
                #expect(session.rest?.prescribedSeconds == (index % memberCount == memberCount - 1 ? 90 : 0))
            }
        }
    }

    @Test func unilateralAdvancesOnlyAfterBothSides() throws {
        var session = try WorkoutFixture.active(WorkoutFixture.program(kind: .unilateral, eachSide: true))
        #expect(session.steps.map(\.id.side) == [.left, .right, .left, .right])
        let left = try #require(session.currentStep)
        try WorkoutFixture.send(.beginSet(left.id), to: &session, at: 0)
        try WorkoutFixture.send(.completeSet(left.id, WorkoutFixture.input), to: &session, at: 10)
        #expect(session.currentStep?.id.side == .right)
        #expect(session.rest?.prescribedSeconds == 0)
        let right = try #require(session.currentStep)
        try WorkoutFixture.send(.beginSet(right.id), to: &session, at: 11)
        try WorkoutFixture.send(.completeSet(right.id, WorkoutFixture.input), to: &session, at: 20)
        #expect(session.currentStep?.id.ordinal == 2)
        #expect(session.currentStep?.id.side == .left)
        #expect(session.rest?.prescribedSeconds == 60)
    }

    @Test func complexIsOneRecordPerLinkedMovementSet() throws {
        var session = try WorkoutFixture.active(WorkoutFixture.program(kind: .complex, sets: 1))
        let step = try #require(session.currentStep)
        try WorkoutFixture.send(.beginSet(step.id), to: &session, at: 0)
        let change = try WorkoutFixture.send(.completeSet(step.id, WorkoutFixture.input), to: &session, at: 10)
        #expect(session.results.count == 1)
        #expect(change.events.count == 1)
        #expect(session.currentStep == nil)
    }

    @Test func skipWholeExerciseInGroupPreservesOtherMembersAndUndoRestoresBatch() throws {
        var session = try WorkoutFixture.active(WorkoutFixture.program(kind: .superset, sets: 1, rounds: 3))
        try WorkoutFixture.send(.skipExercise(prescriptionID: "p0", reason: "Equipment unavailable"), to: &session, at: 1)
        #expect(session.results.count == 3)
        #expect(session.currentStep?.id.prescriptionID == "p1")
        #expect(session.results.allSatisfy { $0.input == nil })
        try WorkoutFixture.send(.undoSet, to: &session, at: 2)
        #expect(session.results.isEmpty)
        #expect(session.currentStep?.id.prescriptionID == "p0")
        #expect(session.undoHistory.first?.reversed.count == 3)
    }

    @Test func undoRetainsAuditAndInputWithoutCountingTheInterveningRestAsWork() throws {
        var session = try WorkoutFixture.active()
        let step = try #require(session.currentStep)
        try WorkoutFixture.send(.beginSet(step.id), to: &session, at: 0)
        try WorkoutFixture.send(.completeSet(step.id, WorkoutFixture.input), to: &session, at: 10)
        try WorkoutFixture.send(.undoSet, to: &session, at: 50)
        #expect(session.currentStep?.id == step.id)
        #expect(session.draft == WorkoutFixture.input)
        #expect(session.rest == nil)
        #expect(session.undoHistory.count == 1)
        #expect(session.setStart?.elapsed(at: WorkoutFixture.instant(55).date) == 15)
        try WorkoutFixture.send(.completeSet(step.id, WorkoutFixture.input), to: &session, at: 55)
        #expect(session.results.count == 1)
        #expect(session.results.first?.activeSeconds == 15)
    }

    @Test func startingNextSetClosesUndoWindow() throws {
        var session = try WorkoutFixture.active()
        let step = try #require(session.currentStep)
        try WorkoutFixture.send(.skipSet(step.id, reason: "Testing"), to: &session, at: 0)
        let next = try #require(session.currentStep)
        try WorkoutFixture.send(.beginSet(next.id), to: &session, at: 1)
        #expect(!session.canUndo)
        #expect(throws: WorkoutError.noUndo) { try WorkoutFixture.send(.undoSet, to: &session, at: 2) }
    }

    @Test func substitutionRetainsOriginalAndRejectsChangesAfterWorkStarts() throws {
        var session = try WorkoutFixture.active()
        try WorkoutFixture.send(.substitute(prescriptionID: "p0", exerciseID: "e1", reason: "Available equipment"), to: &session, at: 0)
        let step = try #require(session.currentStep)
        #expect(step.prescription.exerciseID == "e0")
        #expect(session.exerciseID(for: step) == "e1")
        #expect(session.substitutions["p0"]?.originalExerciseID == "e0")
        try WorkoutFixture.send(.beginSet(step.id), to: &session, at: 1)
        #expect(throws: WorkoutError.substitutionTooLate) {
            try WorkoutFixture.send(.substitute(prescriptionID: "p0", exerciseID: "e0", reason: "Changed mind"), to: &session, at: 2)
        }
        try WorkoutFixture.send(.completeSet(step.id, WorkoutFixture.input), to: &session, at: 10)
        #expect(session.results.first?.exerciseID == "e1")
    }

    @Test func skippedWorkCannotBecomeFullCompletion() throws {
        var session = try WorkoutFixture.active()
        let first = try #require(session.currentStep)
        try WorkoutFixture.send(.skipSet(first.id, reason: "Pain"), to: &session, at: 0)
        #expect(throws: WorkoutError.invalidState) { try WorkoutFixture.send(.finishPartial, to: &session, at: 0) }
        let next = try #require(session.currentStep)
        try WorkoutFixture.send(.beginSet(next.id), to: &session, at: 1)
        try WorkoutFixture.send(.completeSet(next.id, WorkoutFixture.input), to: &session, at: 10)
        #expect(throws: WorkoutError.invalidState) { try WorkoutFixture.send(.finish, to: &session, at: 11) }
        try WorkoutFixture.send(.finishPartial, to: &session, at: 11)
        #expect(session.status == .partial)
    }

    @Test func abortRetainsDraftAndRecordsWithoutInventingCompletion() throws {
        var session = try WorkoutFixture.active()
        let step = try #require(session.currentStep)
        try WorkoutFixture.send(.editDraft(step.id, WorkoutFixture.input), to: &session, at: 0)
        let change = try WorkoutFixture.send(.abort, to: &session, at: 1)
        #expect(session.draft == WorkoutFixture.input)
        #expect(session.results.isEmpty)
        #expect(session.currentStep == nil)
        #expect(change.events == [.finished(.aborted)])
    }

    @Test func commandRoundTripPreservesRetryIdentityAndPayload() throws {
        let command = WorkoutCommand(id: UUID(), sessionID: UUID(), expectedRevision: 2,
            action: .completeSet(WorkoutStepID(prescriptionID: "p0", ordinal: 1, side: .right), WorkoutFixture.input))
        #expect(try JSONDecoder().decode(WorkoutCommand.self, from: JSONEncoder().encode(command)) == command)
    }
}
