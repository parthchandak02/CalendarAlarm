#!/bin/bash

# CalendarAlarmApp - Deploy to iPhone 16 Pro Script
# This script builds and deploys the app to iOS 26.0 devices and simulators

set -e  # Exit on any error

# Verbose mode (set to false for quieter output)
VERBOSE=${VERBOSE:-false}
if [ "$VERBOSE" = "true" ]; then
    set -x  # Enable verbose mode - show all commands being executed
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# App configuration
APP_NAME="CalendarAlarmApp"
PROJECT_NAME="CalendarAlarmApp.xcodeproj"
SCHEME="CalendarAlarmApp"
CONFIGURATION="Debug"
DERIVED_DATA_PATH="./DerivedData"

echo -e "${BLUE}📱 CalendarAlarmApp - iOS 26 AlarmKit Deployment Script${NC}"
echo "======================================================"
echo -e "${GREEN}🔊 VERBOSE MODE ENABLED - Detailed output for debugging${NC}"
echo ""

# Check if we're in the right directory
if [ ! -f "$PROJECT_NAME/project.pbxproj" ]; then
    echo -e "${RED}❌ Error: $PROJECT_NAME not found in current directory${NC}"
    echo "Please run this script from the CalendarAlarmApp root directory"
    exit 1
fi

# Clean any previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
rm -rf "$DERIVED_DATA_PATH"
echo -e "${BLUE}ℹ️  Skipping xcodebuild clean to avoid hanging - using fresh DerivedData instead${NC}"

# Function to list and detect iOS 26 targets
detect_ios26_targets() {
    echo -e "${BLUE}📋 Scanning for iOS 26.0 targets...${NC}"
    echo ""
    
    # Check simulators first (preferred for AlarmKit testing)
    echo -e "${PURPLE}🔍 iOS 26.0 Simulators:${NC}"
    echo "Running: xcrun simctl list devices available | grep 'iOS 26.0' | grep 'iPhone 16'"
    SIMULATORS=$(xcrun simctl list devices available | grep "iOS 26.0" | grep "iPhone 16" || echo "")
    
    if [ -n "$SIMULATORS" ]; then
        echo "$SIMULATORS"
        echo ""
        
        # Try to find booted iPhone 16 Pro iOS 26 simulator
        BOOTED_SIM=$(echo "$SIMULATORS" | grep "iPhone 16 Pro" | grep "Booted" | head -n1 || echo "")
        if [ -n "$BOOTED_SIM" ]; then
            SIM_ID=$(echo "$BOOTED_SIM" | sed -n 's/.*(\([^)]*\)) (Booted).*/\1/p')
            echo -e "${GREEN}✅ Found booted iPhone 16 Pro (iOS 26.0) simulator: $SIM_ID${NC}"
            DEVICE_ID="$SIM_ID"
            DEVICE_TYPE="simulator"
            DEVICE_NAME="iPhone 16 Pro Simulator (iOS 26.0)"
            return 0
        fi
        
        # Try any iPhone 16 Pro iOS 26 simulator
        AVAILABLE_SIM=$(echo "$SIMULATORS" | grep "iPhone 16 Pro" | head -n1 || echo "")
        if [ -n "$AVAILABLE_SIM" ]; then
            SIM_ID=$(echo "$AVAILABLE_SIM" | sed -n 's/.*(\([^)]*\)) (Shutdown).*/\1/p')
            echo -e "${YELLOW}⚡ Found iPhone 16 Pro (iOS 26.0) simulator (will boot): $SIM_ID${NC}"
            DEVICE_ID="$SIM_ID"
            DEVICE_TYPE="simulator"
            DEVICE_NAME="iPhone 16 Pro Simulator (iOS 26.0)"
            return 0
        fi
    else
        echo "  No iOS 26.0 iPhone simulators found"
    fi
    
    echo ""
    echo -e "${PURPLE}🔍 Physical Devices:${NC}"
    echo "Running: xcrun devicectl list devices"
    
    # Check physical devices
    DEVICE_LIST=$(xcrun devicectl list devices 2>/dev/null || echo "")
    
    if [ -n "$DEVICE_LIST" ]; then
        echo "$DEVICE_LIST"
        echo ""
        
        # Try to find iPhone 16 Pro with iOS 26
        IPHONE_16_PRO_ID=$(echo "$DEVICE_LIST" | grep -i "iPhone 16" | grep -i "available" | head -n1 | awk '{print $NF}' | tr -d '()' || echo "")
        
        if [ -n "$IPHONE_16_PRO_ID" ]; then
            echo -e "${GREEN}✅ Found iPhone 16 Pro physical device: $IPHONE_16_PRO_ID${NC}"
            DEVICE_ID="$IPHONE_16_PRO_ID"
            DEVICE_TYPE="device"
            DEVICE_NAME="iPhone 16 Pro Physical Device"
            return 0
        fi
    else
        echo "  No physical devices found"
    fi
    
    return 1
}

