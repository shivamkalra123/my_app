import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app/Screens/Dictionary/Dict.dart';
import 'package:my_app/Screens/Chat/getStartedPage.dart';
import 'package:my_app/Screens/Achievements/AchievementScreen.dart';
import 'package:my_app/Screens/HomePage/HomePage.dart';
import 'package:my_app/Screens/UserProfile/UserProfile.dart'; // <-- Add this import

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({super.key, required this.currentIndex});

  void _navigate(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget target;
    switch (index) {
      case 0:
        target = HomePage();
        break;
      case 1:
        target = DictionaryHomePage();
        break;
      case 2:
        target = GetStartedPage();
        break;
      case 3:
        target = AchievementScreen();
        break;
      case 4:
        target = ProfilePage(); // <-- New user profile page
        break;
      default:
        target = HomePage();
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => target));
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color.fromARGB(121, 211, 222, 250),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(FontAwesomeIcons.house,
                color: currentIndex == 0 ? Colors.blueAccent : Colors.black),
            onPressed: () => _navigate(context, 0),
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.bookOpen,
                color: currentIndex == 1 ? Colors.blueAccent : Colors.black),
            onPressed: () => _navigate(context, 1),
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.solidCommentDots,
                color: currentIndex == 2 ? Colors.blueAccent : Colors.black),
            onPressed: () => _navigate(context, 2),
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.trophy,
                color: currentIndex == 3 ? Colors.blueAccent : Colors.black),
            onPressed: () => _navigate(context, 3),
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.solidUser,
                color: currentIndex == 4 ? Colors.blueAccent : Colors.black),
            onPressed: () => _navigate(context, 4),
          ),
        ],
      ),
    );
  }
}
