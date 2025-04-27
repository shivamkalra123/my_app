import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/Screens/Introductions/completion_screen.dart';
import 'package:my_app/Screens/Topic flow/bloc/mini_game_bloc.dart';
import 'package:my_app/Screens/Topic flow/widgets/question_header.dart';
import 'package:my_app/Screens/Topic flow/widgets/fill_in_the_blank.dart';
import 'package:my_app/Screens/Topic flow/widgets/multiple_choice.dart';
import 'package:my_app/Screens/Topic flow/widgets/pronunciation.dart';
import 'package:my_app/Screens/Topic flow/widgets/listening_mcq.dart';
import 'package:my_app/Screens/Topic flow/widgets/listening_typing.dart';
import 'package:my_app/Screens/Topic flow/widgets/match_pronunciation.dart';
import 'package:my_app/Screens/Topic flow/widgets/jumbled_sentence.dart';

class MiniGameScreen extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final int background;
  final int topicIndex;
  final int chapterIndex;

  MiniGameScreen({
    super.key,
    required this.questions,
    required this.background,
    required this.topicIndex,
    required this.chapterIndex,
  }) {
    assert(questions.isNotEmpty, 'Questions list cannot be empty');
    debugPrint('📋 Questions received:');
    for (var i = 0; i < questions.length; i++) {
      debugPrint('  ${i + 1}. ${questions[i]}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MiniGameBloc()..add(LoadGame(
        questions: questions,
        background: background,
        topicIndex: topicIndex,
        chapterIndex: chapterIndex,
      )),
      child: _MiniGameView(
        background: background,
        topicIndex: topicIndex,
        chapterIndex: chapterIndex,
      ),
    );
  }
}

class _MiniGameView extends StatelessWidget {
  final int background;
  final int topicIndex;
  final int chapterIndex;

  const _MiniGameView({
    required this.background,
    required this.topicIndex,
    required this.chapterIndex,
  });

  void _showFeedback(BuildContext context, bool isCorrect, [String? correctAnswer]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: isCorrect ? Colors.green.shade100 : Colors.red.shade100,
        title: Icon(
          isCorrect ? Icons.check_circle : Icons.cancel,
          color: isCorrect ? Colors.green : Colors.red,
          size: 60,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isCorrect ? 'Correct!' : 'Wrong answer!',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isCorrect && correctAnswer != null) ...[
              const SizedBox(height: 8),
              Text(
                'Correct Answer: $correctAnswer',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
            // Only manually go to next question if not multiple choice
            final currentQuestion = context.read<MiniGameBloc>().questions[
              context.read<MiniGameBloc>().state.currentIndex
            ];
            if (currentQuestion['question_type'] != 'multiple_choice') {
              context.read<MiniGameBloc>().add(NextQuestion());
            }
          },
          child: const Text('Next', style: TextStyle(fontSize: 18)),
        ),
      ],
      ),
    );
  }

  void _showFinalScore(BuildContext context, MiniGameState state) {
    final questions = context.read<MiniGameBloc>().questions;
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.blue.shade100,
        title: const Text(
          'Game Over!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'You scored ${state.score} out of ${questions.length}!',
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => CompletionScreen(
                    background: background,
                    topicIndex: topicIndex,
                    chapterIndex: chapterIndex,
                  ),
                ),
              );
            },
            child: const Text('OK', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MiniGameBloc, MiniGameState>(
      listener: (context, state) {
        if (state.showFeedback) {
          if (state.currentIndex >= context.read<MiniGameBloc>().questions.length - 1) {
            _showFinalScore(context, state);
          } else {
            _showFeedback(
              context,
              state.isCorrect,
              state.isCorrect ? null : state.correctAnswer,
            );
          }
        }
      },
      builder: (context, state) {
        final questions = context.read<MiniGameBloc>().questions;
        
        // Add protection against empty questions list
        if (questions.isEmpty) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No questions available'),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final question = questions[state.currentIndex];
        
        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/theory/Mini_back.jpg",
                fit: BoxFit.cover,
              ),
            ),
            Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: const Color.fromARGB(141, 184, 217, 248),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: const BackButton(color: Colors.black),
                automaticallyImplyLeading: true,
              ),
              body: Column(
                children: [
                  QuestionHeader(questionNumber: state.questionNumber),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 5, bottom: 35),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          border: Border.all(
                            color: const Color.fromARGB(255, 157, 191, 245),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              _getQuestionInstruction(question),
                              style: const TextStyle(
                                fontSize: 25,
                                wordSpacing: 1.5,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (question.containsKey('question_native'))
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  question['question_native'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 30),
                            Divider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                              height: 1,
                            ),
                            _buildQuestionWidget(context, question, state),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _getQuestionInstruction(Map<String, dynamic> question) {
    switch (question['question_type']) {
      case "listening_typing":
        return "Listen to the audio and type what you hear";
      case "pronounciation":
        return "Repeat after the audio";
      case "listening_mcq":
        return "Listen to the audio and select the correct option";
      case "jumbled_sentence":
        return "Arrange the words to form a sentence";
      default:
        return question['question'] ?? question['title'] ?? '';
    }
  }

  Widget _buildQuestionWidget(BuildContext context, Map<String, dynamic> question, MiniGameState state) {
    try {
      switch (question['question_type']) {
        case 'type_in_the_blanks':
          return FillInTheBlankWidget();
        case 'multiple_choice':
          final options = (question['options'] as List).map((e) => e.toString()).toList();
          return MultipleChoiceWidget(
            options: options,
            selectedOption: state.selectedOption,
          );
        case 'pronounciation':
          return PronunciationWidget(
            textToRead: question['text_to_read'],
            isListening: state.isListening,
            userAnswer: state.userAnswer,
          );
        case 'listening_mcq':
          final options = (question['options'] as List).map((e) => e.toString()).toList();
          return ListeningMCQWidget(
            textToRead: question['text_to_read'],
            options: options,
            selectedOption: state.selectedOption,
          );
        case 'listening_typing':
          return ListeningTypingWidget(
            textToRead: question['text_to_read'],
            userAnswer: state.userAnswer,
          );
        case 'match_words':
          if (question['options'] != null && question['options'] is List<dynamic>) {
            try {
              List<String> options = (question['options'] as List).map((e) => e.toString()).toList();
              if (options.isNotEmpty) {
                return MatchPronunciationWidget(
                  options: options,
                  shuffledWords: state.shuffledWords,
               
                  matchedAnswers: state.matchedAnswers,
                  matchResults: state.matchResults,
                );
              }
            } catch (e) {
              debugPrint('Error processing match question: $e');
            }
          }
          return const SizedBox();
        case 'jumbled_sentence':
          return JumbledSentenceWidget(
            correctAnswer: question['correct_answer'].toString(),
            userArrangement: state.userArrangement,
            shuffledWords: state.shuffledWords,
          );
        default:
          return Container(
            child: const Text(
              'Unsupported question type',
              style: TextStyle(fontSize: 18),
            ),
          );
      }
    } catch (e, stackTrace) {
      debugPrint('Error building question widget: $e');
      debugPrint('Stack trace: $stackTrace');
      return Container(
        child: const Text(
          'Error displaying question',
          style: TextStyle(fontSize: 18),
        ),
      );
    }
  }
}