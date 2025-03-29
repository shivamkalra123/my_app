import 'package:my_app/redux/appstate.dart';
import 'package:my_app/redux/actions.dart'; // Ensure this is correctly imported

AppState appReducer(AppState state, dynamic action) {
  if (action is SetUserIdAction) {
    return state.copyWith(userId: action.userId);
  } else if (action is SetUserLevelAction) {
    return state.copyWith(level: action.level);
  } else if (action is SetUserLanguageAction) {
    return state.copyWith(language: action.language);
  } else if (action is SetCompletedTopicsAction) {  
    // This action updates the Redux store with the list of completed topics fetched from Firebase
    return state.copyWith(completedTopics: action.completedTopics);
  }
  return state;
}
