#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This gate requires macOS, Xcode 26+, and an iOS 26+ simulator." >&2
  exit 1
fi
major=$(xcodebuild -version | awk '/Xcode/ {split($2, version, "."); print version[1]}')
if [[ "$major" -lt 26 ]]; then
  echo "Select Xcode 26 or later with DEVELOPER_DIR or xcode-select." >&2
  exit 1
fi
python3 tools/validate_repository.py
swift test --package-path Packages/GodModeCore --parallel -Xswiftc -warnings-as-errors
simulator_id="${GODMODE_SIMULATOR_ID:-}"
if [[ -z "$simulator_id" ]]; then
  simulator_id=$(xcrun simctl list devices available -j | python3 -c '
import json, sys
devices = json.load(sys.stdin)["devices"]
for runtime, entries in sorted(devices.items(), reverse=True):
    if ".iOS-" not in runtime:
        continue
    version = int(runtime.split(".iOS-")[-1].split("-")[0])
    if version < 26:
        continue
    for device in entries:
        if device.get("isAvailable") and device["name"].startswith("iPhone"):
            print(device["udid"])
            sys.exit(0)
sys.exit("No available iOS 26+ iPhone simulator; install a runtime in Xcode Settings.")
')
fi
mkdir -p artifacts
result="artifacts/GodMode-$(date +%Y%m%d-%H%M%S).xcresult"
xcodebuild -project GodMode.xcodeproj -scheme GodMode -configuration Debug \
  -destination "platform=iOS Simulator,id=$simulator_id" \
  -derivedDataPath DerivedData -resultBundlePath "$result" \
  CODE_SIGNING_ALLOWED=NO test
xcodebuild -project GodMode.xcodeproj -scheme GodMode -configuration Release \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath DerivedData \
  CODE_SIGNING_ALLOWED=NO build
echo "Apple build/test gate passed. Manual visual/accessibility and device gates remain in TEST_PLAN.md."
