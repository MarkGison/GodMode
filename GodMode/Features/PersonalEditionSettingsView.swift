import SwiftUI
import GodModeCore

struct PersonalEditionSettingsView: View {
    let capabilities: any SystemCapabilities

    var body: some View {
        Page {
            Panel {
                Text("GodMode Personal Edition").font(DesignTokens.TypeStyle.title)
                Text("Private training. Stored on your iPhone.")
                Text("Version \(metadata("CFBundleShortVersionString")) · Build \(metadata("CFBundleVersion"))")
                    .font(DesignTokens.TypeStyle.caption)
                Text("Data schema \(String(describing: GodModeSchemaV1.versionIdentifier))")
                    .font(DesignTokens.TypeStyle.caption)
            }
            Panel {
                Text("System Capabilities").font(DesignTokens.TypeStyle.section)
                ForEach(SystemCapability.allCases) { capability in
                    VStack(alignment: .leading, spacing: DesignTokens.Space.inline) {
                        Text(title(capability)).font(DesignTokens.TypeStyle.section)
                        Text(reason(capabilities.observation(for: capability).state))
                            .foregroundStyle(DesignTokens.Color.textSecondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("capability.\(capability.rawValue)")
                }
            }
            Panel {
                Text("Data Management").font(DesignTokens.TypeStyle.section)
                Text("Backup, import and diagnostics export are in development. This foundation build cannot yet back up your data.")
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            }
        }
        .navigationTitle("Personal Edition")
    }

    private func metadata(_ key: String) -> String {
        Bundle.main.object(forInfoDictionaryKey: key) as? String ?? String(localized: "Unknown")
    }

    private func title(_ capability: SystemCapability) -> String {
        switch capability {
        case .healthKit: String(localized: "HealthKit")
        case .notifications: String(localized: "Notifications")
        case .liveActivities: String(localized: "Live Activities")
        case .appIntents: String(localized: "Shortcuts")
        case .widgets: String(localized: "Widgets")
        case .iCloud: String(localized: "iCloud — future optional feature")
        }
    }

    private func reason(_ state: CapabilityState) -> String {
        switch state {
        case .notIncluded: String(localized: "Not included in this build. Local features remain available.")
        case .unsupported: String(localized: "Unavailable on this device or iOS version.")
        case .notConfigured: String(localized: "This build is not configured for this integration.")
        case .configurationUnknown: String(localized: "Integration availability has not been verified.")
        case .permissionRequired: String(localized: "Permission is required to use this optional integration.")
        case .denied: String(localized: "Permission is off. You can continue using local features.")
        case .authorizationUnknown: String(localized: "Authorization status is unavailable.")
        case .available: String(localized: "Available")
        }
    }
}
