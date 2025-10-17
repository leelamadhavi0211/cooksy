/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  List recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    try {
      // Replace with your backend IP or public URL
      final url = Uri.parse("http://10.124.153.137:5000/recipes?q=healthy");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recipes = data;
          isLoading = false;
        });
      } else {
        print("Failed to load recipes: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching recipes: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🍳 Cooksy Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recipes.isEmpty
              ? const Center(child: Text("No recipes found."))
              : ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: recipe['image'] != null
                            ? Image.network(
                                "http://10.124.153.137:5000/proxy-image?url=${Uri.encodeComponent(recipe['image'])}",
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.image_not_supported);
                                },
                              )
                            : const Icon(Icons.fastfood),
                        title: Text(recipe['title'] ?? 'Unnamed Recipe'),
                        onTap: () {
                          // Navigate to Recipe Details Screen
                          Navigator.pushNamed(
                            context,
                            '/recipeDetail',
                            arguments: recipe['id'],
                          );
                        },
                      ),
                    );
                  },
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Welcome, ${user?.email ?? 'User'}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  List recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  // Fetch recipes from backend
  Future<void> fetchRecipes() async {
    try {
      final url = Uri.parse("http://10.124.153.137:5000/recipes?q=indian");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recipes = data; // store recipes
          isLoading = false;
        });
      } else {
        print("Failed to load recipes: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching recipes: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🍳 Cooksy Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recipes.isEmpty
              ? const Center(child: Text("No recipes found."))
              : ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    final recipeId = recipe['id'] ?? recipe['idMeal']; // ensure ID exists
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: recipe['strMealThumb'] != null
                        ? Image.network(
                          recipe['strMealThumb'], // directly from API
                           width: 60,
                           height: 60,
                           fit: BoxFit.cover,
                           errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                      )
                      : const Icon(Icons.fastfood),
                        title: Text(recipe['title'] ?? recipe['strMeal'] ?? 'Unnamed Recipe'),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/recipeDetail',
                            arguments: recipeId.toString(), // pass ID as string
                          );
                        },
                      ),
                    );
                  },
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Welcome, ${user?.email ?? 'User'}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

