import SwiftUI

struct SetupView: View {
    @Bindable var model: AppModel
    @State private var name = ""

    var body: some View {
        NavigationStack {
            Page {
                Text("Awaken your potential.").font(DesignTokens.TypeStyle.hero)
                Text("Real training. A new journey.").foregroundStyle(DesignTokens.Color.textSecondary)
                Panel {
                    Text("What should we call you?").font(DesignTokens.TypeStyle.section)
                    TextField("Hunter name", text: $name,
                              prompt: Text("Hunter name").foregroundStyle(DesignTokens.Color.textSecondary))
                        .textContentType(.nickname)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .accessibilityIdentifier("setup.name")
                        .onSubmit { model.saveProfile(name: name) }
                    Text("Your name stays on this device. No account required.")
                        .font(DesignTokens.TypeStyle.caption)
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                    if let error = model.setupError {
                        Text(error)
                            .foregroundStyle(DesignTokens.Color.error)
                            .accessibilityIdentifier("setup.error")
                    }
                    Button("Continue") { model.saveProfile(name: name) }
                        .buttonStyle(.borderedProminent)
                        .foregroundStyle(DesignTokens.Color.onEnergy)
                        .controlSize(.large)
                        .frame(minHeight: DesignTokens.Size.minimumTarget)
                        .disabled(model.isSaving)
                        .accessibilityIdentifier("setup.continue")
                }
                Text("Foundation preview: explore the four-day program. Workout logging and game progression are still in development.")
                    .font(DesignTokens.TypeStyle.caption)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            }
            .navigationTitle("GodMode")
        }
    }
}
