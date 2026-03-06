part of 'creator_bloc.dart';

/// Creator Events
/// 
/// Все события, связанные с созданием контента
abstract class CreatorEvent extends Equatable {
  const CreatorEvent();

  @override
  List<Object?> get props => [];
}

/// Load generation credits
class LoadGenerationCreditsRequested extends CreatorEvent {
  final String userId;

  const LoadGenerationCreditsRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Generate image
class GenerateImageRequested extends CreatorEvent {
  final String userId;
  final String prompt;
  final String? negativePrompt;
  final AIImageStyle? style;
  final AIImageSize size;
  final int? seed;

  const GenerateImageRequested({
    required this.userId,
    required this.prompt,
    this.negativePrompt,
    this.style,
    this.size = AIImageSize.square,
    this.seed,
  });

  @override
  List<Object?> get props => [
    userId,
    prompt,
    negativePrompt,
    style,
    size,
    seed,
  ];
}

/// Generate text
class GenerateTextRequested extends CreatorEvent {
  final String userId;
  final String prompt;
  final TextContentType contentType;
  final int? maxLength;
  final String? tone;
  final String? language;

  const GenerateTextRequested({
    required this.userId,
    required this.prompt,
    required this.contentType,
    this.maxLength,
    this.tone,
    this.language,
  });

  @override
  List<Object?> get props => [
    userId,
    prompt,
    contentType,
    maxLength,
    tone,
    language,
  ];
}

/// Generate audio
class GenerateAudioRequested extends CreatorEvent {
  final String userId;
  final String prompt;
  final AudioType audioType;
  final int? duration;
  final String? genre;
  final String? mood;

  const GenerateAudioRequested({
    required this.userId,
    required this.prompt,
    required this.audioType,
    this.duration,
    this.genre,
    this.mood,
  });

  @override
  List<Object?> get props => [
    userId,
    prompt,
    audioType,
    duration,
    genre,
    mood,
  ];
}

/// Generate game
class GenerateGameRequested extends CreatorEvent {
  final String userId;
  final String prompt;
  final GameType? gameType;
  final String? difficulty;

  const GenerateGameRequested({
    required this.userId,
    required this.prompt,
    this.gameType,
    this.difficulty,
  });

  @override
  List<Object?> get props => [
    userId,
    prompt,
    gameType,
    difficulty,
  ];
}

/// Enhance prompt
class EnhancePromptRequested extends CreatorEvent {
  final String prompt;
  final ExperienceType type;

  const EnhancePromptRequested({
    required this.prompt,
    required this.type,
  });

  @override
  List<Object?> get props => [prompt, type];
}

/// Check content safety
class CheckContentSafetyRequested extends CreatorEvent {
  final String content;
  final ContentType contentType;

  const CheckContentSafetyRequested({
    required this.content,
    this.contentType = ContentType.text,
  });

  @override
  List<Object?> get props => [content, contentType];
}

/// Publish experience
class PublishExperienceRequested extends CreatorEvent {
  final String generationId;
  final String title;
  final String? description;
  final double price;
  final DateTime expiresAt;
  final List<String> tags;

  const PublishExperienceRequested({
    required this.generationId,
    required this.title,
    this.description,
    required this.price,
    required this.expiresAt,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [
    generationId,
    title,
    description,
    price,
    expiresAt,
    tags,
  ];
}

/// Cancel generation
class CancelGenerationRequested extends CreatorEvent {
  final String generationId;

  const CancelGenerationRequested(this.generationId);

  @override
  List<Object?> get props => [generationId];
}

/// Load generation history
class LoadGenerationHistoryRequested extends CreatorEvent {
  final String userId;
  final int page;
  final int limit;

  const LoadGenerationHistoryRequested({
    required this.userId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [userId, page, limit];
}

/// Load suggested prompts
class LoadSuggestedPromptsRequested extends CreatorEvent {
  final ExperienceType type;

  const LoadSuggestedPromptsRequested(this.type);

  @override
  List<Object?> get props => [type];
}

/// Purchase additional credits
class PurchaseCreditsRequested extends CreatorEvent {
  final String userId;
  final int amount;
  final PaymentMethod paymentMethod;

  const PurchaseCreditsRequested({
    required this.userId,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [userId, amount, paymentMethod];
}
