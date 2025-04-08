import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:redux/redux.dart';
import 'appstate.dart';
import 'actions.dart';

void fetchUserProgressMiddleware(Store<AppState> store, action, NextDispatcher next) async {
  if (action is FetchUserProgressAction) {
    print("[DEBUG] Middleware Triggered: FetchUserProgressAction");

    final userId = store.state.userId;
    print("[DEBUG] User ID: $userId");

    if (userId == null) {
      print("[ERROR] No user ID found.");
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance.collection("user_progress").doc(userId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        print("[DEBUG] Raw Firestore Data: $data");

        if (data != null && data.containsKey("completed_topics")) {
          final List<Map<String, int>> completedTopics = 
              (data["completed_topics"] as List)
                  .map((topic) => {
                        "chapter_number": topic["chapter_number"] as int,
                        "topic_number": topic["topic_number"] as int,
                      })
                  .toList();

          print("[DEBUG] Parsed Completed Topics: $completedTopics");

          store.dispatch(SetCompletedTopicsAction(completedTopics));
        } else {
          print("[DEBUG] No completed topics found.");
        }
      } else {
        print("[DEBUG] No document found for this user.");
      }
    } catch (error) {
      print("[ERROR] Failed to fetch progress: $error");
    }
  }

  next(action); // Make sure to call next(action) to continue the Redux flow
}
