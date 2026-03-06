import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/experience.dart';
import '../../../../domain/repositories/ai_repository.dart';

part 'creator_event.dart';
part 'creator_state.dart';

/// Creator BLoC
/// 
/// Управляет AI генерацией контента
class CreatorBloc extends Bloc<CreatorEvent, CreatorState> {
  final AIRepository _aiRepository;

  CreatorBloc({required AIRepository aiRepository})
      : _aiRepository = aiRepository,
        super(const CreatorState()) {
    on<LoadGenerationCreditsRequested>(_onLoadCredits);
    on<GenerateImageRequested>(_onGenerateImage);
    on<GenerateTextRequested>(_onGenerateText);
    on<GenerateAudioRequested>(_onGenerateAudio);
    on<GenerateGameRequested>(_onGenerateGame);
    on<EnhancePromptRequested>(_onEnhancePrompt);
    on<CheckContentSafetyRequested>(_onCheckSafety);
    on<PublishExperienceRequested>(_onPublish);
    on<CancelGenerationRequested>(_onCancelGeneration);
    on<LoadGenerationHistoryRequested>(_onLoadHistory);
    on<LoadSuggestedPromptsRequested>(_onLoadSuggestedPrompts);
  }

  /// Load generation credits
  Future<void> _onLoadCredits(
    LoadGenerationCreditsRequested event,
    Emitter<CreatorState> emit,
  ) async {
    emit(state.copyWith(status: CreatorStatus.loading));

    final result = await _aiRepository.getGenerationCredits(event.userId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: CreatorStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (credits) {
        emit(state.copyWith(
          status: CreatorStatus.loaded,
          credits: credits,
        ));
      },
    );
  }

