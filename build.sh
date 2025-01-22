#!/bin/bash
set -e

echo "Cleaning previous builds..."
rm -rf .build StemDiffer.app StemDiffer.zip

echo "Building app..."
swift build -c release

echo "Creating app bundle..."
mkdir -p StemDiffer.app/Contents/{MacOS,Resources}
cp .build/release/StemDiffer StemDiffer.app/Contents/MacOS/
cp Info.plist StemDiffer.app/Contents/

# copy and set up app icon
mkdir -p StemDiffer.app/Contents/Resources
cp AppIcon.png StemDiffer.app/Contents/Resources/AppIcon.icns

echo "APPL????" > StemDiffer.app/Contents/PkgInfo

echo "Setting permissions..."
find StemDiffer.app -type f -exec chmod 644 {} \;
find StemDiffer.app -type d -exec chmod 755 {} \;
chmod 755 StemDiffer.app/Contents/MacOS/StemDiffer

echo "Creating zip..."
# Use ditto instead of zip to preserve bundle attributes
ditto -c -k --sequesterRsrc --keepParent StemDiffer.app StemDiffer.zip

echo "Build complete. Check StemDiffer.zip" 