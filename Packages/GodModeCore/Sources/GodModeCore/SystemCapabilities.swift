/// Capability availability is independent of workout functionality and of any signing account.
public enum SystemCapability: String, CaseIterable, Sendable, Identifiable {
    case healthKit, notifications, liveActivities, appIntents, widgets, iCloud
    public var id: String { rawValue }
}

public enum CapabilityConfiguration: Sendable { case verified, missing, unknown }
public enum CapabilityAuthorization: Sendable { case notRequired, authorized, notDetermined, denied, unknown }
public enum CapabilityState: Sendable, Equatable {
    case notIncluded, unsupported, notConfigured, configurationUnknown
    case permissionRequired, denied, authorizationUnknown, available
}

public struct CapabilityObservation: Sendable {
    public let moduleIncluded: Bool
    public let platformSupported: Bool
    public let configuration: CapabilityConfiguration
    public let authorization: CapabilityAuthorization

    public init(moduleIncluded: Bool, platformSupported: Bool,
                configuration: CapabilityConfiguration, authorization: CapabilityAuthorization) {
        self.moduleIncluded = moduleIncluded
        self.platformSupported = platformSupported
        self.configuration = configuration
        self.authorization = authorization
    }

    public var state: CapabilityState {
        guard moduleIncluded else { return .notIncluded }
        guard platformSupported else { return .unsupported }
        switch configuration {
        case .missing: return .notConfigured
        case .unknown: return .configurationUnknown
        case .verified: break
        }
        switch authorization {
        case .authorized, .notRequired: return .available
        case .notDetermined: return .permissionRequired
        case .denied: return .denied
        case .unknown: return .authorizationUnknown
        }
    }
}

public protocol SystemCapabilities: Sendable {
    func observation(for capability: SystemCapability) -> CapabilityObservation
}
