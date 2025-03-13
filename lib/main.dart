import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:my_app/Screens/HomeScreen.dart';
import 'package:redux/redux.dart';
import 'package:my_app/redux/appstate.dart';
import 'package:my_app/redux/reducer.dart';
import 'package:my_app/Screens/LanguageScreen.dart';
import 'package:my_app/Screens/LevelScreen.dart';
import 'package:my_app/Screens/LoginScreen.dart';
import 'package:my_app/Screens/SignupScreen.dart';
import 'Onboarding.dart';
import 'package:my_app/Services/auth_provider.dart';
import 'package:my_app/Screens/HomePage/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Check if user is logged in
  User? user = FirebaseAuth.instance.currentUser;
  final store = Store<AppState>(
    appReducer,
    initialState: AppState(userId: user?.uid),
  );

  runApp(
    StoreProvider(
      store: store,
      child: AuthProvide(store: store, child: MyApp(store: store)),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Store<AppState> store;

  const MyApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: store.state.userId != null ? '/home' : '/',
        onGenerateRoute: (settings) {
          final args = settings.arguments as Map<String, dynamic>? ?? {};

          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const Onboarding());

            case '/signup':
              return MaterialPageRoute(builder: (_) => SignupScreen());

            case '/login':
              return MaterialPageRoute(builder: (_) => LoginScreen());

            case '/lang':
              return MaterialPageRoute(builder: (_) => const LanguageScreen());

            case '/level':
              return MaterialPageRoute(
                builder: (_) => LevelScreen(userId: args['userId'] ?? ''),
              );

            case '/home':
              return MaterialPageRoute(builder: (_) => const HomeScreen());

            default:
              return MaterialPageRoute(builder: (_) => const Onboarding());
          }
        },
      ),
    );
  }
}
