import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_app/Screens/HomePage/components/bottom_nav_bar.dart';
import 'package:my_app/Screens/Introductions/conversation.dart';
import 'package:my_app/Screens/Topic%20flow/theory_screen.dart';
import 'package:my_app/redux/appstate.dart';
import 'package:my_app/Screens/UserProfile/settings/transaltion_service/translation.dart';

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
  
  final TranslationService _translator = TranslationService();


  bool _isLanguageLoaded = false;

 Future<void> _loadLanguage() async {
 
  final store = StoreProvider.of<AppState>(context, listen: false);
  

  final selectedLang = store.state.selectedLanguageCode ?? 'en'; 
  

  await _translator.setLanguage(selectedLang);


  setState(() {
    _isLanguageLoaded = true;
  });
}

  @override
  void initState() {
    super.initState();
    print('HomePage initialized');
    _loadLanguage();
  }

  Future<bool> _onWillPop() async {
    if (_lastPressedTime == null ||
        DateTime.now().difference(_lastPressedTime!) > const Duration(seconds: 2)) {
      _lastPressedTime = DateTime.now();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_translator.translate('press_back_again_to_exit'))),
      );
      return false;
    }
    SystemNavigator.pop();
    return true;
  }

  bool _isTopicCompleted(Map<String, dynamic> completedTopics, int chapterIndex, int topicIndex) {
    final completionKey = "chapter_${chapterIndex}_topic_$topicIndex";
    final completionData = completedTopics[completionKey];
    return completionData != null;
  }

  bool _isNextTopic(Map<String, dynamic> completedTopics, int chapterIndex, int topicIndex) {
  // Print the chapter and topic indices for debugging

  
  
  if (topicIndex == 0) return false;

  // Generating the previous topic's key
  final prevKey = "chapter_${chapterIndex}_topic_${topicIndex - 1}";

  // Check if the previous topic was completed
  final isPrevCompleted = completedTopics[prevKey] != null;
  

  final isCurrentCompleted = _isTopicCompleted(completedTopics, chapterIndex, topicIndex);
  

  return isPrevCompleted && !isCurrentCompleted;
}


  @override
  Widget build(BuildContext context) {
    if (!_isLanguageLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: StoreConnector<AppState, Map<String, dynamic>>(
        converter: (store) => store.state.completedTopics ?? {},
        builder: (context, completedTopics) {
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
                    user?.displayName ?? _translator.translate('guest'),
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
                      final classData = classes[classIndex];
                      final translatedTitle = _translator.translate(classData["title"] as String);

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
                                        "${_translator.translate("chapter")} ${classIndex + 1}",
                                        style: TextStyle(
                                          fontSize: 22,
                                          color: classData["subColor"] as Color,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      Text(
                                        translatedTitle,
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
                                final topic = (classData["topics"] as List)[topicIndex];
                                final isCompleted = _isTopicCompleted(completedTopics, classIndex+1, topicIndex);
                                final isNextTopic = _isNextTopic(completedTopics, classIndex + 1, topicIndex);
                                final isFirstTopic = classIndex == 0 && topicIndex == 0;
                                final isEnabled = isCompleted || isNextTopic || isFirstTopic;
                                final translatedTopicTitle = _translator.translate(topic["title"] as String);

                                return GestureDetector(
                                  onTap: isEnabled
                                      ? () {
                                        print("Chapter Index: $classIndex");
        print("Topic Index: $topicIndex");
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => topic["title"] == "Introduction"
                                                  ? ConversationScreen(chapter: classIndex + 1)
                                                  : TheoryScreen(
                                                      classIndex: classIndex+1,
                                                      topicIndex: topicIndex,
                                                      background: classIndex + 1,
                                                    ),
                                            ),
                                          ).then((_) => setState(() {}));
                                        }
                                      : () => ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Complete the previous topic to unlock this'),
                                            ),
                                          ),
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
                                        text: translatedTopicTitle,
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
                const Positioned(
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
