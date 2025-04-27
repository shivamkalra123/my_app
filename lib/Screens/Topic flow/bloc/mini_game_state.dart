part of 'mini_game_bloc.dart';

class MiniGameState extends Equatable {
  final int currentIndex;
  final int score;
  final String userAnswer;
  final bool isListening;
  final String? selectedOption;
  final int questionNumber;
  final List<String> shuffledWords;
  final List<String> userArrangement;
  final Map<String, String?> matchedAnswers;
  final Map<String, bool> matchResults;
  final bool showFeedback;
  final bool isCorrect;
  final String? correctAnswer;
  final bool isGameCompleted;

  const MiniGameState({
    this.currentIndex = 0,
    this.score = 0,
    this.userAnswer = '',
    this.isListening = false,
    this.selectedOption,
    this.questionNumber = 1,
    this.shuffledWords = const [],
    this.userArrangement = const [],
    this.matchedAnswers = const {},
    this.matchResults = const {},
    this.showFeedback = false,
    this.isCorrect = false,
    this.correctAnswer,
    this.isGameCompleted = false,
  });

  MiniGameState copyWith({
    int? currentIndex,
    int? score,
    String? userAnswer,
    bool? isListening,
    String? selectedOption,
    int? questionNumber,
    List<String>? shuffledWords,
    List<String>? userArrangement,
    Map<String, String?>? matchedAnswers,
    Map<String, bool>? matchResults,
    bool? showFeedback,
    bool? isCorrect,
    String? correctAnswer,
    bool? isGameCompleted,
  }) {
    return MiniGameState(
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      userAnswer: userAnswer ?? this.userAnswer,
      isListening: isListening ?? this.isListening,
      selectedOption: selectedOption ?? this.selectedOption,
      questionNumber: questionNumber ?? this.questionNumber,
      shuffledWords: shuffledWords ?? this.shuffledWords,
      userArrangement: userArrangement ?? this.userArrangement,
      matchedAnswers: matchedAnswers ?? this.matchedAnswers,
      matchResults: matchResults ?? this.matchResults,
      showFeedback: showFeedback ?? this.showFeedback,
      isCorrect: isCorrect ?? this.isCorrect,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      isGameCompleted: isGameCompleted ?? this.isGameCompleted,
    );
  }

  @override
  List<Object?> get props => [
        currentIndex,
        score,
        userAnswer,
        isListening,
        selectedOption,
        questionNumber,
        shuffledWords,
        userArrangement,
        matchedAnswers,
        matchResults,
        showFeedback,
        isCorrect,
        correctAnswer,
        isGameCompleted,
      ];
}