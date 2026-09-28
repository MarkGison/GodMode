import Foundation

public struct WorkoutRest: Sendable, Equatable {
    public let afterStep: WorkoutStepID
    public let startedAt: Date
    public let prescribedSeconds: Int
    public internal(set) var deadline: Date?
    public internal(set) var pausedRemaining: TimeInterval?
    public internal(set) var accumulatedPauseSeconds: TimeInterval = 0
    public internal(set) var wasSkipped = false
    var elapsedBeforeSegment: TimeInterval = 0
    var segmentStartedAt: Date?
    var pausedAt: Date?

    init(after step: WorkoutStepID, seconds: Int, at date: Date) {
        afterStep = step; startedAt = date; prescribedSeconds = seconds
        deadline = date.addingTimeInterval(Double(seconds)); segmentStartedAt = date
    }
    public func remaining(at date: Date) -> TimeInterval {
        pausedRemaining ?? deadline.map { max(0, $0.timeIntervalSince(date)) } ?? 0
    }
    public func elapsed(at date: Date) -> TimeInterval {
        elapsedBeforeSegment + (segmentStartedAt.map { max(0, date.timeIntervalSince($0)) } ?? 0)
    }
    mutating func pause(at date: Date) {
        pausedRemaining = remaining(at: date); elapsedBeforeSegment = elapsed(at: date)
        deadline = nil; segmentStartedAt = nil; pausedAt = date
    }
    mutating func resume(at date: Date) {
        accumulatedPauseSeconds += pausedAt.map { max(0, date.timeIntervalSince($0)) } ?? 0
        deadline = date.addingTimeInterval(pausedRemaining ?? 0)
        pausedRemaining = nil; segmentStartedAt = date; pausedAt = nil
    }
    mutating func extend(seconds: Int, at date: Date) throws {
        guard (1...600).contains(seconds), remaining(at: date) + Double(seconds) <= 3600,
              !wasSkipped else { throw WorkoutError.invalidInput }
        if let pausedRemaining { self.pausedRemaining = pausedRemaining + Double(seconds) }
        else { deadline = date.addingTimeInterval(remaining(at: date) + Double(seconds)) }
    }
    mutating func skip(at date: Date) {
        if pausedRemaining != nil { pausedRemaining = 0 } else { deadline = date }
        wasSkipped = true
    }
    mutating func reconcile(from old: Date, to new: Date) {
        let seconds = remaining(at: old)
        elapsedBeforeSegment = elapsed(at: old)
        if pausedRemaining != nil {
            accumulatedPauseSeconds += pausedAt.map { max(0, old.timeIntervalSince($0)) } ?? 0
            pausedAt = new
        } else {
            deadline = new.addingTimeInterval(seconds); segmentStartedAt = new
        }
    }
}

public struct WorkoutClosedRest: Sendable, Equatable {
    public enum EndReason: Sendable, Equatable { case nextSetBegan, sessionEnded }
    public let period: WorkoutRest
    public let endedAt: Date
    public let elapsedSeconds: TimeInterval
    public let reason: EndReason
}

public struct TempoCue: Sendable, Equatable {
    public enum Phase: Sendable, Equatable { case lower, hold, lift }
    public let phase: Phase
    public let secondsRemaining: TimeInterval
    public let cycle: Int
}

extension Tempo {
    var isWorkoutValid: Bool {
        (0...10).contains(eccentric) && (0...10).contains(pause) && (0...10).contains(concentric)
            && eccentric + pause + concentric > 0
    }
    /// Render from elapsed active time; no tick changes the workout or earns a rep.
    public func cue(after elapsedSeconds: TimeInterval) throws -> TempoCue {
        guard isWorkoutValid, elapsedSeconds.isFinite, (0...86400).contains(elapsedSeconds) else {
            throw WorkoutError.invalidInput
        }
        let total = Double(eccentric + pause + concentric)
        var position = elapsedSeconds.truncatingRemainder(dividingBy: total)
        for (phase, duration) in [(TempoCue.Phase.lower, eccentric), (.hold, pause), (.lift, concentric)] {
            if position < Double(duration) {
                return TempoCue(phase: phase, secondsRemaining: Double(duration) - position,
                                cycle: Int(elapsedSeconds / total))
            }
            position -= Double(duration)
        }
        throw WorkoutError.invalidInput
    }
}
