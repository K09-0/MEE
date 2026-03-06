import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../domain/entities/experience.dart';
import '../../../../domain/repositories/experience_repository.dart';

part 'experience_event.dart';
part 'experience_state.dart';

/// Experience BLoC
/// 
/// Управляет состоянием микроопытов в приложении
/// Обрабатывает загрузку, создание, покупку и лайки
class ExperienceBloc extends Bloc<ExperienceEvent, ExperienceState> {
  final ExperienceRepository _experienceRepository;

  ExperienceBloc({required ExperienceRepository experienceRepository})
      : _experienceRepository = experienceRepository,
        super(const ExperienceState()) {
    on<LoadExperiencesRequested>(_onLoadExperiences);
    on<LoadTrendingExperiencesRequested>(_onLoadTrending);
    on<LoadNewExperiencesRequested>(_onLoadNew);
    on<LoadExpiringExperiencesRequested>(_onLoadExpiring);
    on<LoadExperienceDetailRequested>(_onLoadDetail);
    on<CreateExperienceRequested>(_onCreateExperience);
    on<PurchaseExperienceRequested>(_onPurchaseExperience);
    on<ToggleLikeExperienceRequested>(_onToggleLike);
    on<SearchExperiencesRequested>(_onSearch);
    on<LoadCreatorExperiencesRequested>(_onLoadCreatorExperiences);
    on<LoadPurchasedExperiencesRequested>(_onLoadPurchased);
    on<ReportExperienceRequested>(_onReportExperience);
  }

