import Foundation
import SwiftData
import Testing
import GodModeCore
@testable import GodMode

@MainActor
struct PersistenceTests {
    @Test func freshStoreHasNoInventedProfile() throws {
        let repository = SwiftDataProfileRepository(container: try StoreFactory.make(inMemory: true))
        #expect(try repository.load() == nil)
    }

    @Test func saveUpdatesOneProfile() throws {
        let container = try StoreFactory.make(inMemory: true)
        let repository = SwiftDataProfileRepository(container: container)
        let start = Date(timeIntervalSince1970: 100)
        try repository.save(TrainingProfile(displayName: "First", createdAt: start, updatedAt: start))
        try repository.save(TrainingProfile(displayName: "Updated", createdAt: start, updatedAt: start.addingTimeInterval(10)))
        #expect(try repository.load()?.displayName == "Updated")
        let records = try ModelContext(container).fetch(FetchDescriptor<GodModeSchemaV1.ProfileRecord>())
        #expect(records.count == 1)
        #expect(records.first?.createdAt == start)
    }

    @Test func profileSurvivesDiskStoreReopening() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("fixture.store")
        let now = Date(timeIntervalSince1970: 100)
        let expected = try TrainingProfile(displayName: "Restored", createdAt: now, updatedAt: now)
        try writeAndClose(expected, at: url)
        let reopened = try StoreFactory.make(url: url)
        #expect(try SwiftDataProfileRepository(container: reopened).load() == expected)
    }

    @Test func duplicateProfilesSurfaceAnError() throws {
        let container = try StoreFactory.make(inMemory: true)
        let context = ModelContext(container)
        for name in ["One", "Two"] {
            context.insert(GodModeSchemaV1.ProfileRecord(displayName: name, createdAt: .now, updatedAt: .now))
        }
        try context.save()
        let repository = SwiftDataProfileRepository(container: container)
        #expect(throws: ProfileError.duplicateProfile) { try repository.load() }
    }

    private func writeAndClose(_ profile: TrainingProfile, at url: URL) throws {
        let container = try StoreFactory.make(url: url)
        try SwiftDataProfileRepository(container: container).save(profile)
    }
}
