#!/bin/bash

# ==========================================
# MEE App - APK Build Script
# ==========================================

set -e

echo "=========================================="
echo "  MEE App - Building APK"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter is not installed${NC}"
    echo "Please install Flutter first: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check Flutter version
echo -e "${YELLOW}Checking Flutter version...${NC}"
flutter --version

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
flutter clean

# Get dependencies
echo -e "${YELLOW}Getting dependencies...${NC}"
flutter pub get

# Analyze code
echo -e "${YELLOW}Analyzing code...${NC}"
flutter analyze

# Run tests (optional)
# echo -e "${YELLOW}Running tests...${NC}"
# flutter test

# Build APK
echo -e "${YELLOW}Building APK...${NC}"
flutter build apk --release

# Check if build succeeded
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo -e "${GREEN}==========================================${NC}"
    echo -e "${GREEN}  APK Build Successful!${NC}"
    echo -e "${GREEN}==========================================${NC}"
    echo ""
    echo "APK Location: build/app/outputs/flutter-apk/app-release.apk"
    echo ""
    ls -lh build/app/outputs/flutter-apk/app-release.apk
    echo ""
    echo -e "${GREEN}You can install the APK with:${NC}"
    echo "  adb install build/app/outputs/flutter-apk/app-release.apk"
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi
