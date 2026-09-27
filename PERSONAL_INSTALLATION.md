# GodMode Personal Edition installation

Target: private personal use on the owner's iPhone, iOS 26 or later. Development happens on Windows; native builds happen in automated macOS CI. No App Store/TestFlight/public release or paid remote Mac is required. Keep the repository and downloadable artifacts private.

## Artifact meanings

| Artifact | Meaning |
| --- | --- |
| Build/test logs and `.xcresult` | Validation evidence, not an app installer |
| `GodMode.xcarchive` | Device build archive; may be unsigned |
| `GodMode-unsigned-for-resigning.ipa` | Device app packaged for a compatible legitimate signing installer; **cannot install as-is** |
| `GodMode.ipa` | Standard Xcode export/signature verification succeeded with supplied valid signing configuration; still subject to provisioning/device compatibility |

Run GitHub Actions **GodMode checkpoint**, full suite. Choose none for validation only, unsigned for a re-signing package, signed only when legitimate credentials are configured. Download the run's artifact ZIP and read `build-status.json` before selecting the contained IPA. See `CI.md` for exact inputs and secret names. An `.ipa` extension alone is not evidence of signing.

## Free personal signing

Use a compatible, maintained Windows personal sideload installer that signs/provisions with the owner's Apple account through its documented flow. GodMode does not depend on a specific vendor and does not store that account. Check that the installer supports the current iOS version, the package and its capabilities. Apple's free Personal Team profiles expire after seven days and require renewal; tool-specific limits and refresh behavior also apply. See [Apple's account overview](https://developer.apple.com/help/account/basics/about-your-developer-account) and, as one example rather than a requirement, [AltStore's Windows documentation](https://faq.altstore.io/altstore-classic/how-to-install-altstore-windows).

The repository neither bypasses code signing nor renews profiles itself. Do not jailbreak, patch iOS security, use unsupported certificates or defeat expiry. Follow standard device trust/developer settings only when the legitimate installation flow requires them. No free-account CI export capability is promised; unsigned CI payload + legitimate installer re-signing may be the practical path. Actual installer compatibility must be verified on the owner's device.

## Stable updates and data

Identity is `com.markgison.godmode` in `Config/build.json`, chosen before the first app installation. Preserve it, the installer identity/mapping and compatible signing team across updates. Some installers transform IDs; record the actual installed identity and keep it consistent. Same-ID updates may retain the container; identity changes or uninstall can remove it. Data never depends on a certificate's serial number or expiry.

Before updating, export a `.godmode` backup to storage outside the app and verify its Backup Information. Install as an update without deleting the existing app. Reopen and check Hunter/history/active workout. If data is absent, use validated import; never attempt to repair it by deleting more files. **The current foundation does not yet implement backup/import; it is not ready for irreplaceable training data.** Backup is a V1 release gate.

## Troubleshooting

| Symptom | Check/action |
| --- | --- |
| Cannot install unsigned IPA | It still requires legitimate signing/provisioning; inspect `ipaKind` |
| Integrity/profile expired | Refresh/re-sign through the legitimate installer using the same identity; do not uninstall first |
| Device not covered / identifier mismatch | Profile must authorize the device and installed bundle ID; use a compatible valid profile |
| Requires newer iOS | Minimum is iOS 26; CI simulator output cannot be installed on a device |
| HealthKit/iCloud/widget unavailable | Check Personal Edition capabilities; use local/manual features; iCloud is future scope |
| Compilation/Test FAIL | Share the relevant CI log; signing changes cannot repair source errors |
| Signing NOT CONFIGURED | Source development may continue; supply valid credentials only if using CI signing |
| Signing FAIL | Inspect sanitized signing-step report; verify expiry, certificate/private-key match and bundle/device coverage |
| No IPA in run | Check selected package mode, archive/signing statuses and earlier failures |

Once implemented, Export Diagnostics provides sanitized support information. Backups and diagnostics are different files; do not share a complete health/workout backup merely to report a compile or installation error.
