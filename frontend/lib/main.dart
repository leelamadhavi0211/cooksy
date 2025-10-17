/*import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'signup_screen.dart' as signup;
import 'home_screen.dart' as home;
import 'recipe_detail_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cooksy Web',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => signup.SignupScreen(),
        '/home': (context) => home.HomeScreen(),
        '/recipeDetail': (context) {
        final recipeId =
            ModalRoute.of(context)!.settings.arguments as int;
        return RecipeDetailScreen(recipeId: recipeId);
      },
      },
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'signup_screen.dart' as signup;
import 'home_screen.dart' as home;
import 'recipe_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cooksy Web',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => signup.SignupScreen(),
        '/home': (context) => home.HomeScreen(),
        '/recipeDetail': (context) {
          // ✅ Retrieve recipeId as String from arguments
          final recipeId =
              ModalRoute.of(context)!.settings.arguments.toString();
          return RecipeDetailScreen(recipeId: recipeId);
        },
      },
    );
  }
}
