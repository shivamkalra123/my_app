class AppState {
  final String? userId;
  final String? level;
  final String? language;
  final List<Map<String, int>> completedTopics;

  AppState({
    this.userId,
    this.level,
    this.language,
      List<Map<String, int>>? completedTopics, // Allow null in constructor
  }) : completedTopics = completedTopics ?? []; // Default to empty list


  AppState copyWith({
    String? userId,
    String? level,
    String? language,
    List<Map<String, int>>? completedTopics,
  }) {
    return AppState(
      userId: userId ?? this.userId,
      level: level ?? this.level,
      language: language ?? this.language,
      completedTopics: completedTopics ?? this.completedTopics, // ✅ Ensure it's never null
    );
  }
}
