import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/Screens/Topic%20flow/bloc/mini_game_bloc.dart';

class MatchPronunciationWidget extends StatelessWidget {
  final List<String> options;
  final List<String> shuffledWords;
  final Map<String, String?> matchedAnswers;
  final Map<String, bool> matchResults;

  const MatchPronunciationWidget({
    super.key,
    required this.options,
    required this.shuffledWords,
    required this.matchedAnswers,
    required this.matchResults,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Words (original order)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: options.map((word) {
                      final isMatched = matchedAnswers.containsKey(word);
                      return Draggable<String>(
                        data: word,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isMatched 
                                ? Colors.green.shade100 
                                : const Color(0xFFECF4FB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isMatched 
                                  ? Colors.green 
                                  : const Color(0xFF6EA4D6),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            word,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        feedback: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6EA4D6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF41729F),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              word,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECF4FB),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF6EA4D6),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              word,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Right: Audio Buttons (shuffled)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: shuffledWords.map((audioWord) {
                      final matchedEntry = matchedAnswers.entries.firstWhere(
                        (entry) => entry.value == audioWord,
                        orElse: () => const MapEntry('', null),
                      );
                      final bool isMatched = matchedEntry.key.isNotEmpty;
                      final bool isCorrect = matchResults[matchedEntry.key] ?? false;

                      return DragTarget<String>(
                        onAccept: (draggedWord) {
                          context.read<MiniGameBloc>().add(
                            SelectWord(
                              draggedWord: draggedWord,
                              targetAudioWord: audioWord,
                            ),
                          );
                        },
                        builder: (context, candidateData, rejectedData) {
                          return ElevatedButton.icon(
                            onPressed: () async {
                              context.read<MiniGameBloc>().add(PlayAudio(audioWord));
                            },
                            icon: const Icon(Icons.volume_up),
                            label: Text(
                              isMatched ? matchedEntry.key : 'Play Audio',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isCorrect
                                    ? Colors.green.shade700
                                    : isMatched
                                        ? Colors.red.shade700
                                        : Colors.black,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCorrect
                                  ? const Color(0xFFD6F5D6)
                                  : isMatched
                                      ? const Color(0xFFFADADA)
                                      : Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isCorrect
                                      ? Colors.green
                                      : isMatched
                                          ? Colors.red
                                          : const Color(0xFF6EA4D6),
                                  width: 1,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Submit Button
            if (matchedAnswers.length == options.length)
              ElevatedButton(
                onPressed: () {
                  context.read<MiniGameBloc>().add(CheckMatchAnswers());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6EA4D6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Submit',
                  style: GoogleFonts.poppins(fontSize: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }
}