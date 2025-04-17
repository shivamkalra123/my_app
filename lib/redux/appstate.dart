class AppState {
  final String? userId;
  final String? level;
  final String? language;
  final Map<String, dynamic> completedTopics;
  final int streak;

  AppState({
    this.userId,
    this.level,
    this.language,
    Map<String, dynamic>? completedTopics,
    this.streak = 0,
  }) : completedTopics = completedTopics ?? {};

  AppState copyWith({
    String? userId,
    String? level,
    String? language,
    Map<String, dynamic>? completedTopics,
    int? streak,
  }) {
    return AppState(
      userId: userId ?? this.userId,
      level: level ?? this.level,
      language: language ?? this.language,
      completedTopics: completedTopics ?? this.completedTopics,
      streak: streak ?? this.streak,
    );
  }
}
