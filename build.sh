#!/bin/bash

# build the app
rm -rf .build
swift build -c release

# create app bundle structure
rm -rf StemDiffer.app
mkdir -p StemDiffer.app/Contents/MacOS
mkdir -p StemDiffer.app/Contents/Resources

# copy binary and resources
cp .build/release/StemDiffer StemDiffer.app/Contents/MacOS/
cp Info.plist StemDiffer.app/Contents/

# ensure executable permissions
chmod +x StemDiffer.app/Contents/MacOS/StemDiffer

# create PkgInfo
echo "APPL????" > StemDiffer.app/Contents/PkgInfo

# update Info.plist with required keys
/usr/libexec/PlistBuddy -c "Add :LSMinimumSystemVersion string 12.0" StemDiffer.app/Contents/Info.plist 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :NSHighResolutionCapable bool true" StemDiffer.app/Contents/Info.plist 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" StemDiffer.app/Contents/Info.plist 2>/dev/null || true

# sign the app
codesign --force --deep --sign "Developer ID Application" --options runtime StemDiffer.app

# create zip for notarization
ditto -c -k --keepParent StemDiffer.app StemDiffer.zip

# notarize the app
xcrun notarytool submit StemDiffer.zip --keychain-profile "AC_PASSWORD" --wait

# staple the notarization
xcrun stapler staple StemDiffer.app

# create final zip for distribution
ditto -c -k --keepParent StemDiffer.app StemDiffer.zip 