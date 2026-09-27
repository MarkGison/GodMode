import SwiftUI

struct RootView: View {
    @Bindable var model: AppModel

    var body: some View {
        Group {
            switch model.state {
            case .loading:
                ProgressView("Loading your program…")
            case .failed:
                ContentUnavailableView {
                    Label("Unable to load GodMode", systemImage: "exclamationmark.triangle")
                } description: {
                    Text("Your local data has not been replaced. Try loading again.")
                } actions: {
                    Button("Retry") { Task { await model.load() } }
                }
            case .ready:
                if model.profile == nil {
                    SetupView(model: model)
                } else {
                    tabs
                }
            }
        }
        .task { await model.load() }
    }

    private var tabs: some View {
        TabView {
            Tab("System", systemImage: "sparkles") {
                NavigationStack { SystemView(model: model) }
            }
            Tab("Quests", systemImage: "list.bullet.clipboard") {
                NavigationStack {
                    if let program = model.program { ProgramView(program: program) }
                }
            }
            Tab("Hunter", systemImage: "person.crop.circle") {
                NavigationStack {
                    FutureFeatureView(title: "Hunter", symbol: "person.crop.circle", description: "Your Hunter will evolve through training. Character creation arrives after the workout foundation.")
                }
            }
            Tab("Arsenal", systemImage: "square.grid.2x2") {
                NavigationStack {
                    FutureFeatureView(title: "Arsenal", symbol: "square.grid.2x2", description: "Earned cosmetics will appear here when rewards and inventory are available.")
                }
            }
            Tab("Progress", systemImage: "chart.xyaxis.line") {
                NavigationStack {
                    FutureFeatureView(title: "Progress", symbol: "chart.xyaxis.line", description: "No workouts recorded. Your saved training history will appear here once workout logging is available.")
                }
            }
        }
    }
}
