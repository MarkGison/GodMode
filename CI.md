# Checkpoint CI and artifact contract

`Config/build.json` pins Xcode 26.2, iOS 26.2 simulator runtime, iOS 26 minimum, version/build and stable bundle ID. GitHub `macos-15` currently includes this Xcode; images evolve, so missing tools are an Environment failure requiring a deliberate pin update. Never select an arbitrary newer version silently. No third-party runtime packages or package-manager install step. Project generation uses standard-library Python and is checked for drift. Source content is reproducible; signed artifacts/timestamps need not be byte-identical. [Runner inventory](https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md).

## Workflows

- **GodMode portable checks:** Ubuntu on relevant code/config/tool changes and manual dispatch. Documentation-only pushes do not run it; no macOS minutes. Validates structure, pipeline tests and generated Xcode project.
- **GodMode checkpoint:** manual dispatch only. Cheap preflight before macOS allocation; read-only repository token; bounded 45-minute job. Group related changes before running. Inputs `suite = compile | unit | full`, `package = none | unsigned | signed`. Full suite is required for packaging. Compile-only is diagnostic, not milestone completion.

Full suite: native Debug build-for-testing with coverage + Release simulator build; Foundation-only Swift tests with warnings as errors; app SwiftData/presentation tests and UI smoke/performance tests; xcresult/coverage/attachments. UI flows additionally run on iPhone SE (3rd generation) and iPhone 17 Pro Max at default and largest accessibility text sizes. Unit scope omits UI execution and is labeled as such. Physical-device checks remain acceptance work. No automatic paid service enrollment or provisioning setup.

## Independent results

Each run writes `build-status.json` and `summary.md` under a fresh timestamped artifact folder. Environment identifies runner availability; Compilation reports simulator compilation; Tests reports selected scope; Archive reports device archive creation; Signing reports export/signature verification; IPA reports actual packaging. Device archive failures can include device-specific compilation errors; inspect that stage's log. Signing failure does not rewrite earlier passing source/test states.

| Stage | Values |
| --- | --- |
| Compilation / Tests | PASS / FAIL; NOT RUN or RUNNING until evidence exists |
| Archive / Signing | PASS / FAIL / NOT CONFIGURED; RUNNING while executing |
| IPA | GENERATED / NOT GENERATED; RUNNING during packaging |

`ipaKind` is `unsigned`, `signed`, or null. Unsigned always has `installable: false`. Signed means export and codesign verification passed, not that the owner-device installation was tested. `physicalDeviceVerified` remains false until separate evidence is recorded. A green job with Signing NOT CONFIGURED means validation succeeded; it does not promise an IPA. Canceled/runner-lost jobs with incomplete states are never accepted.

## Packaging

`none`: no archive/signing work. `unsigned`: unsigned **device** archive → `Payload/GodMode.app` ZIP → `GodMode-unsigned-for-resigning.ipa`; clearly not directly installable. Never package a simulator build. `signed`: unsigned device archive then standard `xcodebuild -exportArchive` with valid manual development signing → codesign verification → `GodMode.ipa`. Missing credentials skip signing without marking source invalid. Invalid/expired/mismatched credentials fail only deployment stages. No provisioning/security bypass or Apple ID password flow is built into CI.

Protected environment `personal-signing` optionally holds `GODMODE_CERTIFICATE_P12_BASE64`, `GODMODE_CERTIFICATE_PASSWORD`, `GODMODE_PROFILE_BASE64`. Empty P12 password is allowed. `validation` environment needs no signing secrets. Only signed requests receive signing material. Export requires a valid matching private key/certificate and unexpired device development profile for the stable bundle ID. No promise that every free-account workflow can supply exportable CI credentials; the compatible Windows installer may perform legitimate signing instead.

Ephemeral keychain and temporary profile files are cleaned up. Standalone credentials/profiles are never uploaded. The signed IPA necessarily embeds its public provisioning profile; keep artifact access private. Logs from signing contain only named step/exit-code diagnostics, not raw credential-tool output. No `-allowProvisioningUpdates`, certificate downloading tricks or App Store upload steps.

Artifacts: logs, environment metadata, state reports, xcresult (including UI attachments), coverage when available, optional `.xcarchive` and appropriate `.ipa`. GitHub downloads them as a ZIP named `GodMode-<run>-<commit>`. Retention 7 days to limit storage; download wanted IPAs/reports promptly. Forced cancellation may prevent final artifact upload. Full native validation passed in checkpoint 36323283081; see STATUS.md for current packaging and acceptance evidence.