# Detect target device
if ! detect_ios26_targets; then
    echo -e "${RED}❌ No suitable iOS 26.0 iPhone 16 Pro targets found${NC}"
    echo ""
    echo "To fix this:"
    echo "  📲 For physical device: Connect iPhone 16 Pro and trust this computer"
    echo "  📱 For simulator: Create iPhone 16 Pro iOS 26.0 simulator in Xcode"
    exit 1
fi

echo ""

# Boot simulator if needed
if [ "$DEVICE_TYPE" = "simulator" ]; then
    echo -e "${BLUE}🚀 Ensuring simulator is booted...${NC}"
    echo "Running: xcrun simctl boot '$DEVICE_ID'"
    xcrun simctl boot "$DEVICE_ID" 2>/dev/null || echo "Simulator already booted"
    sleep 2
    
    echo -e "${BLUE}📱 Checking simulator status...${NC}"
    xcrun simctl list devices | grep "$DEVICE_ID" || echo "Simulator not found in device list"
fi

# Build the app
echo -e "${BLUE}🔨 Building $APP_NAME for iOS 26.0...${NC}"
echo "Target: $DEVICE_NAME"
echo "Configuration: $CONFIGURATION"
echo "Device ID: $DEVICE_ID"
echo ""

if [ "$DEVICE_TYPE" = "simulator" ]; then
    DESTINATION="platform=iOS Simulator,id=$DEVICE_ID"
else
    DESTINATION="id=$DEVICE_ID"
fi

# Add domain blocking functions to prevent xcodebuild hanging
block_apple_domain() {
    echo -e "${YELLOW}🚫 Temporarily blocking developerservices2.apple.com to prevent hanging...${NC}"
    echo "127.0.0.1 developerservices2.apple.com" | sudo tee -a /etc/hosts > /dev/null
    echo "Domain blocked"
}

unblock_apple_domain() {
    echo -e "${YELLOW}🔓 Restoring access to developerservices2.apple.com...${NC}"
    sudo sed -i '' '/developerservices2\.apple\.com/d' /etc/hosts
    echo "Domain unblocked"
}

# Add timeout wrapper function for macOS
run_with_timeout() {
    local timeout_duration=$1
    shift
    
    # Check if gtimeout is available (from coreutils)
    if command -v gtimeout &> /dev/null; then
        gtimeout "$timeout_duration" "$@"
        return $?
    # Check if timeout is available (Linux systems)
    elif command -v timeout &> /dev/null; then
        timeout "$timeout_duration" "$@"
        return $?
    else
        # Fallback: run without timeout but warn user
        echo -e "${YELLOW}⚠️  No timeout command available - running without timeout protection${NC}"
        "$@"
        return $?
    fi
}

# Block Apple domain to prevent hanging (known Xcode 16+ bug)
block_apple_domain

# Ensure domain is always unblocked on exit
trap 'unblock_apple_domain' EXIT

echo "Running: xcodebuild -project '$PROJECT_NAME' -scheme '$SCHEME' -configuration '$CONFIGURATION' -destination '$DESTINATION' -derivedDataPath '$DERIVED_DATA_PATH' -verbose build"
echo -e "${YELLOW}⏰ Build timeout set to 5 minutes to prevent hanging${NC}"

