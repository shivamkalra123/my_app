import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_app/Screens/HomePage/components/bottom_nav_bar.dart';
import 'package:my_app/redux/appstate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:collection/collection.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  _AchievementScreenState createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  final ScreenshotController screenshotController = ScreenshotController();

  final List<Map<String, dynamic>> achievements = [
    {
      "title": "First Step!",
      "description": "Completed your first topic 🎉",
      "unlockCondition": (List<Map<String, int>> topics) => topics.isNotEmpty,
      "badgeImage": "assets/onboarding/bronze.png",
    },
    {
      "title": "Chapter Champ",
      "description": "Completed 5 topics 🧠",
      "unlockCondition": (List<Map<String, int>> topics) => topics.length >= 5,
      "badgeImage": "assets/onboarding/bronze.png",
    },
    {
      "title": "Mastermind",
      "description": "Completed 10 topics 🧠",
      "unlockCondition": (List<Map<String, int>> topics) => topics.length >= 10,
      "badgeImage": "assets/onboarding/bronze.png",
    },
  ];

  Future<void> shareOrDownloadBadge(Map<String, dynamic> badge) async {
    Uint8List image = await screenshotController.captureFromWidget(
      Material(
        color: Colors.transparent,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(badge["badgeImage"], width: 300),
              Text(badge["title"],
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(badge["description"], textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );

    final tempDir = await getTemporaryDirectory();
    final file = await File(
            '${tempDir.path}/${badge['title'].replaceAll(" ", "_")}.png')
        .create();
    await file.writeAsBytes(image);

    await Share.shareXFiles([
      XFile(file.path, name: "${badge['title']}.png")
    ], text: "I just unlocked '${badge['title']}' badge in MyApp! 🎉");
  }

  Future<bool> _onWillPop() async {
    final store = StoreProvider.of<AppState>(context);
    if (store.state.userId != null) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: StoreConnector<AppState, Map<String, dynamic>>(
        converter: (store) => store.state.completedTopics,
        builder: (context, completedTopicsMap) {
          final List<Map<String, int>> completedTopics =
    completedTopicsMap.entries.map((entry) {
  final data = entry.value as Map<String, dynamic>;
  return {
    "chapter_number": data['chapter_number'] as int,
    "topic_number": data['topic_number'] as int,
  };
}).toList();


          int totalExercises = 20;
          int completedCount = completedTopics.length;
          double progress = completedCount / totalExercises;

          final groupedByChapter = groupBy(
              completedTopics, (Map<String, int> topic) => topic['chapter_number']);
          int chaptersCompleted = groupedByChapter.length;
          int topicsCompleted = completedTopics.length;

          return Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            backgroundColor: Colors.transparent,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.deepPurpleAccent.shade200,
                    Colors.deepPurple.shade100,
                    Colors.deepPurple.shade50,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: 30,),
                    Text("Achievements", style: TextStyle(color: Colors.white, fontSize: 25)),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 40),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurpleAccent.withOpacity(0.4),
                                    blurRadius: 40,
                                    spreadRadius: 5,
                                  )
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 180,
                                    width: 180,
                                    child: CircularProgressIndicator(
                                      value: progress,
                                      strokeWidth: 16,
                                      backgroundColor: Colors.white.withOpacity(0.3),
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        "${(progress * 100).round()}%",
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text("Overall Progress",
                                          style: TextStyle(color: Colors.white70)),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text("Chapters Completed",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      SizedBox(height: 4),
                                      Text("$chaptersCompleted",
                                          style: TextStyle(fontSize: 20, color: Colors.white)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text("Topics Completed",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      SizedBox(height: 4),
                                      Text("$topicsCompleted",
                                          style: TextStyle(fontSize: 20, color: Colors.white)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            GridView.count(
                              crossAxisCount: 2,
                              padding: EdgeInsets.all(16),
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: achievements.map((achievement) {
                                bool unlocked = achievement['unlockCondition'](completedTopics);

                                return GestureDetector(
                                  onTap: unlocked
                                      ? () => shareOrDownloadBadge(achievement)
                                      : null,
                                  child: Opacity(
                                    opacity: unlocked ? 1.0 : 0.4,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade300,
                                            blurRadius: 8,
                                            offset: Offset(2, 4),
                                          )
                                        ],
                                      ),
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            achievement["badgeImage"],
                                            width: 80,
                                            height: 80,
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            achievement["title"],
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.center,
                                          ),
                                          Text(
                                            achievement["description"],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CustomBottomNav(currentIndex: 3),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
