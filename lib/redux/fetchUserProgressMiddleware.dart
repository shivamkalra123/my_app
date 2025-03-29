import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redux/redux.dart';
import 'package:my_app/redux/appstate.dart';
import 'package:my_app/redux/actions.dart';

void fetchUserProgressMiddleware(
    Store<AppState> store, dynamic action, NextDispatcher next) async {
  
  if (action is FetchUserProgressAction) {
    String? userId = store.state.userId;
    print("[DEBUG] Middleware Triggered: FetchUserProgressAction");
    print("[DEBUG] User ID: $userId");

    if (userId == null) {
      print("[ERROR] User ID is null, cannot fetch progress.");
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_progress')
          .doc(userId)
          .get();

      if (!snapshot.exists) {
        print("[ERROR] No data found for user: $userId");
        return;
      }

      final data = snapshot.data();
      print("[DEBUG] Raw Firestore Data: $data");

      List<Map<String, int>> completedTopics = [];
      if (data != null && data.containsKey('completed_topics')) {
        completedTopics = List<Map<String, int>>.from(
          (data['completed_topics'] as List<dynamic>).map(
            (e) => {
              "chapter_number": e["chapter_number"] as int,
              "topic_number": e["topic_number"] as int,
            },
          ),
        );
      }

      print("[DEBUG] Parsed Completed Topics: $completedTopics");

      store.dispatch(SetCompletedTopicsAction(completedTopics));
    } catch (e) {
      print("[ERROR] Failed to fetch user progress: $e");
    }
  }

  next(action);
}
