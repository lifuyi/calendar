#!/bin/bash

# Script to create a proper macOS app bundle for CalendarStatusBar

echo "Creating CalendarStatusBar.app bundle..."

# Build the project first
swift build -c release

# Create app bundle structure
APP_NAME="CalendarStatusBar"
BUNDLE_DIR="${APP_NAME}.app"
CONTENTS_DIR="${BUNDLE_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

# Clean up any existing bundle
rm -rf "${BUNDLE_DIR}"

# Create directory structure
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Copy the executable
cp ".build/release/${APP_NAME}" "${MACOS_DIR}/"

# Copy the existing Info.plist and modify it
cp "Sources/CalendarStatusBar/Info.plist" "${CONTENTS_DIR}/Info.plist"

# Update the Info.plist with proper values
cat > "${CONTENTS_DIR}/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>Calendar Status Bar</string>
    <key>CFBundleIdentifier</key>
    <string>com.calendar.statusbar</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSCalendarsUsageDescription</key>
    <string>此应用需要访问您的日历以显示今天的事件。</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Copy resources if they exist
if [ -d "Sources/CalendarStatusBar/Media.xcassets" ]; then
    cp -r "Sources/CalendarStatusBar/Media.xcassets" "${RESOURCES_DIR}/"
fi

if [ -d "Sources/CalendarStatusBar/Holidays" ]; then
    cp -r "Sources/CalendarStatusBar/Holidays" "${RESOURCES_DIR}/"
fi

if [ -f "mainland-china.json" ]; then
    cp "mainland-china.json" "${RESOURCES_DIR}/"
fi

# Make executable
chmod +x "${MACOS_DIR}/${APP_NAME}"

echo "App bundle created: ${BUNDLE_DIR}"
echo "You can now run: open ${BUNDLE_DIR}"
echo "Or copy to Applications: cp -r ${BUNDLE_DIR} /Applications/"