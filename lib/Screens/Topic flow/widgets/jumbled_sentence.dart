import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/Screens/Topic%20flow/bloc/mini_game_bloc.dart';

class JumbledSentenceWidget extends StatelessWidget {
  final String correctAnswer;
  final List<String> userArrangement;
  final List<String> shuffledWords;

  const JumbledSentenceWidget({
    super.key,
    required this.correctAnswer,
    required this.userArrangement,
    required this.shuffledWords,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Instruction
        Text(
          'Arrange the words to form a correct sentence:',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // User's current arrangement
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: userArrangement.map((word) {
              return GestureDetector(
                onTap: () {
                  // When tapping a word in the arrangement, treat it as dragging to nothing
                  context.read<MiniGameBloc>().add(SelectWord(
                    draggedWord: word,
                    targetAudioWord: '', // Empty string indicates removal
                  ));
                },
                child: Chip(
                  label: Text(word),
                  backgroundColor: const Color(0xFF6EA4D6),
                  labelStyle: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Available words
        Text(
          'Available words:',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: shuffledWords.map((word) {
            return GestureDetector(
              onTap: () {
                // When tapping an available word, treat it as dragging to the sentence area
                context.read<MiniGameBloc>().add(SelectWord(
                  draggedWord: word,
                  targetAudioWord: 'sentence_area', // Special identifier
                ));
              },
              child: Chip(
                label: Text(word),
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: const Color(0xFF6EA4D6),
                  width: 1,
                ),
                labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 30),

        // Submit button
        ElevatedButton(
          onPressed: userArrangement.isNotEmpty
              ? () {
                  // Convert the user arrangement to a format the bloc expects
                  final matches = <String, String>{};
                  for (int i = 0; i < userArrangement.length; i++) {
                    matches[userArrangement[i]] = 'position_$i';
                  }
                  
                  // Trigger answer checking
                  context.read<MiniGameBloc>().add(CheckMatchAnswers());
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6EA4D6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Check Answer',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}