#!/bin/bash

# DMG creation script with drag-to-install layout

APP_NAME="CalendarStatusBar"
DMG_NAME="${APP_NAME}.dmg"
APP_PATH="./${APP_NAME}.app"

echo "Creating DMG for ${APP_NAME}..."

# Check if the app exists
if [ ! -d "$APP_PATH" ]; then
    echo "Error: $APP_PATH not found. Please build the app first."
    exit 1
fi

# Check if create-dmg is available
if ! command -v create-dmg &> /dev/null; then
    echo "Error: create-dmg not found. Please install it first."
    echo "Install with: brew install create-dmg"
    exit 1
fi

# Clean up any existing DMG and temp files
rm -f "$DMG_NAME" rw.*.dmg

# Background image (optional)
BACKGROUND=""
if [ -f "dmg_background.png" ]; then
    BACKGROUND="--background dmg_background.png"
    echo "Using background image: dmg_background.png"
fi

# Create DMG with drag-to-install layout
create-dmg \
  --volname "$APP_NAME" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "$APP_NAME.app" 150 190 \
  --icon "Applications" 450 190 \
  --hide-extension "$APP_NAME.app" \
  --app-drop-link 450 190 \
  $BACKGROUND \
  "$DMG_NAME" \
  "$APP_PATH"

# Verify the result
if [ -f "$DMG_NAME" ]; then
    echo ""
    echo "DMG Created Successfully!"
    echo "File: $DMG_NAME"
    echo "Size: $(du -h "$DMG_NAME" | cut -f1)"
    echo ""
    echo "Features:"
    echo "   - App positioned on the left"
    echo "   - Applications folder on the right"
    echo "   - Drag-to-install layout"
    echo "   - Compressed for distribution"
else
    echo "Failed to create DMG"
    exit 1
fi
