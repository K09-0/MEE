# ==========================================
# MEE App - Makefile
# ==========================================

.PHONY: help clean deps analyze test build-apk build-aab build-ios install run

# Default target
help:
	@echo "MEE App - Available commands:"
	@echo ""
	@echo "  make clean       - Clean build artifacts"
	@echo "  make deps        - Install dependencies"
	@echo "  make analyze     - Analyze code"
	@echo "  make test        - Run tests"
	@echo "  make build-apk   - Build release APK"
	@echo "  make build-aab   - Build App Bundle"
	@echo "  make build-ios   - Build iOS release"
	@echo "  make install     - Install APK to connected device"
	@echo "  make run         - Run app in debug mode"
	@echo ""

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	flutter clean
	cd android && ./gradlew clean 2>/dev/null || true

# Install dependencies
deps:
	@echo "Installing dependencies..."
	flutter pub get

# Analyze code
analyze:
	@echo "Analyzing code..."
	flutter analyze

# Run tests
test:
	@echo "Running tests..."
	flutter test

# Build release APK
build-apk: clean deps
	@echo "Building release APK..."
	flutter build apk --release
	@echo ""
	@echo "APK built successfully!"
	@echo "Location: build/app/outputs/flutter-apk/app-release.apk"
	@ls -lh build/app/outputs/flutter-apk/app-release.apk

# Build App Bundle for Google Play
build-aab: clean deps
	@echo "Building App Bundle..."
	flutter build appbundle --release
	@echo ""
	@echo "AAB built successfully!"
	@echo "Location: build/app/outputs/bundle/release/app-release.aab"

# Build iOS release
build-ios: clean deps
	@echo "Building iOS release..."
	flutter build ios --release

# Install APK to connected device
install:
	@echo "Installing APK..."
	adb install build/app/outputs/flutter-apk/app-release.apk

# Run app in debug mode
run:
	@echo "Running app in debug mode..."
	flutter run

# Full build pipeline
all: clean deps analyze build-apk
	@echo "Build pipeline completed!"
