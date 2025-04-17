import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:my_app/Screens/UserProfile/EditProfile.dart';
import 'package:my_app/Screens/UserProfile/ReferFriend.dart';
import 'package:my_app/Screens/UserProfile/settings/UserProfileSettings.dart';
import 'package:my_app/Screens/UserProfile/StreakTab.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int selectedTabIndex = 0;
  String? avatarUrl;
  bool avatarLoading = true;

  @override
  void initState() {
    super.initState();
    loadAvatar();
  }

  Future<void> loadAvatar() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/avatars.json');
      final data = json.decode(jsonString);
      final List<dynamic> avatars = data['avatars'];

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final avatarIndex = doc.data()?['avatarIndex'] ?? 0;

      if (avatarIndex < avatars.length) {
        setState(() {
          avatarUrl = avatars[avatarIndex];
          avatarLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading avatar: $e");
      setState(() {
        avatarLoading = false;
      });
    }
  }

  void navigateToTab(int index) => setState(() => selectedTabIndex = index);

  void onGeneralItemTap(String title) {
    switch (title) {
      case "Refer a Friend":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferAFriendPage()));
        break;
      // Add more cases as needed.
    }
    switch(title){
      case "Settings":
      Navigator.push(context, MaterialPageRoute(builder: (_)=> const UserProfileSettings()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFC6D5),
              Color(0xFFF5E1ED),
              Color(0xFFF1ECF6),
              Color(0xFFF0EFF9),
              Color(0xFFFFF5E8),
              Color(0xFFFEF6E9),
              Color(0xFFFBF0E1),
              Color(0xFFF4E5F1),
              Color(0xFFFFC6D5),
            ],
            stops: [0.0, 0.15, 0.19, 0.22, 0.30, 0.52, 0.75, 0.88, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
                      child: Row(
                        children: [
                          Image.asset('assets/profile/arrow_icon.png', height: 20, width: 20),
                          const SizedBox(width: 8),
                          Text('Back', style: GoogleFonts.lato(fontSize: 14, color: const Color(0xFF437D28))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                avatarLoading
                    ? const CircularProgressIndicator()
                    : CircleAvatar(
                        radius: 53,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.network(
                            avatarUrl ?? 'https://i.pravatar.cc/150?img=1',
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                            loadingBuilder: (context, child, loadingProgress) =>
                                loadingProgress == null ? child : const CircularProgressIndicator(),
                          ),
                        ),
                      ),

                const SizedBox(height: 10),
                Image.asset('assets/profile/catHands.png', fit: BoxFit.cover, width: 380, height: 70),
                const SizedBox(height: 20),

                Divider(color: Colors.grey.shade300, thickness: 1),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTab("General", 0),
                      _buildTab("Streak🔥", 1),
                      _buildTab("Goals", 2),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 1,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: _buildTabContent(),
                ),

                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset('assets/profile/editButton.png', height: 250, width: 250),
                    Positioned(
                      bottom: 50,
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
                        child: Text.rich(
                          TextSpan(
                            style: GoogleFonts.lato(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF837977)),
                            children: [
                              const TextSpan(text: "Want to "),
                              TextSpan(
                                text: "Edit",
                                style: GoogleFonts.lato(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFFEA4877)),
                              ),
                              const TextSpan(text: " Profile?"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final bool isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () => navigateToTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF9C0D6) : const Color(0xFFF6DCE9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF5B4473),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildGeneralItem(Icons.group_add, "Refer a Friend"),
            _buildGeneralItem(Icons.settings, "Settings"),
            _buildGeneralItem(Icons.feedback_outlined, "Feedback"),
            _buildGeneralItem(Icons.help_outline, "Help & Support"),
          ],
        );
      case 1:
        return StreakTab();
      case 2:
      default:
        return Center(
          child: Text(
            "Selected Tab: Goals",
            style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
          ),
        );
    }
  }

  Widget _buildGeneralItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF5B4473)),
      title: Text(title, style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () => onGeneralItemTap(title),
    );
  }
}