  /// Generate image
  Future<void> _onGenerateImage(
    GenerateImageRequested event,
    Emitter<CreatorState> emit,
  ) async {
    // Check credits first
    if (state.credits != null && !state.credits!.canGenerate) {
      emit(state.copyWith(
        status: CreatorStatus.error,
        errorMessage: 'Daily generation limit reached. Upgrade to Pro.',
      ));
      return;
    }

    emit(state.copyWith(
      status: CreatorStatus.generating,
      generationType: ExperienceType.art,
    ));

    final result = await _aiRepository.generateImage(
      prompt: event.prompt,
      negativePrompt: event.negativePrompt,
      style: event.style,
      size: event.size,
      seed: event.seed,
    );

    result.fold(
      (failure) {
        AppLogger.w('Image generation failed: ${failure.message}');
        emit(state.copyWith(
          status: CreatorStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (result) {
        AppLogger.i('Image generated: ${result.id}');
        emit(state.copyWith(
          status: CreatorStatus.generated,
          generationResult: result,
        ));
        // Update credits
        add(LoadGenerationCreditsRequested(event.userId));
      },
    );
  }

  /// Generate text
  Future<void> _onGenerateText(
    GenerateTextRequested event,
    Emitter<CreatorState> emit,
  ) async {
    if (state.credits != null && !state.credits!.canGenerate) {
      emit(state.copyWith(
        status: CreatorStatus.error,
        errorMessage: 'Daily generation limit reached. Upgrade to Pro.',
      ));
      return;
    }

    emit(state.copyWith(
      status: CreatorStatus.generating,
      generationType: ExperienceType.text,
    ));

    final result = await _aiRepository.generateText(
      prompt: event.prompt,
      contentType: event.contentType,
      maxLength: event.maxLength,
      tone: event.tone,
      language: event.language,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: CreatorStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (result) {
        emit(state.copyWith(
          status: CreatorStatus.generated,
          generationResult: result,
        ));
        add(LoadGenerationCreditsRequested(event.userId));
      },
    );
  }

  /// Generate audio
  Future<void> _onGenerateAudio(
    GenerateAudioRequested event,
    Emitter<CreatorState> emit,
  ) async {
    if (state.credits != null && !state.credits!.canGenerate) {
      emit(state.copyWith(
        status: CreatorStatus.error,
        errorMessage: 'Daily generation limit reached. Upgrade to Pro.',
      ));
      return;
    }

    emit(state.copyWith(
      status: CreatorStatus.generating,
      generationType: ExperienceType.audio,
    ));

    final result = await _aiRepository.generateAudio(
      prompt: event.prompt,
      audioType: event.audioType,
      duration: event.duration,
      genre: event.genre,
      mood: event.mood,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: CreatorStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (result) {
        emit(state.copyWith(
          status: CreatorStatus.generated,
          generationResult: result,
        ));
        add(LoadGenerationCreditsRequested(event.userId));
      },
    );
  }

  /// Generate game
  Future<void> _onGenerateGame(
    GenerateGameRequested event,
    Emitter<CreatorState> emit,
  ) async {
    if (state.credits != null && !state.credits!.canGenerate) {
      emit(state.copyWith(
        status: CreatorStatus.error,
        errorMessage: 'Daily generation limit reached. Upgrade to Pro.',
      ));
      return;
    }

    emit(state.copyWith(
      status: CreatorStatus.generating,
      generationType: ExperienceType.miniGame,
    ));

    final result = await _aiRepository.generateGameConcept(
      prompt: event.prompt,
      gameType: event.gameType,
      difficulty: event.difficulty,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: CreatorStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (result) {
        emit(state.copyWith(
          status: CreatorStatus.generated,
          generationResult: result,
        ));
        add(LoadGenerationCreditsRequested(event.userId));
      },
    );
  }

  /// Enhance prompt
  Future<void> _onEnhancePrompt(
    EnhancePromptRequested event,
    Emitter<CreatorState> emit,
  ) async {
    emit(state.copyWith(status: CreatorStatus.enhancing));

    final result = await _aiRepository.enhancePrompt(
      prompt: event.prompt,
      type: event.type,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: CreatorStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (enhancedPrompt) {
        emit(state.copyWith(
          status: CreatorStatus.promptEnhanced,
          enhancedPrompt: enhancedPrompt,
        ));
      },
    );
  }

  /// Check content safety
  Future<void> _onCheckSafety(
    CheckContentSafetyRequested event,
    Emitter<CreatorState> emit,
  ) async {
    final result = await _aiRepository.checkContentSafety(
      event.content,
      contentType: event.contentType,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          errorMessage: failure.userMessage,
        ));
      },
      (safetyResult) {
        emit(state.copyWith(
          safetyResult: safetyResult,
        ));
      },
    );
  }

  /// Publish experience
  Future<void> _onPublish(
    PublishExperienceRequested event,
    Emitter<CreatorState> emit,
  ) async {
    emit(state.copyWith(status: CreatorStatus.publishing));

    // In real app, this would call ExperienceRepository
    // For now, simulate success
    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(
      status: CreatorStatus.published,
    ));
  }

  /// Cancel generation
  Future<void> _onCancelGeneration(
    CancelGenerationRequested event,
    Emitter<CreatorState> emit,
  ) async {
    final result = await _aiRepository.cancelGeneration(event.generationId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          errorMessage: failure.userMessage,
        ));
      },
      (_) {
        emit(state.copyWith(
          status: CreatorStatus.cancelled,
        ));
      },
    );
  }

  /// Load generation history
  Future<void> _onLoadHistory(
    LoadGenerationHistoryRequested event,
    Emitter<CreatorState> emit,
  ) async {
    final result = await _aiRepository.getGenerationHistory(
      event.userId,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          errorMessage: failure.userMessage,
        ));
      },
      (history) {
        emit(state.copyWith(
          generationHistory: history,
        ));
      },
    );
  }

  /// Load suggested prompts
  Future<void> _onLoadSuggestedPrompts(
    LoadSuggestedPromptsRequested event,
    Emitter<CreatorState> emit,
  ) async {
    final result = await _aiRepository.getSuggestedPrompts(event.type);

    result.fold(
      (failure) {
        emit(state.copyWith(
          errorMessage: failure.userMessage,
        ));
      },
      (prompts) {
        emit(state.copyWith(
          suggestedPrompts: prompts,
        ));
      },
    );
  }
}
