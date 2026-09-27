import SwiftUI
import SwiftData
import GodModeCore

@main
struct GodModeApp: App {
    var body: some Scene {
        WindowGroup {
            BootstrapView()
                .preferredColorScheme(.dark)
                .tint(DesignTokens.Color.energy)
        }
    }
}

private struct BootstrapView: View {
    @State private var model: AppModel?
    @State private var failed = false

    var body: some View {
        Group {
            if let model {
                RootView(model: model)
            } else if failed {
                ContentUnavailableView {
                    Label("Storage unavailable", systemImage: "externaldrive.badge.exclamationmark")
                } description: {
                    Text("GodMode could not open your local data. Your store has been preserved.")
                } actions: {
                    Button("Retry", action: bootstrap)
                }
            } else {
                ProgressView("Opening GodMode…")
            }
        }
        .background(DesignTokens.Color.canvas)
        .task { if model == nil { bootstrap() } }
    }

    private func bootstrap() {
        failed = false
        do {
            var useMemory = false
            #if DEBUG
            useMemory = ProcessInfo.processInfo.arguments.contains("--ui-testing")
            #endif
            let container = try StoreFactory.make(inMemory: useMemory)
            model = AppModel(
                programs: BundledProgramRepository(),
                profiles: SwiftDataProfileRepository(container: container)
            )
        } catch {
            // WHY: An ephemeral fallback would imply that unsaved user data is safely stored.
            failed = true
        }
    }
}
