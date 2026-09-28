import Foundation
import Testing
@testable import GodModeCore

struct WorkoutTimingTests {
    private func resting() throws -> WorkoutSession {
        var session = try WorkoutFixture.active()
        let step = try #require(session.currentStep)
        try WorkoutFixture.send(.beginSet(step.id), to: &session, at: 0)
        try WorkoutFixture.send(.completeSet(step.id, WorkoutFixture.input), to: &session, at: 10)
        return session
    }

    @Test func restUsesAbsoluteDeadlineWithoutTickMutations() throws {
        let session = try resting()
        #expect(session.rest?.remaining(at: WorkoutFixture.instant(10).date) == 60)
        #expect(session.rest?.remaining(at: WorkoutFixture.instant(30).date) == 40)
        #expect(session.rest?.remaining(at: WorkoutFixture.instant(500).date) == 0)
        #expect(session.revision == 3)
    }

    @Test func pauseExtensionAndResumePreserveRemainingAndActualRest() throws {
        var session = try resting()
        try WorkoutFixture.send(.pause, to: &session, at: 20)
        try WorkoutFixture.send(.extendRest(seconds: 15), to: &session, at: 50)
        #expect(session.rest?.remaining(at: WorkoutFixture.instant(100).date) == 65)
        try WorkoutFixture.send(.resume, to: &session, at: 120)
        #expect(session.rest?.deadline == WorkoutFixture.instant(185).date)
        let step = try #require(session.currentStep)
        try WorkoutFixture.send(.beginSet(step.id), to: &session, at: 150)
        #expect(session.restHistory.last?.elapsedSeconds == 40)
        #expect(session.restHistory.last?.period.accumulatedPauseSeconds == 100)
        #expect(session.pausedSeconds == 100)
        try WorkoutFixture.send(.completeSet(step.id, WorkoutFixture.input), to: &session, at: 200)
        #expect(session.restHistory.last?.elapsedSeconds == 40)
        #expect(session.results.last?.activeSeconds == 50)
    }

