import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

part 'mini_game_event.dart';
part 'mini_game_state.dart';

class MiniGameBloc extends Bloc<MiniGameEvent, MiniGameState> {
  final SpeechToText speechToText = SpeechToText();
  final FlutterTts flutterTts = FlutterTts();
  List<Map<String, dynamic>> questions = [];
  List<int> audioIndices = [];

  MiniGameBloc() : super(const MiniGameState()) {
    on<LoadGame>(_onLoadGame);
    on<AnswerQuestion>(_onAnswerQuestion);
    on<NextQuestion>(_onNextQuestion);
    on<StartListening>(_onStartListening);
    on<StopListening>(_onStopListening);
    on<PlayAudio>(_onPlayAudio);
    on<SelectOption>(_onSelectOption);
    on<SelectWord>(_onSelectWord);
    on<CheckMatchAnswers>(_onCheckMatchAnswers);
  }

  // In mini_game_bloc.dart
Future<void> _onLoadGame(LoadGame event, Emitter<MiniGameState> emit) async {
  if (event.questions.isEmpty) {
    emit(state.copyWith(
      showFeedback: true,
      isGameCompleted: true,
      correctAnswer: 'No questions available',
    ));
    return;
  }

  questions = event.questions;
  
  // Initialize for match_words question type if it exists
  List<String> shuffledWords = [];
  if (questions.isNotEmpty && 
      questions[0]['question_type'] == 'match_words' && 
      questions[0]['options'] is List) {
    List<String> options = (questions[0]['options'] as List).map((e) => e.toString()).toList();
    audioIndices = List.generate(options.length, (index) => index)..shuffle();
    shuffledWords = audioIndices.map((index) => options[index]).toList();
  }

  emit(state.copyWith(
    questionNumber: 1,
    shuffledWords: shuffledWords,
  ));
}

  void _onAnswerQuestion(AnswerQuestion event, Emitter<MiniGameState> emit) {
  final question = questions[state.currentIndex];
  if (!question.containsKey('correct_answer')) {
    emit(state.copyWith(
      showFeedback: true,
      isCorrect: false,
      correctAnswer: 'Missing correct answer in data',
    ));
    return;
  }

  String userAnswer = event.answer.trim().toLowerCase().replaceAll(
        RegExp(r'[^\w\s]'),
        '',
      );
  String correctAnswer = question['correct_answer']
      .toString()
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]'), '');

  bool isCorrect = userAnswer == correctAnswer;

  emit(state.copyWith(
    showFeedback: true,
    isCorrect: isCorrect,
    correctAnswer: isCorrect ? null : question['correct_answer'],
    score: isCorrect ? state.score + 1 : state.score,
    isGameCompleted: state.currentIndex >= questions.length - 1,
  ));

  // For multiple choice, automatically go to next question if correct
  if (question['question_type'] == 'multiple_choice') {
    Future.delayed(const Duration(milliseconds: 1500), () {
      add(NextQuestion());
    });
  }
}

  void _onNextQuestion(NextQuestion event, Emitter<MiniGameState> emit) {
    if (state.currentIndex < questions.length - 1) {
      // Prepare for next question
      List<String> shuffledWords = [];
      if (questions[state.currentIndex + 1]['question_type'] == 'match_words' && 
          questions[state.currentIndex + 1]['options'] is List<dynamic>) {
        List<String> options = questions[state.currentIndex + 1]['options'].whereType<String>().toList();
        audioIndices = List.generate(options.length, (index) => index)..shuffle();
        shuffledWords = audioIndices.map((index) => options[index]).toList();
      }

      emit(state.copyWith(
        currentIndex: state.currentIndex + 1,
        userAnswer: '',
        selectedOption: null,
        questionNumber: state.questionNumber + 1,
        showFeedback: false,
        shuffledWords: shuffledWords,
        userArrangement: [],
        matchedAnswers: {},
        matchResults: {},
        isCorrect: false,
        correctAnswer: null,
      ));
    } else {
      // Game over
      emit(state.copyWith(
        showFeedback: true,
        isGameCompleted: true,
      ));
    }
  }

  Future<void> _onStartListening(StartListening event, Emitter<MiniGameState> emit) async {
    bool available = await speechToText.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: $error'),
    );

    if (available) {
      emit(state.copyWith(isListening: true));
      
      speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            add(StopListening());
            add(AnswerQuestion(answer: result.recognizedWords));
          } else {
            emit(state.copyWith(userAnswer: result.recognizedWords));
          }
        },
        localeId: 'de_DE',
      );
    }
  }

  void _onStopListening(StopListening event, Emitter<MiniGameState> emit) {
    speechToText.stop();
    emit(state.copyWith(isListening: false));
  }

  Future<void> _onPlayAudio(PlayAudio event, Emitter<MiniGameState> emit) async {
    await flutterTts.setLanguage('de-DE');
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(event.text);
  }

void _onSelectOption(SelectOption event, Emitter<MiniGameState> emit) {
  emit(state.copyWith(selectedOption: event.option));
  
  // Automatically check the answer after selection
  add(AnswerQuestion(answer: event.option));
}

  // In mini_game_bloc.dart
void _onSelectWord(SelectWord event, Emitter<MiniGameState> emit) {
  final newMatchedAnswers = Map<String, String?>.from(state.matchedAnswers);
  
  // Remove any previous match for this dragged word
  newMatchedAnswers.remove(event.draggedWord);
  
  // Remove any previous match for this target audio word
  final existingMatch = newMatchedAnswers.entries
      .firstWhere((e) => e.value == event.targetAudioWord, orElse: () => MapEntry('', null));
  if (existingMatch.key.isNotEmpty) {
    newMatchedAnswers.remove(existingMatch.key);
  }
  
  // Add the new match
  newMatchedAnswers[event.draggedWord] = event.targetAudioWord;

  emit(state.copyWith(
    matchedAnswers: newMatchedAnswers,
    matchResults: {}, // Clear previous results when new matches are made
  ));
}

void _onCheckMatchAnswers(CheckMatchAnswers event, Emitter<MiniGameState> emit) {
  final question = questions[state.currentIndex];
  if (question['question_type'] != 'match_words') return;

  final options = (question['options'] as List).cast<String>();
  bool allCorrect = true;
  final newMatchResults = <String, bool>{};

  // Check each match against correct answers
  for (final entry in state.matchedAnswers.entries) {
    final correctAudioWord = options[audioIndices[options.indexOf(entry.key)]];
    final isCorrect = entry.value == correctAudioWord;
    
    newMatchResults[entry.key] = isCorrect;
    if (!isCorrect) {
      allCorrect = false;
    }
  }

  emit(state.copyWith(
    matchResults: newMatchResults,
  ));

  if (allCorrect) {
    Future.delayed(const Duration(milliseconds: 1500), () {
      add(AnswerQuestion(answer: 'correct'));
      add(NextQuestion());
    });
  } else {
    add(AnswerQuestion(answer: 'incorrect'));
  }
}

  @override
  Future<void> close() {
    speechToText.stop();
    flutterTts.stop();
    return super.close();
  }
}