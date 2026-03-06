# MEE - MicroExperiential Engine

<p align="center">
  <img src="assets/images/app_icon.png" width="120" alt="MEE Logo">
</p>

<p align="center">
  <strong>AI-powered micro-experience marketplace for Gen Z</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#deployment">Deployment</a>
</p>

---

## 🚀 Features

### Core Features

- **🔐 Authentication** - Email/Password, Google Sign-In, Apple Sign-In
- **🎨 AI Creator Studio** - Generate images, music, text, and mini-games
- **🛒 Marketplace** - Browse, filter, and purchase micro-experiences
- **💰 Wallet** - Track earnings, withdrawals, and transaction history
- **🔗 Viral Mechanics** - Referral system, deep links, social sharing
- **⏰ FOMO Timers** - Time-limited exclusive content

### Experience Types

| Type | Description | Price Range |
|------|-------------|-------------|
| 🎨 **Digital Art** | AI-generated artwork | $0.99 - $4.99 |
| 🎵 **Music** | AI-composed tracks | $0.99 - $2.99 |
| 🎮 **Mini-Games** | Interactive experiences | $1.99 - $4.99 |
| 📖 **Stories** | AI-generated narratives | $0.99 - $1.99 |

---

## 🛠 Tech Stack

### Frontend

- **Flutter 3.x** - Cross-platform UI framework
- **Dart 3.x** - Programming language
- **BLoC Pattern** - State management
- **Material 3** - Design system

### Backend

- **Firebase Auth** - Authentication
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - File storage
- **Cloud Functions** - Serverless functions
- **Firebase Dynamic Links** - Deep linking

### AI Integration

- **Hugging Face** - Text generation, image models
- **Replicate** - Advanced AI models
- **Stability AI** - Image generation

### Payments

- **Stripe** - Credit/debit card payments
- **Solana Pay** - Cryptocurrency payments
- **TON Connect** - TON blockchain payments

---

## 🏗 Architecture

### Clean Architecture

```
lib/
├── core/                    # Core utilities
│   ├── errors/             # Exceptions and failures
│   ├── theme/              # App theme and colors
│   └── utils/              # Helper functions
├── data/                    # Data layer
│   ├── models/             # Data models
│   └── repositories/       # Repository implementations
├── domain/                  # Domain layer
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/           # Business logic
├── features/                # Feature modules
│   ├── auth/               # Authentication
│   ├── creator/            # AI Creator Studio
│   ├── marketplace/        # Browse & Purchase
│   ├── wallet/             # Payments & Earnings
│   └── profile/            # User profile
└── services/               # External services
    ├── ai_service.dart     # AI generation
    └── payment_service.dart # Payment processing
```

### State Management

```
UI → BLoC → Repository → Data Source
         ↓
    State Stream → UI Update
```

---

## 📦 Getting Started

### Prerequisites

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Firebase CLI
- Android Studio / Xcode

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/mee-app.git
cd mee-app
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Configure Firebase**

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```

4. **Set up environment variables**

```bash
cp .env.example .env.development
# Edit .env.development with your API keys
```

5. **Run the app**

```bash
flutter run
```

---

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

---

## 🚀 Deployment

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed deployment instructions.

### Quick Deploy

```bash
# iOS
flutter build ipa --release

# Android
flutter build appbundle --release
```

---

## 📊 Business Model

### Revenue Split

```
┌─────────────────────────────────────┐
│         Purchase: $1.99             │
├─────────────────────────────────────┤
│  Creator: 80%      │   $1.59        │
│  Platform: 20%     │   $0.40        │
│  Referral: 10%*    │   $0.20        │
└─────────────────────────────────────┘
* When referral code is used
```

### Key Metrics

- **Target Audience**: Gen Z (18-25)
- **Price Range**: $0.99 - $4.99
- **Creator Earnings**: 70-80%
- **Platform Fee**: 20%
- **Referral Bonus**: 10%

---

## 🎨 Design System

### Colors

| Name | Hex | Usage |
|------|-----|-------|
| Primary | `#7B2FF7` | Buttons, accents |
| Secondary | `#00D4AA` | Success, highlights |
| Background | `#0A0A0F` | Main background |
| Surface | `#141419` | Cards, inputs |
| Error | `#FF4D4D` | Errors, warnings |

### Typography

- **Display**: Inter Bold
- **Headline**: Inter SemiBold
- **Body**: Inter Regular
- **Caption**: Inter Medium

---

## 🔐 Security

- ✅ Firebase Authentication with secure tokens
- ✅ Firestore Security Rules
- ✅ Input validation and sanitization
- ✅ Rate limiting on API calls
- ✅ Secure payment processing
- ✅ Data encryption at rest

---

## 📱 Screenshots

<p align="center">
  <img src="screenshots/feed.png" width="200" alt="Feed">
  <img src="screenshots/creator.png" width="200" alt="Creator Studio">
  <img src="screenshots/wallet.png" width="200" alt="Wallet">
  <img src="screenshots/profile.png" width="200" alt="Profile">
</p>

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use `dart format` before committing
- Run `flutter analyze` to check for issues

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev) for the amazing framework
- [Firebase](https://firebase.google.com) for backend services
- [Hugging Face](https://huggingface.co) for AI models
- [Replicate](https://replicate.com) for AI infrastructure

---

## 📞 Contact

- Website: [https://mee.app](https://mee.app)
- Email: support@mee.app
- Twitter: [@mee_app](https://twitter.com/mee_app)
- Discord: [Join our community](https://discord.gg/mee)

---

<p align="center">
  Made with 💜 by the MEE Team
</p>
