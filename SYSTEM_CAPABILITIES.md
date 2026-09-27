# System capability contract

SystemCapabilities is an injected central layer. Availability is not equivalent to user authorization. Model build inclusion, platform/device support, entitlement configuration and runtime authorization separately, with a user-readable reason and manual fallback. No framework access solely because `#available` is true. Do not assume all personal-account apps have the same capability set.

The M1 foundation includes a pure capability policy and an app provider declaring current optional integrations not included. Later adapters supply real platform/entitlement/permission observations before enabling their controls. This intentionally conservative foundation never guesses an authorization result or requests permissions at startup.

| Capability | Future probe | Absent/denied behavior |
| --- | --- | --- |
| HealthKit | Build flag + configured signed entitlement + health-data availability + requested write authorization; read access remains opaque | Manual body-weight entry and authoritative local workout history |
| Notifications | UNUserNotificationCenter authorization settings | In-app rest/schedule UI; no reminder promise |
| Live Activities | Build configuration + ActivityAuthorizationInfo + OS/device support | In-app absolute rest countdown |
| App Intents | Included intent definitions + OS support | Ordinary in-app navigation; do not invent a permission dialog |
| Widgets | Built extension + required shared storage configuration | All information remains available in app; installation/pinning not inferred |
| iCloud | Future CloudSyncService + configured entitlement + account availability | Local repository; outside V1 |

Re-evaluate runtime observations on foreground and settings changes. Never crash when unavailable. UI hides or explains disabled optional controls; core workout/RPG/3D/backup features do not depend on optional states. Notifications cannot be inferred from an entitlement bit; HealthKit empty reads cannot be labeled denial. Settings shows only nonsecret capability reasons.

Tests: missing module, unsupported OS/device, missing entitlement, unknown authorization, explicit denial/revocation, supported ready state and refresh. Later provider integration tests must verify the relevant Apple API behavior on CI/device; the current policy tests are not entitlement verification.

Reference: [Apple capability availability](https://developer.apple.com/help/account/reference/supported-capabilities-ios).
