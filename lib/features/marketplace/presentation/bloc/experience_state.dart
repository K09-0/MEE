part of 'experience_bloc.dart';

/// Experience Status
/// 
/// Возможные состояния загрузки микроопытов
enum ExperienceStatus {
  initial,
  loading,
  loaded,
  detailLoaded,
  creating,
  created,
  purchasing,
  purchased,
  reporting,
  reported,
  error,
}

/// Experience State
/// 
/// Состояние микроопытов в приложении
class ExperienceState extends Equatable {
  final ExperienceStatus status;
  final List<Experience> experiences;
  final Experience? selectedExperience;
  final String? errorMessage;
  final bool hasReachedMax;
  final int currentPage;

  const ExperienceState({
    this.status = ExperienceStatus.initial,
    this.experiences = const [],
    this.selectedExperience,
    this.errorMessage,
    this.hasReachedMax = false,
    this.currentPage = 1,
  });

  /// Initial state
  factory ExperienceState.initial() => const ExperienceState();

  /// Loading state
  factory ExperienceState.loading() => const ExperienceState(
    status: ExperienceStatus.loading,
  );

  /// Loaded state
  factory ExperienceState.loaded(List<Experience> experiences) => ExperienceState(
    status: ExperienceStatus.loaded,
    experiences: experiences,
  );

  /// Error state
  factory ExperienceState.error(String message) => ExperienceState(
    status: ExperienceStatus.error,
    errorMessage: message,
  );

  /// Check if loading
  bool get isLoading => status == ExperienceStatus.loading;

  /// Check if creating
  bool get isCreating => status == ExperienceStatus.creating;

  /// Check if purchasing
  bool get isPurchasing => status == ExperienceStatus.purchasing;

  /// Check if loaded
  bool get isLoaded => status == ExperienceStatus.loaded;

  /// Check if has error
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Check if can load more
  bool get canLoadMore => !hasReachedMax && !isLoading;

  /// Get trending experiences
  List<Experience> get trendingExperiences => experiences
    .where((e) => e.isTrending)
    .toList();

  /// Get new experiences (last 24h)
  List<Experience> get newExperiences => experiences
    .where((e) => DateTime.now().difference(e.createdAt).inHours < 24)
    .toList();

  /// Get expiring soon experiences
  List<Experience> get expiringExperiences => experiences
    .where((e) => e.isExpiringSoon && !e.isExpired)
    .toList();

  /// Copy with
  ExperienceState copyWith({
    ExperienceStatus? status,
    List<Experience>? experiences,
    Experience? selectedExperience,
    String? errorMessage,
    bool? hasReachedMax,
    int? currentPage,
  }) {
    return ExperienceState(
      status: status ?? this.status,
      experiences: experiences ?? this.experiences,
      selectedExperience: selectedExperience ?? this.selectedExperience,
      errorMessage: errorMessage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    experiences,
    selectedExperience,
    errorMessage,
    hasReachedMax,
    currentPage,
  ];

  @override
  String toString() {
    return 'ExperienceState(status: $status, experiences: ${experiences.length}, error: $errorMessage)';
  }
}