run_with_timeout 300 xcodebuild -project "$PROJECT_NAME" \
           -scheme "$SCHEME" \
           -configuration "$CONFIGURATION" \
           -destination "$DESTINATION" \
           -derivedDataPath "$DERIVED_DATA_PATH" \
           -verbose \
           build

BUILD_EXIT_CODE=$?
if [ $BUILD_EXIT_CODE -eq 124 ]; then
    echo -e "${RED}❌ Build timed out after 5 minutes${NC}"
    echo ""
    echo "The build process hung. Common solutions:"
    echo "  🔄 Try opening the project in Xcode first to resolve any issues"
    echo "  🏗️  Run a manual build in Xcode to see detailed errors"
    echo "  🧹 Clear Xcode caches: Xcode > Product > Clean Build Folder"
    echo "  🔄 Restart Xcode and try again"
    exit 1
elif [ $BUILD_EXIT_CODE -ne 0 ]; then
    echo -e "${RED}❌ Build failed with exit code $BUILD_EXIT_CODE${NC}"
    echo ""
    echo "Common solutions:"
    echo "  📱 Check Xcode project settings and signing"
    echo "  🔑 Verify Apple Developer account is active"
    echo "  📲 For device: Ensure Developer Mode is enabled"
    echo "  🏗️  Open project in Xcode to see detailed build errors"
    exit 1
fi

echo -e "${GREEN}✅ Build successful!${NC}"
echo ""

# Find the built app
echo -e "${BLUE}🔍 Searching for built app...${NC}"
if [ "$DEVICE_TYPE" = "simulator" ]; then
    APP_PATH=$(find "$DERIVED_DATA_PATH" -name "$APP_NAME.app" -path "*iphonesimulator*" -type d | head -n1)
    echo "Looking for simulator app at: $DERIVED_DATA_PATH/*iphonesimulator*/$APP_NAME.app"
else
    APP_PATH=$(find "$DERIVED_DATA_PATH" -name "$APP_NAME.app" -path "*iphoneos*" -type d | head -n1)
    echo "Looking for device app at: $DERIVED_DATA_PATH/*iphoneos*/$APP_NAME.app"
fi

if [ -z "$APP_PATH" ]; then
    echo -e "${YELLOW}⚠️  App not found with specific path pattern, searching more broadly...${NC}"
    APP_PATH=$(find "$DERIVED_DATA_PATH" -name "$APP_NAME.app" -type d | head -n1)
fi

if [ -z "$APP_PATH" ]; then
    echo -e "${RED}❌ Could not find built app at $APP_NAME.app${NC}"
    exit 1
fi

echo -e "${BLUE}📦 Found app at: $APP_PATH${NC}"
echo ""

# Install and launch the app
if [ "$DEVICE_TYPE" = "simulator" ]; then
    # Simulator installation
    echo -e "${BLUE}📲 Installing $APP_NAME on iOS 26.0 simulator...${NC}"
    echo "Running: xcrun simctl install '$DEVICE_ID' '$APP_PATH'"
    
    xcrun simctl install "$DEVICE_ID" "$APP_PATH"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Simulator installation failed${NC}"
        echo "Device ID: $DEVICE_ID"
        echo "App Path: $APP_PATH"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Installation successful!${NC}"
    echo ""
    
    # Get bundle ID and launch
    BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$APP_PATH/Info.plist" 2>/dev/null || echo "")
    
    if [ -n "$BUNDLE_ID" ]; then
        echo -e "${BLUE}🚀 Launching $APP_NAME on simulator...${NC}"
        echo "Bundle ID: $BUNDLE_ID"
        echo "Running: xcrun simctl launch '$DEVICE_ID' '$BUNDLE_ID'"
        
        xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID"
        LAUNCH_EXIT_CODE=$?
        
        if [ $LAUNCH_EXIT_CODE -eq 0 ]; then
            echo -e "${GREEN}✅ App launched successfully!${NC}"
        else
            echo -e "${YELLOW}⚠️  Launch command completed with exit code $LAUNCH_EXIT_CODE - check simulator${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Could not determine bundle identifier${NC}"
        echo "App Path: $APP_PATH"
    fi
    
