# MEE Setup Guide

## Prerequisites

Before starting, ensure you have:

1. **Flutter SDK** (3.10 or higher)
   ```bash
   flutter doctor
   ```

2. **Firebase CLI**
   ```bash
   npm install -g firebase-tools
   firebase login
   ```

3. **Android Studio** or **Xcode** for mobile development

4. **Git** for version control

---

## Step-by-Step Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create Project"
3. Name it `mee-app` (or your preferred name)
4. Enable Google Analytics (optional but recommended)
5. Accept terms and create

### 2. Configure FlutterFire

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# In your project directory
flutterfire configure
```

Select your Firebase project and platforms (iOS, Android).

### 3. Enable Firebase Services

#### Authentication
1. Go to **Authentication** → **Sign-in method**
2. Enable:
   - **Email/Password** (enable Email link if desired)
   - **Google** (add SHA-1 fingerprint from `cd android && ./gradlew signingReport`)
   - **Apple** (requires Apple Developer account)

#### Firestore Database
1. Go to **Firestore Database** → **Create database**
2. Choose **Start in production mode**
3. Select region closest to your users
4. Deploy security rules (see `firestore.rules`)

#### Storage
1. Go to **Storage** → **Get started**
2. Choose **Start in production mode**
3. Set security rules:
   ```
   rules_version = '2';
   service firebase.storage {
     match /b/{bucket}/o {
       match /users/{userId}/{allPaths=**} {
         allow read: if request.auth != null;
         allow write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

#### Cloud Functions
1. Go to **Functions** → **Get started**
2. Upgrade to Blaze plan (pay-as-you-go) for external API calls

### 4. Configure API Keys

#### Stripe (Payments)
1. Create account at [Stripe](https://stripe.com)
2. Get API keys from Dashboard
3. Add to Firebase config:
   ```bash
   firebase functions:config:set stripe.secret_key="sk_test_..."
   firebase functions:config:set stripe.webhook_secret="whsec_..."
   ```

#### AI Services
1. **Hugging Face**: Get token from [settings](https://huggingface.co/settings/tokens)
2. **Replicate**: Get token from [dashboard](https://replicate.com/account/api-tokens)
3. Add to your app constants or environment variables

### 5. Deploy Cloud Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

### 6. Run the App

```bash
# Get dependencies
flutter pub get

# Run on device
flutter run

# Or run with flavor
flutter run --flavor dev
```

---

## Development Workflow

### Adding a New Feature

1. **Domain Layer**
   - Add entity to `lib/domain/entities/`
   - Add repository interface to `lib/domain/repositories/`

2. **Data Layer**
   - Add model to `lib/data/models/`
   - Implement repository in `lib/data/repositories/`

3. **Presentation Layer**
   - Create BLoC in `lib/features/<feature>/presentation/bloc/`
   - Create UI in `lib/features/<feature>/presentation/pages/`

4. **Dependency Injection**
   - Register in `lib/injection_container.dart`

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

---

## Common Issues

### Issue: `FirebaseAuthException` - API key invalid

**Solution**: 
- Ensure `google-services.json` and `GoogleService-Info.plist` are in correct locations
- Run `flutter clean && flutter pub get`

### Issue: Cloud Functions deployment fails

**Solution**:
- Ensure you're on Blaze plan
- Check `firebase functions:log` for errors
- Verify Node.js version (18)

### Issue: Stripe payments not working

**Solution**:
- Verify Stripe keys are set correctly
- Check webhook endpoint is configured in Stripe Dashboard
- Use test mode keys for development

### Issue: AI generation fails

**Solution**:
- Verify API keys for Hugging Face/Replicate
- Check rate limits on free tiers
- Consider upgrading to paid plans for production

---

## Production Checklist

### Security
- [ ] Update Firestore rules for production
- [ ] Enable App Check
- [ ] Configure CORS for Storage
- [ ] Use production Stripe keys
- [ ] Enable Firebase Analytics

### Performance
- [ ] Enable Firestore indexes
- [ ] Configure CDN for Storage
- [ ] Optimize images before upload
- [ ] Enable caching

### Monitoring
- [ ] Set up Crashlytics
- [ ] Configure Performance Monitoring
- [ ] Set up alerts for errors
- [ ] Monitor costs

### Legal
- [ ] Add Privacy Policy
- [ ] Add Terms of Service
- [ ] Add Cookie Policy (if applicable)
- [ ] Configure GDPR compliance

---

## Deployment

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

Upload to Google Play Console:
1. Create app in [Play Console](https://play.google.com/console)
2. Fill store listing
3. Upload AAB file
4. Configure pricing and distribution

### iOS

```bash
# Build IPA
flutter build ipa --release
```

Upload to App Store Connect:
1. Archive in Xcode
2. Upload to App Store Connect
3. Fill App Store information
4. Submit for review

---

## Support

For issues and questions:
- Check [Flutter documentation](https://docs.flutter.dev)
- Check [Firebase documentation](https://firebase.google.com/docs)
- Open issue on GitHub
- Contact: support@mee.app
