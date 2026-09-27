import Foundation
import Observation
import GodModeCore

@MainActor
@Observable
final class AppModel {
    enum State { case loading, ready, failed }
    private(set) var state = State.loading
    private(set) var program: TrainingProgram?
    private(set) var profile: TrainingProfile?
    private(set) var setupError: String?
    private(set) var isSaving = false
    @ObservationIgnored private let programs: any ProgramRepository
    @ObservationIgnored private let profiles: any ProfileRepository

    init(programs: any ProgramRepository, profiles: any ProfileRepository) {
        self.programs = programs
        self.profiles = profiles
    }

    func load() async {
        state = .loading
        do {
            let loaded = try await programs.load()
            try Task.checkCancellation()
            let profile = try profiles.load()
            self.program = loaded
            self.profile = profile
            state = .ready
        } catch {
            state = .failed
        }
    }

    func saveProfile(name: String, now: Date = .now) {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        setupError = nil
        do {
            let created = profile?.createdAt ?? now
            let updated = try TrainingProfile(displayName: name, createdAt: created, updatedAt: max(created, now))
            try profiles.save(updated)
            profile = updated
        } catch ProfileError.invalidName {
            setupError = String(localized: "Enter a name of 1–40 characters without line breaks.")
        } catch {
            setupError = String(localized: "Your name could not be saved. Your entry is still here. Try again.")
        }
    }
}
