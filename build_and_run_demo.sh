#!/bin/bash
# Build and run the GWYoga iOS Demo App
# Usage: ./build_and_run_demo.sh [simulator_name]
# Default simulator: "iPhone 14 Pro"

set -e

SIM_NAME="${1:-iPhone 14 Pro}"

echo "==> Resolving package dependencies..."
xcodebuild -workspace Demo.xcworkspace -scheme GWYogaDemoApp \
  -destination "platform=iOS Simulator,name=$SIM_NAME" \
  -resolvePackageDependencies 2>&1 | tail -3

echo "==> Building..."
xcodebuild -workspace Demo.xcworkspace -scheme GWYogaDemoApp \
  -destination "platform=iOS Simulator,name=$SIM_NAME" \
  build 2>&1 | tail -3

echo "==> Installing and launching on simulator..."
SIM_UDID=$(xcrun simctl list --json devices available 2>/dev/null | python3 -c "
import json,sys
d=json.load(sys.stdin)
for k,v in d['devices'].items():
    for dev in v:
        if dev['name'] == '$SIM_NAME':
            print(dev['udid'])
            sys.exit(0)
")

if [ -z "$SIM_UDID" ]; then
  echo "Simulator '$SIM_NAME' not found. Build succeeded but skipping launch."
  echo "Open Demo.xcworkspace in Xcode and run from there."
  exit 0
fi

xcrun simctl boot "$SIM_UDID" 2>/dev/null || true
xcrun simctl install "$SIM_UDID" Build/Products/Debug-iphonesimulator/GWYogaDemoApp.app
xcrun simctl launch "$SIM_UDID" com.gwyoga.demo 2>&1
echo "==> Done! App launched on $SIM_NAME"
