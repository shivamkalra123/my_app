part of 'mini_game_bloc.dart';

abstract class MiniGameEvent extends Equatable {
  const MiniGameEvent();

  @override
  List<Object> get props => [];
}

class LoadGame extends MiniGameEvent {
  final List<Map<String, dynamic>> questions;
  final int background;
  final int topicIndex;
  final int chapterIndex;

  const LoadGame({
    required this.questions,
    required this.background,
    required this.topicIndex,
    required this.chapterIndex,
  });

  @override
  List<Object> get props => [questions, background, topicIndex, chapterIndex];
}

class AnswerQuestion extends MiniGameEvent {
  final String answer;
  final String? selectedOption;

  const AnswerQuestion({required this.answer, this.selectedOption});

  @override
  List<Object> get props => [answer, selectedOption ?? ''];
}

class NextQuestion extends MiniGameEvent {}

class StartListening extends MiniGameEvent {}

class StopListening extends MiniGameEvent {}

class PlayAudio extends MiniGameEvent {
  final String text;

  const PlayAudio(this.text);

  @override
  List<Object> get props => [text];
}

class SelectOption extends MiniGameEvent {
  final String option;

  const SelectOption(this.option);

  @override
  List<Object> get props => [option];
}

// In mini_game_event.dart
class SelectWord extends MiniGameEvent {
  final String draggedWord;      // The word being dragged
  final String targetAudioWord;  // The audio word being matched to

  const SelectWord({
    required this.draggedWord,
    required this.targetAudioWord,
  });

  @override
  List<Object> get props => [draggedWord, targetAudioWord];
}
class CheckMatchAnswers extends MiniGameEvent {}