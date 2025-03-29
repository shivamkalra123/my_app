import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/Screens/HomePage/utils/data.dart'; // Import your data file
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompletionScreen extends StatefulWidget {
  final dynamic background;
  final int chapterIndex;
  final int topicIndex;

  const CompletionScreen({
    super.key,
    required this.chapterIndex,
    required this.topicIndex,
    required this.background,
  });

  @override
  _CompletionScreenState createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String chapterName = "Unknown Chapter";

  @override
  void initState() {
    super.initState();

    // Initialize animation
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Find the chapter name based on indices
    findChapterName();
  }



void findChapterName() async {
  print("Debug: Checking chapterIndex = ${widget.chapterIndex}, topicIndex = ${widget.topicIndex}");

  for (var chapter in classes ?? []) { // Ensure 'classes' is not null
    if (chapter['chapter_number'] == widget.chapterIndex) {
      for (var topic in (chapter['topics'] ?? [])) {
        if (topic['topic_number'] == widget.topicIndex) {
          setState(() {
            chapterName = (chapter['title'] ?? "Unknown Chapter").toString(); 
          });

          print("Chapter Name: ${chapterName}");
          print("Topic Name: ${(topic['title'] ?? "Unknown Topic").toString()}");

          // Save progress to Firestore
          await saveUserProgress(chapter['chapter_number'], topic['topic_number']);
          return;
        }
      }
    }
  }

  print("Debug: No matching chapter or topic found!");
}

Future<void> saveUserProgress(int chapter, int topic) async {
  final user = FirebaseAuth.instance.currentUser; // Get logged-in user
  if (user == null) return;

  try {
    await FirebaseFirestore.instance.collection('user_progress').doc(user.uid).set({
      'completed_topics': FieldValue.arrayUnion([
        {
          'chapter_number': chapter,
          'topic_number': topic,
          
        }
      ]),
    }, SetOptions(merge: true));

    print("Progress saved successfully!");
  } catch (e) {
    print("Error saving progress: $e");
  }
}



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              widget.background is String
                  ? "${widget.background}"
                  : "assets/introductions/bg${widget.background}.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Color.fromARGB(255, 255, 44, 94).withOpacity(0.2)),
          ),
          Positioned(
            top: 35,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/introductions/zhuaHug.gif'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                border: Border.all(color: Colors.orangeAccent, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(0, 4),
                    blurRadius: 15,
                  ),
                ],
              ),
              padding: EdgeInsets.all(25),
              margin: EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, size: 120, color: Color.fromARGB(255, 250, 194, 110)),
                  SizedBox(height: 10),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _animation.value,
                        child: Text(
                          "Congratulations!",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 54, 53, 53),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 15),
                  Text(
                    "You have completed this topic in:\n$chapterName",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Color.fromARGB(255, 57, 57, 57).withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 136, 220, 250),
                      padding: EdgeInsets.symmetric(horizontal: 35, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      shadowColor: Color.fromARGB(255, 77, 156, 229).withOpacity(0.4),
                      elevation: 10,
                    ),
                    child: Text(
                      "Back to Home page",
                      style: GoogleFonts.poppins(
                        color: Color.fromARGB(255, 74, 70, 177),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
