import SwiftUI

struct SystemView: View {
    let model: AppModel

    var body: some View {
        Page {
            VStack(alignment: .leading, spacing: DesignTokens.Space.inline) {
                Text("TRAIN. LEVEL UP. EVOLVE.")
                    .font(DesignTokens.TypeStyle.caption)
                    .foregroundStyle(DesignTokens.Color.energy)
                Text("Your journey starts here.").font(DesignTokens.TypeStyle.hero)
                if let profile = model.profile {
                    Text("Welcome, \(profile.displayName).")
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                }
            }
            if let program = model.program {
                Panel {
                    Label("Your program", systemImage: "dumbbell").font(DesignTokens.TypeStyle.section)
                    Text(program.name).font(DesignTokens.TypeStyle.title)
                    Text("Four training days · Dumbbells & bench")
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                    NavigationLink("Explore program") { ProgramView(program: program) }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .frame(minHeight: DesignTokens.Size.minimumTarget)
                        .accessibilityIdentifier("system.program")
                }
            }
            Panel {
                Label("Built around recovery", systemImage: "moon.stars").font(DesignTokens.TypeStyle.section)
                Text("Train with control. Take the rest you need. Progress includes recovery.")
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            }
        }
        .navigationTitle("System")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    PersonalEditionSettingsView(capabilities: model.capabilities)
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
    }
}