  /// Load experiences with filter
  Future<void> _onLoadExperiences(
    LoadExperiencesRequested event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(state.copyWith(status: ExperienceStatus.loading));

    final result = await _experienceRepository.getExperiences(
      filter: event.filter,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) {
        AppLogger.w('Load experiences failed: ${failure.message}');
        emit(state.copyWith(
          status: ExperienceStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (experiences) {
        AppLogger.i('Loaded ${experiences.length} experiences');
        emit(state.copyWith(
          status: ExperienceStatus.loaded,
          experiences: event.page > 1 
              ? [...state.experiences, ...experiences]
              : experiences,
          hasReachedMax: experiences.length < event.limit,
        ));
      },
    );
  }

  /// Load trending experiences
  Future<void> _onLoadTrending(
    LoadTrendingExperiencesRequested event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(state.copyWith(status: ExperienceStatus.loading));

    final result = await _experienceRepository.getTrendingExperiences(
      limit: event.limit,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: ExperienceStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (experiences) {
        emit(state.copyWith(
          status: ExperienceStatus.loaded,
          experiences: experiences,
        ));
      },
    );
  }

  /// Load new experiences
  Future<void> _onLoadNew(
    LoadNewExperiencesRequested event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(state.copyWith(status: ExperienceStatus.loading));

    final result = await _experienceRepository.getNewExperiences(
      limit: event.limit,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: ExperienceStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (experiences) {
        emit(state.copyWith(
          status: ExperienceStatus.loaded,
          experiences: experiences,
        ));
      },
    );
  }

  /// Load expiring experiences
  Future<void> _onLoadExpiring(
    LoadExpiringExperiencesRequested event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(state.copyWith(status: ExperienceStatus.loading));

    final result = await _experienceRepository.getExpiringSoon(
      limit: event.limit,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: ExperienceStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (experiences) {
        emit(state.copyWith(
          status: ExperienceStatus.loaded,
          experiences: experiences,
        ));
      },
    );
  }

  /// Load experience detail
  Future<void> _onLoadDetail(
    LoadExperienceDetailRequested event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(state.copyWith(status: ExperienceStatus.loading));

    final result = await _experienceRepository.getExperience(event.experienceId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: ExperienceStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (experience) {
        emit(state.copyWith(
          status: ExperienceStatus.detailLoaded,
          selectedExperience: experience,
        ));
      },
    );
  }

  /// Create new experience
  Future<void> _onCreateExperience(
    CreateExperienceRequested event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(state.copyWith(status: ExperienceStatus.creating));

    final result = await _experienceRepository.createExperience(
      type: event.type,
      title: event.title,
      description: event.description,
      aiPrompt: event.aiPrompt,
      contentUrl: event.contentUrl,
      thumbnailUrl: event.thumbnailUrl,
      previewUrl: event.previewUrl,
      price: event.price,
      currency: event.currency,
      expiresAt: event.expiresAt,
      tags: event.tags,
      metadata: event.metadata,
      contentRating: event.contentRating,
      language: event.language,
    );

    result.fold(
      (failure) {
        AppLogger.w('Create experience failed: ${failure.message}');
        emit(state.copyWith(
          status: ExperienceStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (experience) {
        AppLogger.i('Experience created: ${experience.id}');
        emit(state.copyWith(
          status: ExperienceStatus.created,
          selectedExperience: experience,
          experiences: [experience, ...state.experiences],
        ));
      },
    );
  }

  /// Purchase experience
  Future<void> _onPurchaseExperience(
    PurchaseExperienceRequested event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(state.copyWith(status: ExperienceStatus.purchasing));

    final result = await _experienceRepository.purchaseExperience(
      experienceId: event.experienceId,
      paymentMethod: event.paymentMethod,
    );

    result.fold(
      (failure) {
        AppLogger.w('Purchase failed: ${failure.message}');
        emit(state.copyWith(
          status: ExperienceStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (experience) {
        AppLogger.i('Experience purchased: ${experience.id}');
        emit(state.copyWith(
          status: ExperienceStatus.purchased,
          selectedExperience: experience,
        ));
      },
    );
  }

  /// Toggle like
  Future<void> _onToggleLike(
    ToggleLikeExperienceRequested event,
    Emitter<ExperienceState> emit,
  ) async {
    final result = await _experienceRepository.toggleLike(
      event.experienceId,
      event.userId,
    );

    result.fold(
      (failure) {
        AppLogger.w('Toggle like failed: ${failure.message}');
      },
      (_) {
        // Update local state
        final updatedExperiences = state.experiences.map((e) {
          if (e.id == event.experienceId) {
            // Toggle like locally
            return e; // In real app, update likes count
          }
          return e;
        }).toList();

        emit(state.copyWith(experiences: updatedExperiences));
      },
    );
  }

  /// Search experiences
  Future<void> _onSearch(
    SearchExperiencesRequested event,
    Emitter<ExperienceState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(state.copyWith(
        status: ExperienceStatus.loaded,
        experiences: [],
      ));
      return;
    }

    emit(state.copyWith(status: ExperienceStatus.loading));

    final result = await _experienceRepository.searchExperiences(
      event.query,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: ExperienceStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (experiences) {
        emit(state.copyWith(
          status: ExperienceStatus.loaded,
          experiences: experiences,
        ));
      },
    );
  }

  /// Load creator's experiences
  Future<void> _onLoadCreatorExperiences(
    LoadCreatorExperiencesRequested event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(state.copyWith(status: ExperienceStatus.loading));

    final result = await _experienceRepository.getCreatorExperiences(
      event.creatorId,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: ExperienceStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (experiences) {
        emit(state.copyWith(
          status: ExperienceStatus.loaded,
          experiences: experiences,
        ));
      },
    );
  }

  /// Load purchased experiences
  Future<void> _onLoadPurchased(
    LoadPurchasedExperiencesRequested event,
    Emitter<ExperienceState> emit,
  ) async {
    emit(state.copyWith(status: ExperienceStatus.loading));

    final result = await _experienceRepository.getPurchasedExperiences(
      event.userId,
      page: event.page,
      limit: event.limit,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: ExperienceStatus.error,
          errorMessage: failure.userMessage,
        ));
      },
      (experiences) {
        emit(state.copyWith(
          status: ExperienceStatus.loaded,
          experiences: experiences,
        ));
      },
    );
  }

  /// Report experience
  Future<void> _onReportExperience(
    ReportExperienceRequested event,
    Emitter<ExperienceState> emit,
  ) async {
    final result = await _experienceRepository.reportExperience(
      experienceId: event.experienceId,
      reason: event.reason,
      details: event.details,
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          errorMessage: failure.userMessage,
        ));
      },
      (_) {
        emit(state.copyWith(
          status: ExperienceStatus.reported,
        ));
      },
    );
  }
}
