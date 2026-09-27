import Testing
@testable import GodModeCore

struct CapabilityTests {
    @Test func excludedModuleNeverAppearsAvailable() {
        let observation = CapabilityObservation(moduleIncluded: false, platformSupported: true,
                                                configuration: .verified, authorization: .authorized)
        #expect(observation.state == .notIncluded)
    }

    @Test func platformAndConfigurationMustBothAllowAccess() {
        #expect(CapabilityObservation(moduleIncluded: true, platformSupported: false,
                                      configuration: .verified, authorization: .authorized).state == .unsupported)
        #expect(CapabilityObservation(moduleIncluded: true, platformSupported: true,
                                      configuration: .missing, authorization: .authorized).state == .notConfigured)
        #expect(CapabilityObservation(moduleIncluded: true, platformSupported: true,
                                      configuration: .unknown, authorization: .authorized).state == .configurationUnknown)
    }

    @Test func authorizationIsNotInferredFromAvailability() {
        #expect(state(.notDetermined) == .permissionRequired)
        #expect(state(.denied) == .denied)
        #expect(state(.unknown) == .authorizationUnknown)
        #expect(state(.authorized) == .available)
        #expect(state(.notRequired) == .available)
    }

    private func state(_ authorization: CapabilityAuthorization) -> CapabilityState {
        CapabilityObservation(moduleIncluded: true, platformSupported: true,
                              configuration: .verified, authorization: authorization).state
    }
}
