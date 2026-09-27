import Foundation

public struct TrainingProfile: Sendable, Equatable {
    public let displayName: String
    public let createdAt: Date
    public let updatedAt: Date

    public init(displayName: String, createdAt: Date, updatedAt: Date) throws {
        let normalized = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (1...40).contains(normalized.count),
              normalized.unicodeScalars.allSatisfy({ !CharacterSet.controlCharacters.contains($0) }) else {
            throw ProfileError.invalidName
        }
        guard updatedAt >= createdAt else { throw ProfileError.invalidDates }
        self.displayName = normalized
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum ProfileError: Error, Equatable, Sendable {
    case invalidName
    case invalidDates
    case duplicateProfile
}

@MainActor
public protocol ProfileRepository {
    func load() throws -> TrainingProfile?
    func save(_ profile: TrainingProfile) throws
}
