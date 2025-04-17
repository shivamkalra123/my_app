import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LevelScreen extends StatelessWidget {
  final String userId;
  final bool fromSettings;

  const LevelScreen({super.key, required this.userId, this.fromSettings = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/levels.jpg', fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 150),
            child: LanguageList(userId: userId, fromSettings: fromSettings),
          ),
        ],
      ),
    );
  }
}

class LanguageList extends StatelessWidget {
  final String userId;
  final bool fromSettings;

  const LanguageList({super.key, required this.userId, required this.fromSettings});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        LevelTile(
          flagPath: 'assets/images/bronze.png',
          language: 'Tier 1: Word Collector',
          userId: userId,
          fromSettings: fromSettings,
        ),
        LevelTile(
          flagPath: 'assets/images/silver.png',
          language: 'Tier 2: Fluent Fighter',
          userId: userId,
          fromSettings: fromSettings,
        ),
        LevelTile(
          flagPath: 'assets/images/gold.png',
          language: 'Tier 3: Linguistic Legend',
          userId: userId,
          fromSettings: fromSettings,
        ),
      ],
    );
  }
}

class LevelTile extends StatelessWidget {
  final String flagPath;
  final String language;
  final String userId;
  final bool fromSettings;

  const LevelTile({
    required this.flagPath,
    required this.language,
    required this.userId,
    required this.fromSettings,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 193, 142, 142), width: 1.0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Image.asset(flagPath, width: 60),
        title: Text(language),
        onTap: () async {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .set({'level': language}, SetOptions(merge: true));

          if (fromSettings) {
            Navigator.pop(context); // Just go back to settings or the previous screen
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LevelScreen(userId: userId),
              ),
            );
          }
        },
      ),
    );
  }
}
