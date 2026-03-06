import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../entities/experience.dart';

/// AI Repository Interface
/// 
/// Определяет контракт для AI-генерации контента
/// Использует агрегатор API для различных AI сервисов
abstract class AIRepository {
  /// Generate image from prompt (Stable Diffusion)
  Future<Either<AppException, AIGenerationResult>> generateImage({
    required String prompt,
    String? negativePrompt,
    AIImageStyle? style,
    AIImageSize size = AIImageSize.square,
    int? seed,
  });

  /// Generate text content (story, poem, script)
  Future<Either<AppException, AIGenerationResult>> generateText({
    required String prompt,
    required TextContentType contentType,
    int? maxLength,
    String? tone,
    String? language,
  });

  /// Generate music/audio (Suno/Udio alternative)
  Future<Either<AppException, AIGenerationResult>> generateAudio({
    required String prompt,
    required AudioType audioType,
    int? duration,
    String? genre,
    String? mood,
  });

  /// Generate mini-game concept
  Future<Either<AppException, AIGenerationResult>> generateGameConcept({
    required String prompt,
    GameType? gameType,
    String? difficulty,
  });

  /// Enhance prompt (make it better for AI generation)
  Future<Either<AppException, String>> enhancePrompt({
    required String prompt,
    required ExperienceType type,
  });

  /// Check content safety (moderation)
  Future<Either<AppException, ContentSafetyResult>> checkContentSafety(
    String content, {
    ContentType contentType = ContentType.text,
  });

  /// Get available generation credits
  Future<Either<AppException, GenerationCredits>> getGenerationCredits(String userId);

  /// Use generation credit
  Future<Either<AppException, GenerationCredits>> useGenerationCredit(String userId);

  /// Purchase additional credits
  Future<Either<AppException, GenerationCredits>> purchaseCredits({
    required String userId,
    required int amount,
    required PaymentMethod paymentMethod,
  });

  /// Get generation history
  Future<Either<AppException, List<AIGenerationResult>>> getGenerationHistory(
    String userId, {
    int page = 1,
    int limit = 20,
  });

  /// Get suggested prompts for type
  Future<Either<AppException, List<String>>> getSuggestedPrompts(ExperienceType type);

  /// Cancel ongoing generation
  Future<Either<AppException, void>> cancelGeneration(String generationId);

  /// Stream generation progress
  Stream<GenerationProgress> generationProgressStream(String generationId);
}

/// AI Generation Result
class AIGenerationResult {
  final String id;
  final String contentUrl;
  final String? thumbnailUrl;
  final ExperienceType type;
  final String prompt;
  final String? enhancedPrompt;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final int creditsUsed;
  final int generationTimeMs;

  const AIGenerationResult({
    required this.id,
    required this.contentUrl,
    this.thumbnailUrl,
    required this.type,
    required this.prompt,
    this.enhancedPrompt,
    this.metadata = const {},
    required this.createdAt,
    this.creditsUsed = 1,
    this.generationTimeMs = 0,
  });
}

/// Generation Progress
class GenerationProgress {
  final String generationId;
  final GenerationStatus status;
  final double progress; // 0.0 to 1.0
  final String? message;
  final String? previewUrl;
  final int? estimatedTimeRemaining;

  const GenerationProgress({
    required this.generationId,
    required this.status,
    this.progress = 0.0,
    this.message,
    this.previewUrl,
    this.estimatedTimeRemaining,
  });

  bool get isComplete => status == GenerationStatus.completed;
  bool get isFailed => status == GenerationStatus.failed;
  bool get isInProgress => status == GenerationStatus.generating;
}

/// Generation Status
enum GenerationStatus {
  pending,
  queued,
  generating,
  completed,
  failed,
  cancelled,
}

/// Generation Credits
class GenerationCredits {
  final String userId;
  final int dailyLimit;
  final int usedToday;
  final int remainingToday;
  final int purchasedCredits;
  final DateTime? lastResetDate;
  final SubscriptionTier tier;

  const GenerationCredits({
    required this.userId,
    required this.dailyLimit,
    required this.usedToday,
    required this.remainingToday,
    this.purchasedCredits = 0,
    this.lastResetDate,
    required this.tier,
  });

  bool get canGenerate => remainingToday > 0 || purchasedCredits > 0;
  int get totalAvailable => remainingToday + purchasedCredits;
}

/// AI Image Style
enum AIImageStyle {
  photorealistic,
  digitalArt,
  anime,
  oilPainting,
  watercolor,
  sketch,
  cyberpunk,
  fantasy,
  abstract,
  minimalist,
  retro,
  pixelArt,
}

