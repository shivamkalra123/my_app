import 'package:flutter/material.dart';
import 'package:my_app/Screens/LanguageScreen.dart';
import 'package:my_app/Screens/LevelScreen.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_app/redux/appstate.dart';

class UserProfileSettings extends StatelessWidget {
  const UserProfileSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, String?>(
      converter: (store) => store.state.userId,
      builder: (context, userId) {
        if (userId == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: Colors.deepPurpleAccent,
            elevation: 4.0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  // Add logout functionality if necessary
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.language,
                  title: 'Change Language',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LanguageScreen(fromSettings: true),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildSettingsTile(
                  context,
                  icon: Icons.military_tech,
                  title: 'Change Level',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LevelScreen(userId: userId, fromSettings: true),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.deepPurpleAccent,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.deepPurpleAccent,
        ),
        onTap: onTap,
      ),
    );
  }
}
