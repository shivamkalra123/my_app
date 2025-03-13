import 'package:my_app/redux/appstate.dart';
import 'package:my_app/redux/actions.dart';

AppState appReducer(AppState state, dynamic action) {
  if (action is SetUserIdAction) {
    return state.copyWith(userId: action.userId);
  } else if (action is SetUserLevelAction) {
    return state.copyWith(level: action.level);
  } else if (action is SetUserLanguageAction) {
    return state.copyWith(language: action.language);
  }
  return state;
}
