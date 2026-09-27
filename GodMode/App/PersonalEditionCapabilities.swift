import GodModeCore

struct PersonalEditionCapabilities: SystemCapabilities {
    func observation(for capability: SystemCapability) -> CapabilityObservation {
        // WHY: No optional integration is included yet. Never infer entitlements from the OS version.
        // Future module adapters must obtain real configuration and authorization observations.
        CapabilityObservation(moduleIncluded: false, platformSupported: true,
                              configuration: .unknown, authorization: .unknown)
    }
}
