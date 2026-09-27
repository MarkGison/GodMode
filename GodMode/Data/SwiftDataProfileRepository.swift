import Foundation
import SwiftData
import GodModeCore

@MainActor
final class SwiftDataProfileRepository: ProfileRepository {
    private let context: ModelContext

    init(container: ModelContainer) {
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    func load() throws -> TrainingProfile? {
        guard let record = try existingRecord() else { return nil }
        return try TrainingProfile(
            displayName: record.displayName, createdAt: record.createdAt, updatedAt: record.updatedAt
        )
    }

    func save(_ profile: TrainingProfile) throws {
        do {
            if let record = try existingRecord() {
                record.displayName = profile.displayName
                record.updatedAt = profile.updatedAt
            } else {
                context.insert(GodModeSchemaV1.ProfileRecord(
                    displayName: profile.displayName, createdAt: profile.createdAt, updatedAt: profile.updatedAt
                ))
            }
            // WHY: Success must mean durable commit, not a pending autosave that termination can lose.
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }

    private func existingRecord() throws -> GodModeSchemaV1.ProfileRecord? {
        var request = FetchDescriptor<GodModeSchemaV1.ProfileRecord>()
        request.fetchLimit = 2
        let records = try context.fetch(request)
        guard records.count <= 1 else { throw ProfileError.duplicateProfile }
        return records.first
    }
}