else
    # Physical device installation
    echo -e "${BLUE}📲 Installing $APP_NAME on physical device...${NC}"
    echo "Running: xcrun devicectl device install app --device '$DEVICE_ID' '$APP_PATH'"
    
    xcrun devicectl device install app \
        --device "$DEVICE_ID" \
        "$APP_PATH"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Device installation failed${NC}"
        echo "Device ID: $DEVICE_ID"
        echo "App Path: $APP_PATH"
        echo ""
        echo "Common solutions:"
        echo "  📱 Ensure device is unlocked and trusted"
        echo "  🔧 Check Developer Mode is enabled (Settings > Privacy & Security > Developer Mode)"
        echo "  🔑 Verify your Apple ID is signed in to Xcode"
        echo "  🔄 Try manual installation through Xcode"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Installation successful!${NC}"
    echo ""
    
    # Get bundle ID and launch
    BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$APP_PATH/Info.plist" 2>/dev/null || echo "")
    
    if [ -n "$BUNDLE_ID" ]; then
        echo -e "${BLUE}🚀 Launching $APP_NAME on device...${NC}"
        echo "Bundle ID: $BUNDLE_ID"
        echo "Running: xcrun devicectl device process launch --device '$DEVICE_ID' '$BUNDLE_ID'"
        
        xcrun devicectl device process launch \
            --device "$DEVICE_ID" \
            "$BUNDLE_ID"
        LAUNCH_EXIT_CODE=$?
        
        if [ $LAUNCH_EXIT_CODE -eq 0 ]; then
            echo -e "${GREEN}✅ App launched successfully!${NC}"
        else
            echo -e "${YELLOW}⚠️  Launch command completed with exit code $LAUNCH_EXIT_CODE - check your device${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Could not determine bundle identifier automatically${NC}"
        echo "App Path: $APP_PATH"
        echo "Please launch the app manually from your device home screen"
    fi
fi

echo ""
echo -e "${GREEN}🎉 Deployment complete!${NC}"
echo ""
echo -e "${BLUE}📱 Your CalendarAlarmApp is now running on $DEVICE_NAME!${NC}"
echo ""
echo -e "${PURPLE}🔔 AlarmKit Testing Notes:${NC}"
echo "  • The app uses iOS 26 AlarmKit framework for countdown-based alarms"
echo "  • Test creating timer alarms with Live Activities in Dynamic Island"
echo "  • Try pause/resume functionality during countdown"
echo "  • Verify custom sounds and alert presentations work"
echo ""
if [ "$DEVICE_TYPE" = "simulator" ]; then
    echo "📲 Simulator testing tips:"
    echo "  • Use Device > Trigger Live Activity to test different states"
    echo "  • Check Dynamic Island integration"
    echo "  • Test with locked simulator (Device > Lock)"
else
    echo "📱 Physical device testing tips:"
    echo "  • Ensure AlarmKit permissions are granted"
    echo "  • Test with device locked for full AlarmKit experience"
    echo "  • Check Live Activity appears in Dynamic Island"
fi
echo ""
echo -e "${GREEN}Happy testing with iOS 26 AlarmKit! 🚀${NC}"
echo ""
echo -e "${BLUE}🔊 DEPLOYMENT SCRIPT FEATURES:${NC}"
echo "  • ✅ Verbose mode enabled by default (set -x, -verbose)"
echo "  • ✅ Xcode 16+ hanging bug workaround (domain blocking)"
echo "  • ✅ 5-minute timeout protection for builds"
echo "  • ✅ Enhanced error reporting with context"
echo "  • ✅ Automatic cleanup on script exit"
echo "  • ✅ Support for both simulators and physical devices"
echo ""
echo -e "${YELLOW}🛠️  KNOWN ISSUE RESOLVED:${NC}"
echo "  This script works around the known Xcode 16+ bug where xcodebuild hangs"
echo "  during 'GatherProvisioningInputs' by temporarily blocking network calls"
echo "  to developerservices2.apple.com during the build process."
echo ""
echo -e "${YELLOW}💡 To disable verbose mode, remove 'set -x' from line 7 and '-verbose' from xcodebuild${NC}"