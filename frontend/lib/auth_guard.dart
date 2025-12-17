import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'home_screen.dart' as home;
import 'profile_screen.dart';
import 'my_recipes_screen.dart';
import 'add_recipe_screen.dart';
import 'saved_screen.dart';

class AuthGuard extends StatelessWidget {
  final String routeName;
  const AuthGuard({super.key, required this.routeName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔹 If user is not logged in, redirect to login
        if (!snapshot.hasData) {
          return LoginScreen();
        }

        // 🔹 If logged in, return the actual screen
        switch (routeName) {
          case '/home':
            return home.HomeScreen();
          case '/profile':
            return const ProfileScreen();
          case '/myRecipes':
            return const MyRecipesScreen();
          case '/addRecipe':
            return const AddRecipeScreen();
          case '/savedRecipes':
            return const SavedScreen();
          default:
            return home.HomeScreen();
        }
      },
    );
  }
}
