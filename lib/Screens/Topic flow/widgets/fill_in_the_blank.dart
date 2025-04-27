import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/Screens/Topic%20flow/bloc/mini_game_bloc.dart';

class FillInTheBlankWidget extends StatefulWidget {
  const FillInTheBlankWidget({super.key});

  @override
  State<FillInTheBlankWidget> createState() => _FillInTheBlankWidgetState();
}

class _FillInTheBlankWidgetState extends State<FillInTheBlankWidget> {
  final TextEditingController _answerController = TextEditingController();
  String _currentAnswer = '';

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 188, 214, 238),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 48, 48, 48).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _answerController,
            onChanged: (value) {
              setState(() {
                _currentAnswer = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Type your answer...',
              hintStyle: GoogleFonts.aBeeZee(
                fontSize: 17,
                color: const Color.fromARGB(255, 156, 156, 156),
              ),
              filled: true,
              fillColor: const Color.fromARGB(255, 255, 255, 255),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color.fromARGB(255, 245, 245, 245),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 104, 130, 175),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _currentAnswer.isEmpty
                ? null
                : () {
                    context.read<MiniGameBloc>().add(AnswerQuestion(answer: _currentAnswer));
                    _answerController.clear();
                    setState(() {
                      _currentAnswer = '';
                    });
                  },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color.fromRGBO(233, 240, 250, 1),
              foregroundColor: const Color.fromARGB(255, 46, 46, 46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Submit",
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}