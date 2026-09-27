import Foundation
import Testing
import GodModeCore
@testable import GodMode

@MainActor
struct AppModelTests {
    @Test func failedSaveDoesNotAdvanceSetup() async throws {
        let profiles = ProfileStub()
        profiles.failWrites = true
        let model = AppModel(programs: BundledProgramRepository(), profiles: profiles)
        await model.load()
        model.saveProfile(name: "Hunter")
        #expect(model.profile == nil)
        #expect(model.setupError != nil)
        #expect(!model.isSaving)
        profiles.failWrites = false
        model.saveProfile(name: "Hunter")
        #expect(model.profile?.displayName == "Hunter")
        #expect(model.setupError == nil)
    }

    @Test func failedCatalogLoadCanBeRetried() async {
        let programs = RetryCatalog()
        let model = AppModel(programs: programs, profiles: ProfileStub())
        await model.load()
        if case .failed = model.state {} else { Issue.record("Expected failed state") }
        await programs.allowLoad()
        await model.load()
        if case .ready = model.state {} else { Issue.record("Expected recovered state") }
        #expect(model.program?.days.count == 4)
    }

    @Test func invalidNameNeverReachesStorage() {
        let profiles = ProfileStub()
        let model = AppModel(programs: BundledProgramRepository(), profiles: profiles)
        model.saveProfile(name: "  ")
        #expect(profiles.saveCount == 0)
        #expect(model.setupError != nil)
    }
}

private enum TestFailure: Error { case unavailable }

@MainActor
private final class ProfileStub: ProfileRepository {
    var value: TrainingProfile?
    var failWrites = false
    var saveCount = 0
    func load() throws -> TrainingProfile? { value }
    func save(_ profile: TrainingProfile) throws {
        if failWrites { throw TestFailure.unavailable }
        saveCount += 1
        value = profile
    }
}

private actor RetryCatalog: ProgramRepository {
    private var allowed = false
    func allowLoad() { allowed = true }
    func load() async throws -> TrainingProgram {
        guard allowed else { throw TestFailure.unavailable }
        return try await BundledProgramRepository().load()
    }
}
