# MEE App - Deployment Guide

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Firebase Setup](#firebase-setup)
3. [Environment Configuration](#environment-configuration)
4. [iOS Deployment](#ios-deployment)
5. [Android Deployment](#android-deployment)
6. [Payment Integration](#payment-integration)
7. [AI Service Setup](#ai-service-setup)
8. [Post-Deployment](#post-deployment)

---

## Prerequisites

### Required Tools

- **Flutter SDK** (>=3.0.0)
- **Dart SDK** (>=3.0.0)
- **Firebase CLI**
- **Node.js** (>=16.0.0) for Firebase Functions
- **Android Studio** (for Android builds)
- **Xcode** (>=14.0, for iOS builds)
- **CocoaPods** (for iOS dependencies)

### Install Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

---

## Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `mee-app-prod`
4. Enable Google Analytics (recommended)
5. Select Analytics account
6. Click "Create Project"

### 2. Register Apps

#### Android App

1. In Firebase Console, click "Add App" → Android
2. Package name: `com.mee.app`
3. App nickname: `MEE Android`
4. Download `google-services.json`
5. Place in `android/app/`

#### iOS App

1. Click "Add App" → iOS
2. Bundle ID: `com.mee.app`
3. App nickname: `MEE iOS`
4. Download `GoogleService-Info.plist`
5. Place in `ios/Runner/` via Xcode

### 3. Configure FlutterFire

```bash
flutterfire configure \
  --project=mee-app-prod \
  --out=lib/firebase_options.dart \
  --ios-bundle-id=com.mee.app \
  --android-app-id=com.mee.app
```

### 4. Enable Firebase Services

#### Authentication

1. Go to **Authentication** → **Sign-in method**
2. Enable providers:
   - ✅ Email/Password
   - ✅ Google
   - ✅ Apple (iOS only)
   - ✅ Anonymous (optional)

#### Firestore Database

1. Go to **Firestore Database** → **Create Database**
2. Start in production mode
3. Select region (recommend: `us-central1` or closest to your users)

**Security Rules:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId;
    }
    
    // Experiences collection
    match /experiences/{experienceId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (resource.data.creatorId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Transactions collection
    match /transactions/{transactionId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         resource.data.sellerId == request.auth.uid);
      allow create: if request.auth != null;
      allow update: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Likes collection
    match /likes/{likeId} {
      allow read: if true;
      allow create, delete: if request.auth != null;
    }
    
    // Shares collection
    match /shares/{shareId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }
    
    // Referrals collection
    match /referrals/{referralId} {
      allow read: if request.auth != null && 
        (resource.data.referrerId == request.auth.uid || 
         resource.data.referredUserId == request.auth.uid);
      allow create: if request.auth != null;
    }
  }
}
```

#### Firebase Storage

1. Go to **Storage** → **Get Started**
2. Select region same as Firestore

**Security Rules:**

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /experiences/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /avatars/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### Cloud Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

### 5. Firebase Dynamic Links

1. Go to **Dynamic Links** → **Get Started**
2. Add URL prefix: `meeapp.page.link`
3. Add domain to `AndroidManifest.xml` and iOS `Info.plist`

---

## Environment Configuration

### 1. Create Environment Files

#### `.env.development`

```env
# API Keys
HUGGING_FACE_API_KEY=your_huggingface_key
REPLICATE_API_KEY=your_replicate_key
STABILITY_API_KEY=your_stability_key

# Payment Keys (Test)
STRIPE_PUBLISHABLE_KEY=pk_test_your_key
STRIPE_SECRET_KEY=sk_test_your_key

# Solana (Devnet)
SOLANA_RPC_URL=https://api.devnet.solana.com

# App Settings
API_BASE_URL=https://api-dev.mee.app
ENABLE_ANALYTICS=false
ENABLE_CRASHLYTICS=false
```

#### `.env.production`

```env
# API Keys
HUGGING_FACE_API_KEY=your_huggingface_key
REPLICATE_API_KEY=your_replicate_key
STABILITY_API_KEY=your_stability_key

# Payment Keys (Live)
STRIPE_PUBLISHABLE_KEY=pk_live_your_key
STRIPE_SECRET_KEY=sk_live_your_key

# Solana (Mainnet)
SOLANA_RPC_URL=https://api.mainnet-beta.solana.com

# App Settings
API_BASE_URL=https://api.mee.app
ENABLE_ANALYTICS=true
ENABLE_CRASHLYTICS=true
```

### 2. Add to .gitignore

```
.env*
!.env.example
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

### 3. Load Environment in main.dart

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment
  await dotenv.load(fileName: '.env.production');
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await di.init();
  runApp(const MEEApp());
}
```

---

## iOS Deployment

### 1. Apple Developer Account

- Enroll in [Apple Developer Program](https://developer.apple.com/programs/) ($99/year)
- Create App ID in Certificates, Identifiers & Profiles

### 2. Xcode Configuration

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner → Signing & Capabilities
3. Select your Team
4. Enable capabilities:
   - ✅ Push Notifications
   - ✅ Background Modes (Remote Notifications)
   - ✅ Associated Domains (for Dynamic Links)
   - ✅ Sign In with Apple

### 3. App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Create new app:
   - Platform: iOS
   - Bundle ID: `com.mee.app`
   - SKU: `mee-app-001`
   - Name: `MEE - Micro Experiences`

### 4. Build and Upload

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Install pods
cd ios && pod install --repo-update && cd ..

# Build for release
flutter build ipa --release

# Or build and open in Xcode
flutter build ios --release
open ios/Runner.xcworkspace
```

In Xcode:
1. Product → Archive
2. Distribute App → App Store Connect
3. Upload

### 5. App Store Information

Required assets:
- Screenshots (6.5", 5.5", iPad)
- App Icon (1024x1024)
- Description, keywords, support URL
- Privacy policy URL
- App Preview (optional)

---

## Android Deployment

### 1. Google Play Console

- Create [Google Play Developer](https://play.google.com/console/) account ($25 one-time)
- Create new app

### 2. Keystore Setup

```bash
keytool -genkey -v \
  -keystore ~/upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

Create `android/key.properties`:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=/Users/yourname/upload-keystore.jks
```

### 3. Configure Build

Update `android/app/build.gradle`:

```gradle
android {
    // ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 4. Build App Bundle

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build app bundle
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### 5. Upload to Play Console

1. Go to **Production** → **Create Release**
2. Upload AAB file
3. Fill store listing:
   - Screenshots (phone, tablet)
   - Feature graphic (1024x500)
   - App icon (512x512)
   - Description, privacy policy

---

## Payment Integration

### Stripe Setup

1. Create [Stripe Account](https://stripe.com)
2. Get API keys from Dashboard
3. Add webhook endpoint: `https://your-cloud-function/stripe-webhook`
4. Configure in Firebase Functions

### Solana Pay Setup

1. Create Solana wallet for platform
2. Configure in Firebase Functions
3. Set up USDC token account

### TON Connect Setup

1. Register app at [TON Console](https://tonconsole.com/)
2. Get API key
3. Configure manifest URL

---

## AI Service Setup

### Hugging Face

1. Create account at [Hugging Face](https://huggingface.co/)
2. Generate API token
3. Add to environment variables

### Replicate

1. Create account at [Replicate](https://replicate.com/)
2. Get API token
3. Add to environment variables

### Stability AI

1. Create account at [Stability AI](https://stability.ai/)
2. Get API key
3. Add to environment variables

---

## Post-Deployment

### Monitoring

1. **Firebase Analytics**: Track user engagement
2. **Crashlytics**: Monitor crashes
3. **Performance Monitoring**: Track app performance

### App Store Optimization (ASO)

- Keywords: AI, NFT, digital art, creator, marketplace, Gen Z
- Screenshots showing key features
- Regular updates with new features

### Marketing Checklist

- [ ] Social media accounts created
- [ ] Influencer outreach
- [ ] Press kit prepared
- [ ] Landing page live
- [ ] Discord/Telegram community

---

## Troubleshooting

### Common Issues

#### iOS Build Fails

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter build ios
```

#### Android Build Fails

```bash
flutter clean
rm -rf android/.gradle
flutter pub get
cd android
./gradlew clean
flutter build appbundle
```

#### Firebase Connection Issues

- Verify `google-services.json` / `GoogleService-Info.plist`
- Check bundle ID matches Firebase
- Re-run `flutterfire configure`

---

## Support

For deployment issues:
- Firebase Support: https://firebase.google.com/support
- Flutter Issues: https://github.com/flutter/flutter/issues
- Contact: support@mee.app

---

**Last Updated:** 2024
**Version:** 1.0.0
