import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';

/// Viral Repository Interface
/// 
/// Определяет контракт для вирусной механики:
/// - Deep Links
/// - Реферальная система
/// - Social Sharing
abstract class ViralRepository {
  /// Generate deep link for experience
  Future<Either<AppException, String>> generateExperienceDeepLink({
    required String experienceId,
    String? campaign,
    Map<String, String>? additionalParams,
  });

  /// Generate referral deep link
  Future<Either<AppException, String>> generateReferralLink(String referralCode);

  /// Generate profile deep link
  Future<Either<AppException, String>> generateProfileDeepLink(String userId);

  /// Parse incoming deep link
  Future<Either<AppException, DeepLinkData>> parseDeepLink(String url);

  /// Handle deep link
  Future<Either<AppException, void>> handleDeepLink(DeepLinkData data);

  /// Share experience to social media
  Future<Either<AppException, void>> shareExperience({
    required String experienceId,
    required SocialPlatform platform,
    String? customMessage,
  });

  /// Share referral link
  Future<Either<AppException, void>> shareReferral({
    required String referralCode,
    required SocialPlatform platform,
  });

  /// Track share event
  Future<Either<AppException, void>> trackShare({
    required String contentId,
    required SocialPlatform platform,
    required ShareType type,
  });

  /// Get share statistics
  Future<Either<AppException, ShareStats>> getShareStats(String contentId);

  /// Apply referral code
  Future<Either<AppException, ReferralResult>> applyReferralCode(String code);

  /// Get referral code for user
  Future<Either<AppException, String>> getReferralCode(String userId);

  /// Generate QR code for experience
  Future<Either<AppException, String>> generateQRCode(String experienceId);

  /// Copy link to clipboard
  Future<Either<AppException, void>> copyToClipboard(String link);

  /// Initialize deep link listener
  Future<Either<AppException, void>> initDeepLinkListener();

  /// Dispose deep link listener
  Future<Either<AppException, void>> disposeDeepLinkListener();

  /// Stream of incoming deep links
  Stream<DeepLinkData> get deepLinkStream;
}

/// Deep Link Data
class DeepLinkData {
  final DeepLinkType type;
  final String? experienceId;
  final String? userId;
  final String? referralCode;
  final String? campaign;
  final Map<String, String> parameters;
  final String originalUrl;

  const DeepLinkData({
    required this.type,
    this.experienceId,
    this.userId,
    this.referralCode,
    this.campaign,
    this.parameters = const {},
    required this.originalUrl,
  });

  /// Check if this is a referral link
  bool get isReferral => referralCode != null;

  /// Check if this is an experience link
  bool get isExperience => experienceId != null;

  /// Check if this is a profile link
  bool get isProfile => userId != null && experienceId == null;

  factory DeepLinkData.fromUrl(String url) {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    
    DeepLinkType type = DeepLinkType.unknown;
    String? experienceId;
    String? userId;
    String? referralCode;
    
    // Parse path
    if (pathSegments.isNotEmpty) {
      switch (pathSegments[0]) {
        case 'exp':
        case 'experience':
          type = DeepLinkType.experience;
          experienceId = pathSegments.length > 1 ? pathSegments[1] : null;
          break;
        case 'user':
        case 'profile':
          type = DeepLinkType.profile;
          userId = pathSegments.length > 1 ? pathSegments[1] : null;
          break;
        case 'ref':
        case 'referral':
          type = DeepLinkType.referral;
          referralCode = pathSegments.length > 1 ? pathSegments[1] : null;
          break;
      }
    }
    
    // Also check query parameters
    referralCode ??= uri.queryParameters['ref'];
    experienceId ??= uri.queryParameters['exp'];
    userId ??= uri.queryParameters['user'];
    
    return DeepLinkData(
      type: type,
      experienceId: experienceId,
      userId: userId,
      referralCode: referralCode,
      campaign: uri.queryParameters['campaign'],
      parameters: uri.queryParameters,
      originalUrl: url,
    );
  }
}

/// Deep Link Type
enum DeepLinkType {
  experience,
  profile,
  referral,
  promotion,
  unknown,
}

/// Social Platform
enum SocialPlatform {
  tiktok,
  instagram,
  twitter,
  facebook,
  whatsapp,
  telegram,
  snapchat,
  copyLink,
  system,
}

