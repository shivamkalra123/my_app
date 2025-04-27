import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionHeader extends StatelessWidget {
  final int questionNumber;

  const QuestionHeader({super.key, required this.questionNumber});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 7),
          child: Text(
            'Question No. $questionNumber',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