    @Test func activeSetTimingExcludesPause() throws {
        var session = try WorkoutFixture.active()
        let step = try #require(session.currentStep)
        try WorkoutFixture.send(.beginSet(step.id), to: &session, at: 0)
        try WorkoutFixture.send(.editDraft(step.id, WorkoutFixture.input), to: &session, at: 5)
        try WorkoutFixture.send(.pause, to: &session, at: 20)
        #expect(throws: WorkoutError.invalidState) {
            try WorkoutFixture.send(.completeSet(step.id, WorkoutFixture.input), to: &session, at: 50)
        }
        #expect(session.draft == WorkoutFixture.input)
        try WorkoutFixture.send(.resume, to: &session, at: 100)
        try WorkoutFixture.send(.completeSet(step.id, WorkoutFixture.input), to: &session, at: 110)
        #expect(session.results.first?.activeSeconds == 30)
    }

    @Test func skipRestKeepsActualElapsedUntilNextSetStarts() throws {
        var session = try resting()
        try WorkoutFixture.send(.skipRest, to: &session, at: 20)
        #expect(session.rest?.remaining(at: WorkoutFixture.instant(20).date) == 0)
        let step = try #require(session.currentStep)
        try WorkoutFixture.send(.beginSet(step.id), to: &session, at: 25)
        #expect(session.restHistory.last?.elapsedSeconds == 15)
        #expect(session.restHistory.last?.period.wasSkipped == true)
    }

    @Test func expiredRestCanBeExtendedFromNow() throws {
        var session = try resting()
        try WorkoutFixture.send(.extendRest(seconds: 15), to: &session, at: 100)
        #expect(session.rest?.deadline == WorkoutFixture.instant(115).date)
        #expect(session.rest?.prescribedSeconds == 60)
    }

    @Test func clockJumpRequiresAcknowledgementAndCannotInventElapsedWork() throws {
        var session = try resting()
        let jumped = WorkoutInstant(date: WorkoutFixture.instant(500).date, uptime: 120)
        let command = WorkoutCommand(id: UUID(), sessionID: session.id, expectedRevision: session.revision, action: .pause)
        #expect(throws: WorkoutError.clockDiscontinuity) { try WorkoutEngine.apply(command, to: session, at: jumped) }
        let acknowledge = WorkoutCommand(id: UUID(), sessionID: session.id, expectedRevision: session.revision, action: .reconcileClock)
        let transition = try WorkoutEngine.apply(acknowledge, to: session, at: jumped)
        session = transition.session
        #expect(session.rest?.remaining(at: jumped.date) == 60)
        #expect(session.rest?.elapsed(at: jumped.date) == 0)
        #expect(session.results.count == 1)
        #expect(transition.events == [.clockReconciled])
    }

    @Test func backwardsClockOrRebootCannotSilentlyResume() throws {
        let session = try resting()
        let command = WorkoutCommand(id: UUID(), sessionID: session.id, expectedRevision: session.revision, action: .pause)
        for instant in [WorkoutInstant(date: WorkoutFixture.instant(9).date, uptime: 120),
                        WorkoutInstant(date: WorkoutFixture.instant(20).date, uptime: 1)] {
            #expect(throws: WorkoutError.clockDiscontinuity) { try WorkoutEngine.apply(command, to: session, at: instant) }
        }
    }

    @Test func pausedClockReconciliationPreservesDraftAndFrozenWork() throws {
        var session = try WorkoutFixture.active()
        let step = try #require(session.currentStep)
        try WorkoutFixture.send(.beginSet(step.id), to: &session, at: 0)
        try WorkoutFixture.send(.editDraft(step.id, WorkoutFixture.input), to: &session, at: 10)
        try WorkoutFixture.send(.pause, to: &session, at: 20)
        let command = WorkoutCommand(id: UUID(), sessionID: session.id, expectedRevision: session.revision, action: .reconcileClock)
        session = try WorkoutEngine.apply(command, to: session,
            at: WorkoutInstant(date: WorkoutFixture.instant(500).date, uptime: 1)).session
        #expect(session.status == .paused)
        #expect(session.draft == WorkoutFixture.input)
        #expect(session.setStart?.elapsed(at: WorkoutFixture.instant(900).date) == 20)
    }

    @Test func tempoUsesPhaseBoundariesAndSkipsZeroLengthPhases() throws {
        let tempo = Tempo(eccentric: 3, pause: 1, concentric: 1)
        #expect(try tempo.cue(after: 0).phase == .lower)
        #expect(try tempo.cue(after: 3).phase == .hold)
        #expect(try tempo.cue(after: 4).phase == .lift)
        #expect(try tempo.cue(after: 5).phase == .lower)
        #expect(try tempo.cue(after: 5).cycle == 1)
        #expect(try tempo.cue(after: 2.5).secondsRemaining == 0.5)
        #expect(try Tempo(eccentric: 0, pause: 0, concentric: 1).cue(after: 0).phase == .lift)
        #expect(throws: WorkoutError.invalidInput) { try Tempo(eccentric: 0, pause: 0, concentric: 0).cue(after: 0) }
        #expect(throws: WorkoutError.invalidInput) { try tempo.cue(after: .infinity) }
    }

    @Test func timeUnderTensionIsOnlyAnExplicitComparableRepEstimate() {
        let tempo = Tempo(eccentric: 3, pause: 1, concentric: 1)
        #expect(WorkoutSetInput(reps: 10, actualTempo: tempo).estimatedTimeUnderTension == nil)
        #expect(WorkoutSetInput(reps: 10, actualTempo: tempo, comparableFullReps: true).estimatedTimeUnderTension == 50)
        #expect(WorkoutSetInput(durationSeconds: 30, actualTempo: tempo, comparableFullReps: true).estimatedTimeUnderTension == nil)
    }
}
