import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dashboard_screen.dart';
import 'explore_preview_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart' as signup;
import 'recipe_detail_screen.dart';
import 'edit_profile_screen.dart';
import 'auth_guard.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cooksy Web',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xfffffaf5),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/explorePreview': (context) => const ExplorePreviewScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => signup.SignupScreen(),

        // 🔒 Protected Routes — accessible only after login
        '/home': (context) => const AuthGuard(routeName: '/home'),
        '/profile': (context) => const AuthGuard(routeName: '/profile'),
        '/myRecipes': (context) => const AuthGuard(routeName: '/myRecipes'),
        '/addRecipe': (context) => const AuthGuard(routeName: '/addRecipe'),
        '/savedRecipes': (context) => const AuthGuard(routeName: '/savedRecipes'),

        // Public
        '/editProfile': (context) => const EditProfileScreen(),

        '/recipeDetail': (context) {
          final recipeId = ModalRoute.of(context)!.settings.arguments.toString();
          return RecipeDetailScreen(recipeId: recipeId);
        },
      },
    );
  }
}
