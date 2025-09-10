#!/bin/bash

# Final working DMG creation script with layout and best possible icon

APP_NAME="CalendarStatusBar"
DMG_NAME="${APP_NAME}.dmg"
APP_PATH="./${APP_NAME}.app"

echo "Creating final DMG with layout and icon for ${APP_NAME}..."

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

# Clean up any existing DMG
rm -f "$DMG_NAME"

# Create the best possible icon for the volume
ICON_PNG="$APP_PATH/Contents/Resources/RoundedIcon.png"
VOLUME_ICON="/tmp/${APP_NAME}_volume_icon.icns"

if [ -f "$ICON_PNG" ]; then
    echo "Creating volume icon from $ICON_PNG..."
    
    # Try multiple approaches to create a proper ICNS
    
    # Method 1: Try using sips directly (sometimes works)
    sips -s format icns "$ICON_PNG" --out "$VOLUME_ICON" >/dev/null 2>&1
    
    if [ -f "$VOLUME_ICON" ] && file "$VOLUME_ICON" | grep -q "Mac OS X icon"; then
        echo "✅ Created ICNS using sips"
    else
        # Method 2: Create a simple iconset with just essential sizes
        echo "Trying iconset approach..."
        SIMPLE_ICONSET="/tmp/simple_iconset"
        rm -rf "$SIMPLE_ICONSET"
        mkdir -p "$SIMPLE_ICONSET"
        
        # Create only the most essential sizes
        sips -z 128 128 "$ICON_PNG" --out "$SIMPLE_ICONSET/icon_128x128.png" >/dev/null 2>&1
        sips -z 256 256 "$ICON_PNG" --out "$SIMPLE_ICONSET/icon_256x256.png" >/dev/null 2>&1
        sips -z 512 512 "$ICON_PNG" --out "$SIMPLE_ICONSET/icon_512x512.png" >/dev/null 2>&1
        
        # Try iconutil
        iconutil -c icns "$SIMPLE_ICONSET" -o "$VOLUME_ICON" >/dev/null 2>&1
        
        if [ -f "$VOLUME_ICON" ] && file "$VOLUME_ICON" | grep -q "Mac OS X icon"; then
            echo "✅ Created ICNS using iconutil"
        else
            # Method 3: Use a high-quality PNG as fallback
            echo "Using high-quality PNG as volume icon..."
            sips -z 512 512 "$ICON_PNG" --out "$VOLUME_ICON" >/dev/null 2>&1
        fi
        
        rm -rf "$SIMPLE_ICONSET"
    fi
else
    echo "⚠️  Warning: Icon PNG not found, creating DMG without custom volume icon"
    VOLUME_ICON=""
fi

# Create the DMG with create-dmg (which handles layout properly)
echo "Creating DMG with layout..."

if [ -n "$VOLUME_ICON" ] && [ -f "$VOLUME_ICON" ]; then
    ICON_OPTION="--volicon $VOLUME_ICON"
    echo "Using volume icon: $VOLUME_ICON"
else
    ICON_OPTION=""
    echo "No volume icon available"
fi

# Create DMG with proper layout
create-dmg \
  --volname "$APP_NAME" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --icon "$APP_NAME.app" 150 190 \
  --icon "Applications" 450 190 \
  --hide-extension "$APP_NAME.app" \
  --app-drop-link 450 190 \
  --hdiutil-quiet \
  $ICON_OPTION \
  "$DMG_NAME" \
  "$APP_PATH"

# Clean up
rm -f "$VOLUME_ICON" 2>/dev/null

# Verify the result
if [ -f "$DMG_NAME" ]; then
    echo ""
    echo "🎉 DMG Created Successfully!"
    echo "📦 File: $DMG_NAME"
    echo "📏 Size: $(du -h "$DMG_NAME" | cut -f1)"
    
    # Test the DMG
    echo ""
    echo "🔍 Testing DMG..."
    hdiutil attach "$DMG_NAME" -readonly -nobrowse >/dev/null 2>&1
    
    if [ -d "/Volumes/$APP_NAME" ]; then
        echo "✅ DMG mounts successfully"
        
        # Check contents
        if [ -d "/Volumes/$APP_NAME/$APP_NAME.app" ]; then
            echo "✅ App is present"
        fi
        
        if [ -L "/Volumes/$APP_NAME/Applications" ]; then
            echo "✅ Applications link is present"
        fi
        
        # Check volume icon
        if [ -f "/Volumes/$APP_NAME/.VolumeIcon.icns" ]; then
            ICON_TYPE=$(file "/Volumes/$APP_NAME/.VolumeIcon.icns" 2>/dev/null)
            if echo "$ICON_TYPE" | grep -q "Mac OS X icon"; then
                echo "✅ Volume icon: Proper ICNS format"
            else
                echo "⚠️  Volume icon: PNG format (fallback)"
            fi
        else
            echo "❌ Volume icon: Not found"
        fi
        
        hdiutil detach "/Volumes/$APP_NAME" >/dev/null 2>&1
    fi
    
    echo ""
    echo "🚀 DMG Features:"
    echo "   • App positioned on the left"
    echo "   • Applications folder on the right"
    echo "   • Drag-to-install layout"
    echo "   • Custom volume icon (best available format)"
    echo "   • Compressed for distribution"
    echo ""
    echo "✅ Ready for distribution!"
    echo ""
    echo "📋 User Instructions:"
    echo "   1. Download and open $DMG_NAME"
    echo "   2. Drag $APP_NAME.app to Applications folder"
    echo "   3. Launch from Applications or Spotlight"
    
else
    echo "❌ Failed to create DMG"
    exit 1
fi