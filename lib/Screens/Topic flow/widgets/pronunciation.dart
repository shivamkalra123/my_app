import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:audio_wave/audio_wave.dart';
import 'package:my_app/Screens/Topic%20flow/bloc/mini_game_bloc.dart';

class PronunciationWidget extends StatelessWidget {
  final String textToRead;
  final bool isListening;
  final String userAnswer;

  const PronunciationWidget({
    super.key,
    required this.textToRead,
    required this.isListening,
    required this.userAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => context.read<MiniGameBloc>().add(PlayAudio(textToRead)),
          icon: Icon(Icons.volume_up),
          label: Text('Play Audio'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        const SizedBox(height: 40),
        if (isListening)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: AudioWave(
              height: 40,
              animation: true,
              beatRate: const Duration(milliseconds: 80),
              spacing: 2,
              bars: List.generate(
                20,
                (index) => AudioWaveBar(
                  heightFactor: index.isEven ? 0.5 : 0.8,
                  color: const Color.fromARGB(255, 174, 200, 239),
                  radius: 3,
                ),
              ),
            ),
          ),
        ElevatedButton.icon(
          onPressed: () {
            if (isListening) {
              context.read<MiniGameBloc>().add(StopListening());
            } else {
              context.read<MiniGameBloc>().add(StartListening());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6EA4D6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: Icon(isListening ? Icons.stop : Icons.mic),
          label: Text(
            isListening ? 'Stop' : 'Speak',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (userAnswer.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(94, 0, 0, 0),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Text(
                'You said: $userAnswer',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}