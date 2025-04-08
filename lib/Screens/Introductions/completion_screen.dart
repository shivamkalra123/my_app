import 'package:achievement_view/achievement_view.dart'; // ✅ Import AchievementView
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_app/Screens/HomePage/utils/data.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/redux/actions.dart';
import 'package:my_app/redux/appstate.dart';

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
  bool achievementShown = false; // ✅ To prevent duplicate pop-ups

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    findChapterName();
  }

  void findChapterName() async {
    for (var chapter in classes ?? []) { 
      if (chapter['chapter_number'] == widget.chapterIndex) {
        for (var topic in (chapter['topics'] ?? [])) {
          if (topic['topic_number'] == widget.topicIndex) {
            setState(() {
              chapterName = (chapter['title'] ?? "Unknown Chapter").toString(); 
            });

            await saveUserProgress(chapter['chapter_number'], topic['topic_number']);
            return;
          }
        }
      }
    }
  }

  Future<void> saveUserProgress(int chapter, int topic) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    final completedTopic = {
      'chapter_number': chapter,
      'topic_number': topic,
    };

    await FirebaseFirestore.instance
        .collection('user_progress')
        .doc(user.uid)
        .set({
      'completed_topics': FieldValue.arrayUnion([completedTopic]),
    }, SetOptions(merge: true));

    print("Progress saved successfully!");

    // ✅ Update Redux state
    final store = StoreProvider.of<AppState>(context, listen: false);
    final existing = store.state.completedTopics ?? [];
    final updated = List<Map<String, int>>.from(existing)..add(completedTopic);
    store.dispatch(SetCompletedTopicsAction(updated));

    // 🏆 Show achievement only once
    if (chapter == 1 && topic == 0 && !achievementShown) {
      achievementShown = true;
      showAchievement();
    }
  } catch (e) {
    print("Error saving progress: $e");
  }
}


  void showAchievement() {
    AchievementView(
      title: "Achievement Unlocked! 🎉",
      subTitle: "You've completed your first topic!",
      icon: Icon(Icons.emoji_events, color: Colors.white),
      color: Colors.green,
      textStyleTitle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      textStyleSubTitle: TextStyle(fontSize: 14, color: Colors.white),
      duration: Duration(seconds: 3),
      isCircle: true,
    ).show(context);
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
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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
