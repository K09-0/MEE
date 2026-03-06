/// Application-wide constants for MEE App
/// 
/// Содержит все константы приложения: строки, размеры, API endpoints
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation
  
  // App Info
  static const String appName = 'MEE';
  static const String appFullName = 'MicroExperiential Engine';
  static const String appTagline = 'Create. Share. Earn.';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // API Endpoints
  static const String baseApiUrl = 'https://api.mee.app/v1';
  static const String aiApiUrl = 'https://ai.mee.app/v1';
  
  // AI Service Endpoints (Free/Open Source alternatives)
  static const String stableDiffusionUrl = 'https://api.stability.ai/v1';
  static const String huggingFaceUrl = 'https://api-inference.huggingface.co';
  static const String replicateUrl = 'https://api.replicate.com/v1';
  
  // Payment Configuration
  static const String stripePublishableKey = 'pk_test_YOUR_KEY';
  static const String stripeMerchantId = 'merchant.com.mee.app';
  static const String solanaNetwork = 'devnet'; // 'mainnet-beta' for production
  static const String solanaRpcUrl = 'https://api.devnet.solana.com';
  static const String tonNetwork = 'testnet'; // 'mainnet' for production
  
  // Pricing
  static const double minExperiencePrice = 0.99;
  static const double maxExperiencePrice = 4.99;
  static const double platformFeePercent = 0.20; // 20% platform fee
  static const double creatorSharePercent = 0.80; // 80% to creator
  static const double referralBonusPercent = 0.10; // 10% referral bonus
  
  // AI Limits
  static const int freeDailyGenerations = 3;
  static const int proDailyGenerations = 50;
  static const double generationTokenCost = 0.5; // Cost per generation in tokens
  
  // Experience Settings
  static const Duration defaultExperienceDuration = Duration(hours: 24);
  static const Duration maxExperienceDuration = Duration(days: 7);
  static const Duration minExperienceDuration = Duration(hours: 1);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Cache Settings
  static const Duration cacheValidDuration = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100 MB
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Rate Limiting
  static const int maxRequestsPerMinute = 60;
  static const int maxAuthAttemptsPerHour = 10;
  
  // Deep Link Configuration
  static const String appScheme = 'mee';
  static const String appHost = 'app.mee.com';
  static const String referralParam = 'ref';
  static const String experienceParam = 'exp';
  
  // Social Share Configuration
  static const String shareBaseUrl = 'https://mee.app';
  static const String twitterShareUrl = 'https://twitter.com/intent/tweet';
  static const String facebookShareUrl = 'https://www.facebook.com/sharer/sharer.php';
  
  // Content Moderation
  static const List<String> prohibitedWords = [
    'spam', 'scam', 'fake', 'illegal', 'hate', 'violence',
  ];
  static const double contentSafetyThreshold = 0.7;
  
  // Age Verification
  static const int minimumAge = 10;
  static const int adultContentAge = 18;
  
  // File Upload Limits
  static const int maxImageSize = 10 * 1024 * 1024; // 10 MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100 MB
  static const int maxAudioSize = 50 * 1024 * 1024; // 50 MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedVideoTypes = ['mp4', 'mov', 'avi'];
  static const List<String> allowedAudioTypes = ['mp3', 'wav', 'aac', 'ogg'];
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 20.0;
  static const double cardElevation = 4.0;
  static const double buttonHeight = 56.0;
  static const double inputHeight = 56.0;
  static const double iconSize = 24.0;
  static const double avatarSize = 48.0;
  static const double largeAvatarSize = 80.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 2);
  
  // Haptic Feedback
  static const bool enableHapticOnPurchase = true;
  static const bool enableHapticOnLike = true;
  static const bool enableHapticOnShare = true;
  
  // Feature Flags
  static const bool enableCryptoPayments = true;
  static const bool enableNFTGallery = false; // Disabled for MVP
  static const bool enableAdvancedAnalytics = false; // Disabled for MVP
  static const bool enableLiveStreaming = false; // Future feature
  static const bool enableCollaborativeCreation = false; // Future feature
}

/// Asset paths
class AssetPaths {
  AssetPaths._();
  
  // Images
  static const String logo = 'assets/images/logo.png';
  static const String logoWhite = 'assets/images/logo_white.png';
  static const String placeholderAvatar = 'assets/images/placeholders/avatar.png';
  static const String placeholderImage = 'assets/images/placeholders/image.png';
  static const String placeholderAudio = 'assets/images/placeholders/audio.png';
  
  // Onboarding
  static const String onboarding1 = 'assets/images/onboarding/onboarding_1.png';
  static const String onboarding2 = 'assets/images/onboarding/onboarding_2.png';
  static const String onboarding3 = 'assets/images/onboarding/onboarding_3.png';
  
  // Animations
  static const String loadingAnimation = 'assets/animations/loading/loading.json';
  static const String successAnimation = 'assets/animations/success/success.json';
  static const String emptyAnimation = 'assets/animations/empty.json';
  static const String errorAnimation = 'assets/animations/error.json';
  
  // Icons
  static const String homeIcon = 'assets/images/icons/home.svg';
  static const String createIcon = 'assets/images/icons/create.svg';
  static const String walletIcon = 'assets/images/icons/wallet.svg';
  static const String profileIcon = 'assets/images/icons/profile.svg';
}

/// Error Messages
class ErrorMessages {
  ErrorMessages._();
  
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection. Please check your network.';
  static const String timeoutError = 'Request timed out. Please try again.';
  static const String unauthorizedError = 'Session expired. Please log in again.';
  static const String notFoundError = 'Resource not found.';
  static const String serverError = 'Server error. Please try again later.';
  static const String validationError = 'Please check your input and try again.';
  static const String paymentError = 'Payment failed. Please try again.';
  static const String aiGenerationError = 'AI generation failed. Please try again.';
  static const String insufficientFunds = 'Insufficient funds. Please add more.';
  static const String dailyLimitReached = 'Daily limit reached. Upgrade to Pro or try tomorrow.';
  static const String contentFlagged = 'Content flagged for review. Please try different content.';
}

/// Success Messages
class SuccessMessages {
  SuccessMessages._();
  
  static const String loginSuccess = 'Welcome back!';
  static const String registerSuccess = 'Account created successfully!';
  static const String purchaseSuccess = 'Purchase completed!';
  static const String creationSuccess = 'Experience created successfully!';
  static const String shareSuccess = 'Shared successfully!';
  static const String withdrawalSuccess = 'Withdrawal initiated!';
  static const String profileUpdateSuccess = 'Profile updated!';
}
