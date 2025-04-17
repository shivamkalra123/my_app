import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_app/Screens/HomePage/components/bottom_nav_bar.dart';
import 'package:my_app/Screens/Introductions/conversation.dart';
import 'package:my_app/Screens/Topic%20flow/theory_screen.dart';
import 'package:my_app/redux/appstate.dart';
import 'utils/data.dart';
import 'components/my_timeline_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  DateTime? _lastPressedTime;

  Future<bool> _onWillPop() async {
    if (_lastPressedTime == null || 
        DateTime.now().difference(_lastPressedTime!) > const Duration(seconds: 2)) {
      _lastPressedTime = DateTime.now();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Press back again to exit')),
      );
      return false;
    }
    SystemNavigator.pop();
    return true;
  }

  bool _isTopicCompleted(Map<String, dynamic> completedTopics, int chapterIndex, int topicIndex) {
    print('Checking if topic is completed - Chapter: $chapterIndex, Topic: $topicIndex');
    print('Completed topics map: $completedTopics');

    if (completedTopics.isEmpty) {
      print('Completed topics map is empty');
      return false;
    }

    // Dynamically construct the key based on chapter and topic number
    final completionKey = "chapter_${chapterIndex}_topic_$topicIndex";
    print('Looking for completion key: $completionKey');

    // Fetch the completion data for the topic
    final completionData = completedTopics[completionKey];

    if (completionData != null) {
      print('Completion data found: $completionData');
      return true; // If there's completion data, the topic is completed
    }

    print('No completion data found for this topic');
    return false;
  }

  bool _isNextTopic(Map<String, dynamic> completedTopics, int chapterIndex, int topicIndex) {
    print('Checking if topic is next - Chapter: $chapterIndex, Topic: $topicIndex');

    if (completedTopics.isEmpty) {
      print('Completed topics map is empty');
      return false;
    }

    // Check if the current topic is the first one in the chapter
    if (topicIndex == 0) {
      print('This is the first topic in the chapter');
      return false; // The first topic can't be the "next" topic
    }

    // Dynamically check the previous topic
    final prevCompletionKey = "chapter_${chapterIndex}_topic_${topicIndex - 1}";
    print('Looking for previous topic key: $prevCompletionKey');

    // Check if the previous topic is completed
    final isPrevCompleted = completedTopics[prevCompletionKey] != null;
    final isCurrentCompleted = _isTopicCompleted(completedTopics, chapterIndex, topicIndex);

    print('Previous topic completed: $isPrevCompleted');
    print('Current topic completed: $isCurrentCompleted');

    // Return true if the previous topic is completed and the current topic is not
    return isPrevCompleted && !isCurrentCompleted;
  }

  @override
  void initState() {
    super.initState();
    print('HomePage initialized');
  }

  @override
  Widget build(BuildContext context) {
    print('Building HomePage');

    return WillPopScope(
      onWillPop: _onWillPop,
      child: StoreConnector<AppState, Map<String, dynamic>>(
        converter: (store) {
          final completedTopics = store.state.completedTopics ?? {};
          print('StoreConnector - Retrieved completedTopics from store: $completedTopics');
          return completedTopics;
        },
        builder: (context, completedTopics) {
          print('StoreConnector builder - Building with completedTopics: $completedTopics');
          
          return Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/home/bg.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 70,
                  left: 30,
                  child: Text(
                    user?.displayName ?? "Guest",
                    style: const TextStyle(
                      fontSize: 27,
                      color: Color(0xFF393939),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: 200,
                  left: 20,
                  right: 20,
                  bottom: 100,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: classes.length,
                    itemBuilder: (context, classIndex) {
                      print('Building chapter $classIndex');
                      final classData = classes[classIndex];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 100,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: classData["color"] as Color,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Chapter ${classIndex + 1}",
                                        style: TextStyle(
                                          fontSize: 22,
                                          color: classData["subColor"] as Color,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        classData["title"] as String,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: classData["subColor"] as Color,
                                      ),
                                    ),
                                    child: Image.asset(
                                      classData["image"] as String,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: (classData["topics"] as List).length,
                              itemBuilder: (context, topicIndex) {
                                print('Building topic $topicIndex for chapter $classIndex');
                                final topic = (classData["topics"] as List)[topicIndex];
                                final isCompleted = _isTopicCompleted(completedTopics, classIndex + 1, topicIndex);
                                final isNextTopic = _isNextTopic(completedTopics, classIndex + 1, topicIndex);
                                final isFirstTopic = classIndex == 0 && topicIndex == 0;
                                final isEnabled = isCompleted || isNextTopic || isFirstTopic;

                                print('Topic status - Completed: $isCompleted, Next: $isNextTopic, First: $isFirstTopic, Enabled: $isEnabled');

                                return GestureDetector(
                                  onTap: isEnabled
                                      ? () {
                                          print('Navigating to topic ${topic["title"]}');
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => topic["title"] == "Introduction"
                                                  ? ConversationScreen(chapter: classIndex + 1)
                                                  : TheoryScreen(
                                                      classIndex: classIndex,
                                                      topicIndex: topicIndex,
                                                      background: classIndex + 1,
                                                    ),
                                            ),
                                          ).then((_) {
                                            print('Returned from topic screen, rebuilding');
                                            setState(() {});
                                          });
                                        }
                                      : () {
                                          print('Topic locked - showing snackbar');
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Complete the previous topic to unlock this')),
                                          );
                                        },
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 500),
                                    child: Opacity(
                                      opacity: isEnabled ? 1.0 : 0.5,
                                      child: MyTimeLineTile(
                                        key: ValueKey("$classIndex-$topicIndex"),
                                        isFirst: topicIndex == 0,
                                        isLast: topicIndex == (classData["topics"] as List).length - 1,
                                        isPast: isCompleted,
                                        image: topic["image"] as String,
                                        text: topic["title"] as String,
                                        color: isCompleted
                                            ? Colors.green
                                            : isNextTopic
                                                ? Colors.orangeAccent
                                                : classData["color"] as Color,
                                        subColor: classData["subColor"] as Color,
                                        chapterIndex: classIndex + 1,
                                        topicIndex: topicIndex,
                                        isNextTopic: isNextTopic,
                                      ),
                                    ),
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
                Positioned(
                  right: 10,
                  bottom: 120,
                  child: FloatingActionButton(
                    onPressed: () {
                      print('FAB pressed');
                    },
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        FontAwesomeIcons.commentDots,
                        size: 27,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: CustomBottomNav(currentIndex: 0),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