/// Extension for AIImageStyle
extension AIImageStyleExtension on AIImageStyle {
  String get displayName {
    switch (this) {
      case AIImageStyle.photorealistic:
        return 'Photorealistic';
      case AIImageStyle.digitalArt:
        return 'Digital Art';
      case AIImageStyle.anime:
        return 'Anime';
      case AIImageStyle.oilPainting:
        return 'Oil Painting';
      case AIImageStyle.watercolor:
        return 'Watercolor';
      case AIImageStyle.sketch:
        return 'Sketch';
      case AIImageStyle.cyberpunk:
        return 'Cyberpunk';
      case AIImageStyle.fantasy:
        return 'Fantasy';
      case AIImageStyle.abstract:
        return 'Abstract';
      case AIImageStyle.minimalist:
        return 'Minimalist';
      case AIImageStyle.retro:
        return 'Retro';
      case AIImageStyle.pixelArt:
        return 'Pixel Art';
    }
  }

  String get promptModifier {
    switch (this) {
      case AIImageStyle.photorealistic:
        return 'photorealistic, highly detailed, 8k, professional photography';
      case AIImageStyle.digitalArt:
        return 'digital art, vibrant colors, detailed illustration';
      case AIImageStyle.anime:
        return 'anime style, manga, Japanese animation';
      case AIImageStyle.oilPainting:
        return 'oil painting, classic art style, textured brushstrokes';
      case AIImageStyle.watercolor:
        return 'watercolor painting, soft colors, artistic';
      case AIImageStyle.sketch:
        return 'pencil sketch, line art, monochrome';
      case AIImageStyle.cyberpunk:
        return 'cyberpunk, neon lights, futuristic, dystopian';
      case AIImageStyle.fantasy:
        return 'fantasy art, magical, ethereal, detailed';
      case AIImageStyle.abstract:
        return 'abstract art, geometric shapes, modern';
      case AIImageStyle.minimalist:
        return 'minimalist, clean lines, simple, elegant';
      case AIImageStyle.retro:
        return 'retro style, vintage, 80s aesthetic';
      case AIImageStyle.pixelArt:
        return 'pixel art, 8-bit, retro gaming style';
    }
  }
}

/// AI Image Size
enum AIImageSize {
  square,      // 1:1
  portrait,    // 2:3
  landscape,   // 3:2
  wallpaper,   // 16:9
  story,       // 9:16
}

/// Extension for AIImageSize
extension AIImageSizeExtension on AIImageSize {
  String get resolution {
    switch (this) {
      case AIImageSize.square:
        return '1024x1024';
      case AIImageSize.portrait:
        return '1024x1536';
      case AIImageSize.landscape:
        return '1536x1024';
      case AIImageSize.wallpaper:
        return '1920x1080';
      case AIImageSize.story:
        return '1080x1920';
    }
  }

  double get aspectRatio {
    switch (this) {
      case AIImageSize.square:
        return 1.0;
      case AIImageSize.portrait:
        return 2 / 3;
      case AIImageSize.landscape:
        return 3 / 2;
      case AIImageSize.wallpaper:
        return 16 / 9;
      case AIImageSize.story:
        return 9 / 16;
    }
  }
}

/// Text Content Type
enum TextContentType {
  story,
  poem,
  script,
  dialogue,
  description,
  joke,
  quote,
  blogPost,
}

/// Extension for TextContentType
extension TextContentTypeExtension on TextContentType {
  String get displayName {
    switch (this) {
      case TextContentType.story:
        return 'Story';
      case TextContentType.poem:
        return 'Poem';
      case TextContentType.script:
        return 'Script';
      case TextContentType.dialogue:
        return 'Dialogue';
      case TextContentType.description:
        return 'Description';
      case TextContentType.joke:
        return 'Joke';
      case TextContentType.quote:
        return 'Quote';
      case TextContentType.blogPost:
        return 'Blog Post';
    }
  }
}

/// Audio Type
enum AudioType {
  music,
  soundEffect,
  voice,
  ambient,
}

/// Extension for AudioType
extension AudioTypeExtension on AudioType {
  String get displayName {
    switch (this) {
      case AudioType.music:
        return 'Music';
      case AudioType.soundEffect:
        return 'Sound Effect';
      case AudioType.voice:
        return 'Voice';
      case AudioType.ambient:
        return 'Ambient';
    }
  }
}

/// Game Type
enum GameType {
  puzzle,
  quiz,
  memory,
  runner,
  platformer,
  rpg,
}

/// Content Type for moderation
enum ContentType {
  text,
  image,
  audio,
}

/// Content Safety Result
class ContentSafetyResult {
  final bool isSafe;
  final double safetyScore; // 0.0 to 1.0
  final List<String>? flaggedCategories;
  final String? reason;

  const ContentSafetyResult({
    required this.isSafe,
    required this.safetyScore,
    this.flaggedCategories,
    this.reason,
  });
}

/// Payment Method (for credits)
enum PaymentMethod {
  stripe,
  solanaPay,
  tonConnect,
  inAppPurchase,
}
