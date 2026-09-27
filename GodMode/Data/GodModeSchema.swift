import Foundation
import SwiftData

enum GodModeSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [ProfileRecord.self] }

    @Model
    final class ProfileRecord {
        var key: String = "local-owner"
        var displayName: String = ""
        var createdAt: Date = Date.now
        var updatedAt: Date = Date.now

        init(displayName: String, createdAt: Date, updatedAt: Date) {
            self.displayName = displayName
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
    }
}

enum GodModeMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [GodModeSchemaV1.self] }
    // WHY: V1 has no predecessor. A real stage and retained fixture are mandatory when V2 is added.
    static var stages: [MigrationStage] { [] }
}

@MainActor
enum StoreFactory {
    static func make(inMemory: Bool = false, url: URL? = nil) throws -> ModelContainer {
        let schema = Schema(versionedSchema: GodModeSchemaV1.self)
        let configuration: ModelConfiguration
        if let url {
            configuration = ModelConfiguration("GodMode", schema: schema, url: url, cloudKitDatabase: .none)
        } else {
            configuration = ModelConfiguration(
                "GodMode", schema: schema, isStoredInMemoryOnly: inMemory, cloudKitDatabase: .none
            )
        }
        return try ModelContainer(
            for: schema, migrationPlan: GodModeMigrationPlan.self, configurations: [configuration]
        )
    }
}
