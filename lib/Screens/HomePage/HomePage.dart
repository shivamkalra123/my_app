import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/material.dart';
import "package:flutter/services.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:flutter_redux/flutter_redux.dart";
import "package:my_app/Screens/HomePage/components/bottom_nav_bar.dart";
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
  DateTime? _lastPressedTime;

  Future<bool> _onWillPop() async {
    if (_lastPressedTime == null || 
        DateTime.now().difference(_lastPressedTime!) > Duration(seconds: 2)) {
      _lastPressedTime = DateTime.now();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Press back again to exit')),
      );
      return false;
    }
    SystemNavigator.pop();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: StoreConnector<AppState, List<Map<String, int>>>(
        converter: (store) => store.state.completedTopics ?? [],
        builder: (context, completedTopics) {
          return Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
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
                    style: TextStyle(
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
                      final classData = classes[classIndex];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 100,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              margin: EdgeInsets.only(bottom: 10),
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
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10),
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
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: (classData["topics"] as List).length,
                              itemBuilder: (context, topicIndex) {
                                final topic = (classData["topics"] as List)[topicIndex];

                                bool isCompleted = completedTopics.any((completed) =>
                                    completed["chapter_number"] == classIndex + 1 &&
                                    completed["topic_number"] == topicIndex);

                                bool isNextTopic =
                                    completedTopics.any((completed) =>
                                        completed["chapter_number"] == classIndex + 1 &&
                                        completed["topic_number"] == topicIndex - 1) &&
                                    !isCompleted;

                                bool isFirstTopic = classIndex == 0 && topicIndex == 0;
                                bool isEnabled = isCompleted || isNextTopic || isFirstTopic;


                                return GestureDetector(
                                  onTap: isEnabled
                                      ? () {
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
                                            // This triggers a rebuild by calling setState
                                            setState(() {});
                                          });
                                        }
                                      : () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Complete the previous topic to unlock this')),
                                          );
                                        },
                                  child: AnimatedSwitcher(
                                    duration: Duration(milliseconds: 500),
                                    child: Opacity(
                                      opacity: isEnabled ? 1.0 : 0.5,
                                      child: MyTimeLineTile(
                                        key: ValueKey("\$classIndex-\$topicIndex"),
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
                    onPressed: () {},
                    backgroundColor: Colors.white,
                    shape: CircleBorder(),
                    child: Padding(
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
                  
                child: CustomBottomNav(currentIndex: 0), // 3 is HomePage

                ),
              ],
            ),
          );
        },
      ),
    );
  }
}