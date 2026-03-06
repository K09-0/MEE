part of 'creator_bloc.dart';

/// Creator Status
/// 
/// Возможные состояния создания контента
enum CreatorStatus {
  initial,
  loading,
  loaded,
  generating,
  generated,
  enhancing,
  promptEnhanced,
  publishing,
  published,
  cancelled,
  error,
}

/// Creator State
/// 
/// Состояние создания контента в приложении
class CreatorState extends Equatable {
  final CreatorStatus status;
  final GenerationCredits? credits;
  final AIGenerationResult? generationResult;
  final ExperienceType? generationType;
  final String? enhancedPrompt;
  final ContentSafetyResult? safetyResult;
  final List<AIGenerationResult> generationHistory;
  final List<String> suggestedPrompts;
  final String? errorMessage;

  const CreatorState({
    this.status = CreatorStatus.initial,
    this.credits,
    this.generationResult,
    this.generationType,
    this.enhancedPrompt,
    this.safetyResult,
    this.generationHistory = const [],
    this.suggestedPrompts = const [],
    this.errorMessage,
  });

  /// Initial state
  factory CreatorState.initial() => const CreatorState();

  /// Loading state
  factory CreatorState.loading() => const CreatorState(
    status: CreatorStatus.loading,
  );

  /// Loaded state
  factory CreatorState.loaded(GenerationCredits credits) => CreatorState(
    status: CreatorStatus.loaded,
    credits: credits,
  );

  /// Error state
  factory CreatorState.error(String message) => CreatorState(
    status: CreatorStatus.error,
    errorMessage: message,
  );

  /// Check if loading
  bool get isLoading => status == CreatorStatus.loading;

  /// Check if generating
  bool get isGenerating => status == CreatorStatus.generating;

  /// Check if generated
  bool get isGenerated => status == CreatorStatus.generated;

  /// Check if publishing
  bool get isPublishing => status == CreatorStatus.publishing;

  /// Check if published
  bool get isPublished => status == CreatorStatus.published;

  /// Check if has error
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Check if can generate
  bool get canGenerate => credits?.canGenerate ?? false;

  /// Get remaining generations today
  int get remainingGenerations => credits?.remainingToday ?? 0;

  /// Get daily limit
  int get dailyLimit => credits?.dailyLimit ?? 3;

  /// Check if content is safe
  bool get isContentSafe => safetyResult?.isSafe ?? true;

  /// Get safety score
  double get safetyScore => safetyResult?.safetyScore ?? 1.0;

  /// Copy with
  CreatorState copyWith({
    CreatorStatus? status,
    GenerationCredits? credits,
    AIGenerationResult? generationResult,
    ExperienceType? generationType,
    String? enhancedPrompt,
    ContentSafetyResult? safetyResult,
    List<AIGenerationResult>? generationHistory,
    List<String>? suggestedPrompts,
    String? errorMessage,
  }) {
    return CreatorState(
      status: status ?? this.status,
      credits: credits ?? this.credits,
      generationResult: generationResult ?? this.generationResult,
      generationType: generationType ?? this.generationType,
      enhancedPrompt: enhancedPrompt ?? this.enhancedPrompt,
      safetyResult: safetyResult ?? this.safetyResult,
      generationHistory: generationHistory ?? this.generationHistory,
      suggestedPrompts: suggestedPrompts ?? this.suggestedPrompts,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    credits,
    generationResult,
    generationType,
    enhancedPrompt,
    safetyResult,
    generationHistory,
    suggestedPrompts,
    errorMessage,
  ];

  @override
  String toString() {
    return 'CreatorState(status: $status, credits: ${credits?.remainingToday}, generated: ${generationResult != null})';
  }
}