/// Extension for SocialPlatform
extension SocialPlatformExtension on SocialPlatform {
  String get displayName {
    switch (this) {
      case SocialPlatform.tiktok:
        return 'TikTok';
      case SocialPlatform.instagram:
        return 'Instagram';
      case SocialPlatform.twitter:
        return 'X (Twitter)';
      case SocialPlatform.facebook:
        return 'Facebook';
      case SocialPlatform.whatsapp:
        return 'WhatsApp';
      case SocialPlatform.telegram:
        return 'Telegram';
      case SocialPlatform.snapchat:
        return 'Snapchat';
      case SocialPlatform.copyLink:
        return 'Copy Link';
      case SocialPlatform.system:
        return 'More';
    }
  }

  String get icon {
    switch (this) {
      case SocialPlatform.tiktok:
        return '🎵';
      case SocialPlatform.instagram:
        return '📸';
      case SocialPlatform.twitter:
        return '🐦';
      case SocialPlatform.facebook:
        return 'f';
      case SocialPlatform.whatsapp:
        return '💬';
      case SocialPlatform.telegram:
        return '✈️';
      case SocialPlatform.snapchat:
        return '👻';
      case SocialPlatform.copyLink:
        return '🔗';
      case SocialPlatform.system:
        return '•••';
    }
  }

  String get shareUrl {
    switch (this) {
      case SocialPlatform.twitter:
        return 'https://twitter.com/intent/tweet';
      case SocialPlatform.facebook:
        return 'https://www.facebook.com/sharer/sharer.php';
      case SocialPlatform.whatsapp:
        return 'https://wa.me/';
      case SocialPlatform.telegram:
        return 'https://t.me/share/url';
      default:
        return '';
    }
  }

  bool get supportsDirectShare {
    return this == SocialPlatform.copyLink || this == SocialPlatform.system;
  }
}

/// Share Type
enum ShareType {
  experience,
  profile,
  referral,
  achievement,
}

/// Share Statistics
class ShareStats {
  final String contentId;
  final int totalShares;
  final Map<SocialPlatform, int> sharesByPlatform;
  final int clicks;
  final int conversions;
  final double conversionRate;

  const ShareStats({
    required this.contentId,
    required this.totalShares,
    required this.sharesByPlatform,
    required this.clicks,
    required this.conversions,
    required this.conversionRate,
  });
}

/// Referral Result
class ReferralResult {
  final bool success;
  final String? referrerId;
  final String? referrerUsername;
  final String? message;
  final double? bonusAmount;

  const ReferralResult({
    required this.success,
    this.referrerId,
    this.referrerUsername,
    this.message,
    this.bonusAmount,
  });
}

/// Share Template
class ShareTemplate {
  final String title;
  final String description;
  final String? imageUrl;
  final String? hashtags;

  const ShareTemplate({
    required this.title,
    required this.description,
    this.imageUrl,
    this.hashtags,
  });

  /// Get formatted text for platform
  String getFormattedText(SocialPlatform platform) {
    var text = description;
    
    if (hashtags != null && hashtags!.isNotEmpty) {
      switch (platform) {
        case SocialPlatform.twitter:
          text += '\n\n$hashtags';
          break;
        case SocialPlatform.instagram:
          text += '\n\n.$hashtags';
          break;
        case SocialPlatform.tiktok:
          text += ' $hashtags';
          break;
        default:
          text += ' $hashtags';
      }
    }
    
    return text;
  }
}

/// Viral Metrics
class ViralMetrics {
  final double kFactor; // Viral coefficient
  final double viralVelocity; // Shares per day
  final double shareToClickRate;
  final double clickToInstallRate;
  final double clickToPurchaseRate;

  const ViralMetrics({
    required this.kFactor,
    required this.viralVelocity,
    required this.shareToClickRate,
    required this.clickToInstallRate,
    required this.clickToPurchaseRate,
  });

  /// Check if viral (k-factor > 1)
  bool get isViral => kFactor > 1.0;

  /// Get viral score (0-100)
  int get viralScore {
    var score = 0;
    if (kFactor > 0.5) score += 20;
    if (kFactor > 1.0) score += 30;
    if (shareToClickRate > 0.1) score += 20;
    if (clickToInstallRate > 0.05) score += 15;
    if (clickToPurchaseRate > 0.01) score += 15;
    return score.clamp(0, 100);
  }
}
