import Foundation

public protocol ProgramRepository: Sendable {
    func load() async throws -> TrainingProgram
}

public actor BundledProgramRepository: ProgramRepository {
    private var cached: TrainingProgram?

    public init() {}

    public func load() async throws -> TrainingProgram {
        if let cached { return cached }
        guard let url = Bundle.module.url(forResource: "home-hypertrophy-v1", withExtension: "json") else {
            throw CatalogError.resourceMissing
        }
        // WHY: Validate at the content boundary; views never need to repair malformed prescriptions.
        let program = try JSONDecoder().decode(TrainingProgram.self, from: Data(contentsOf: url)).validated()
        cached = program
        return program
    }
}
