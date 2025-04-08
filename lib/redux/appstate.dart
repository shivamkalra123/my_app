class AppState {
  final String? userId;
  final String? level;
  final String? language;
  final List<Map<String, int>> completedTopics;
  final int streak;

  AppState({
    this.userId,
    this.level,
    this.language,
    List<Map<String, int>>? completedTopics,
    this.streak = 0,
  }) : completedTopics = completedTopics ?? [];

  AppState copyWith({
    String? userId,
    String? level,
    String? language,
    List<Map<String, int>>? completedTopics,
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