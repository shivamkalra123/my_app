import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/material.dart';
import "package:flutter_redux/flutter_redux.dart";
import "package:my_app/Screens/Introductions/conversation.dart";
import "package:my_app/Screens/Topic%20flow/theory_screen.dart";
import "package:my_app/redux/appstate.dart";
import "utils/data.dart";
import "components/my_timeline_tile.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<Map<String, int>>>(
      converter: (store) {
        print("[DEBUG] Redux Store in UI: ${store.state.completedTopics}"); // 🔥 Debugging
        return store.state.completedTopics ?? [];
      },
      builder: (context, completedTopics) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  top: 200,
                  left: 20,
                  right: 20,
                  bottom: 100,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: classes.length,
                      itemBuilder: (context, classIndex) {
                        final classData = classes[classIndex];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: (classData["topics"] as List).length,
                                itemBuilder: (context, topicIndex) {
                                  final topic = (classData["topics"] as List)[topicIndex];

                                  // 🔥 Debugging: Print each topic index
                                  print("[DEBUG] Checking: Class $classIndex, Topic $topicIndex");

                                  // ✅ FIXED: Compare topicIndex directly (Firestore uses 0-based indexing)
                                  bool isCompleted = completedTopics.any((completed) =>
                                      completed["chapter_number"] == classIndex + 1 &&
                                      completed["topic_number"] == topicIndex);

                                  return GestureDetector(
                                    onTap: () {
                                      if (topic["title"] == "Introduction") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ConversationScreen(chapter: classIndex + 1),
                                          ),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => TheoryScreen(
                                              classIndex: classIndex,
                                              topicIndex: topicIndex,
                                              background: classIndex + 1,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: MyTimeLineTile(
                                      isFirst: topic["isFirst"] as bool,
                                      isLast: topic["isLast"] as bool,
                                      isPast: topic["isPast"] as bool,
                                      image: topic["image"] as String,
                                      text: topic["title"] as String,
                                      color: isCompleted
                                          ? Colors.green // ✅ Mark Green if Completed
                                          : classData["color"] as Color,
                                      subColor: classData["subColor"] as Color,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
