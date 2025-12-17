import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final String baseUrl = "https://cooksy-backend-z82c.onrender.com";

  List recipes = [];
  bool isLoading = true;
  String searchQuery = "";
  List savedRecipes = [];
  late TabController _tabController;
  late TextEditingController _searchController;
  bool _isInitialLoad = true;

  final List<String> categories = [
    "All",
    "Breakfast",
    "Dessert",
    "Seafood",
    "Vegetarian",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
    _searchController = TextEditingController();
    loadSavedRecipes();
    fetchRecipes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialLoad) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['fromExplore'] == true && recipes.isEmpty) {
        fetchRecipes();
      }
      _isInitialLoad = false;
    }
  }
/// 🔹 Load saved recipes from Firestore
Future<void> loadSavedRecipes() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_recipes')
        .get();

    setState(() {
      savedRecipes = snapshot.docs.map((doc) => doc.data()).toList();
    });

    print("✅ Loaded ${savedRecipes.length} saved recipes");
  } catch (e) {
    print("❌ Error loading saved recipes: $e");
  }
}

/// 🔹 Save recipe to Firestore
Future<void> saveRecipe(Map<String, dynamic> recipe) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please log in to save recipes.")),
    );
    return;
  }

  final recipeId = recipe['idMeal'] ?? recipe['id'] ?? DateTime.now().toString();

  try {
    final recipeRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_recipes')
        .doc(recipeId);

    // Add recipeId explicitly inside data to ensure consistency
    await recipeRef.set({
      ...recipe,
      'id': recipeId,
      'savedAt': Timestamp.now(),
    });

    setState(() {
      savedRecipes.add({...recipe, 'id': recipeId});
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Recipe saved successfully! ❤️")),
    );

    print("✅ Saved recipe: $recipeId");
  } catch (e) {
    print("❌ Error saving recipe: $e");
  }
}

/// 🔹 Remove saved recipe from Firestore
Future<void> removeSavedRecipe(String id) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_recipes')
        .doc(id)
        .delete();

    setState(() {
      savedRecipes.removeWhere((r) => (r['idMeal'] ?? r['id']) == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Recipe removed successfully ❌")),
    );

    print("✅ Removed recipe: $id");
  } catch (e) {
    print("❌ Error removing recipe: $e");
  }
}

/// 🔹 Check if a recipe is saved
bool isRecipeSaved(String id) {
  return savedRecipes.any((r) => (r['idMeal'] ?? r['id']) == id);
}
// 🔹 Fetch recipes (from your API / backend)
Future<void> fetchRecipes({String? query}) async {
  setState(() => isLoading = true);
  try {
    Uri url;
    if (query == null || query.isEmpty || query == "All") {
      url = Uri.parse("$baseUrl/recipes");
    } else {
      url = Uri.parse("$baseUrl/recipes?q=$query");
    }

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        recipes = data is List ? data : data['meals'] ?? [];
        isLoading = false;
      });

      print("✅ Recipes fetched: ${recipes.length}");
    } else {
      print("❌ Failed to fetch recipes, code: ${response.statusCode}");
      setState(() => isLoading = false);
    }
  } catch (e) {
    print("❌ Error fetching recipes: $e");
    setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};
    bool fromExplore = args['fromExplore'] == true;

    return Scaffold(
      backgroundColor: const Color(0xfffdfdfd),
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text(
          "🍳 Cooksy Recipes",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined,
                color: Colors.black, size: 30),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.pushNamed(context, '/editProfile');
              } else if (value == 'saved') {
                Navigator.pushNamed(context, '/savedRecipes');
              } else if (value == 'myRecipes') {
                Navigator.pushNamed(context, '/myRecipes');
              }else if (value == 'logout') {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text("Edit Profile"),
              ),
              const PopupMenuItem(
                value: 'saved',
                child: Text("Saved Recipes"),
              ),
              const PopupMenuItem(
                value: 'myRecipes',
                child: Text("MyRecipes"),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Text("Logout"),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          onTap: (index) {
            fetchRecipes(query: categories[index]);
          },
          tabs: categories.map((cat) => Tab(text: cat)).toList(),
        ),
      ),

      // 🧁 Body
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔍 Search Bar + Add Button Row
Row(
  children: [
    // Search Bar
    Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => searchQuery = value,
          onSubmitted: (value) => fetchRecipes(query: value),
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: "Search recipes...",
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      searchQuery = "";
                      fetchRecipes();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
      ),
    ),

    const SizedBox(width: 12),

    // ➕ Add Recipe Button
    InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/addRecipe');
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orangeAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.orangeAccent.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    ),
  ],
),


            const SizedBox(height: 20),

            // 🍲 Recipes
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : recipes.isEmpty
                      ? const Center(child: Text("No recipes found."))
                      : Column(
                          children: [
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  int crossAxisCount =
                                      constraints.maxWidth > 1000
                                          ? 4
                                          : constraints.maxWidth > 600
                                              ? 2
                                              : 1;

                                  final displayRecipes = fromExplore
                                      ? recipes.take(8).toList()
                                      : recipes;

                                  return GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.85,
                                    ),
                                    itemCount: displayRecipes.length,
                                    itemBuilder: (context, index) {
                                      final recipe = displayRecipes[index];
                                      final id =
                                          recipe['idMeal'] ?? recipe['id'];
                                      final isSaved = isRecipeSaved(id);

                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/recipeDetail',
                                            arguments: id,
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.15),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                        top: Radius.circular(
                                                            15)),
                                                child: Image.network(
                                                  recipe['strMealThumb'] ??
                                                      recipe['image'] ??
                                                      '',
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Container(
                                                    color: Colors.grey[200],
                                                    height: 120,
                                                    child: const Icon(
                                                        Icons.fastfood,
                                                        color: Colors.grey),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      recipe['strMeal'] ??
                                                          recipe['title'] ??
                                                          '',
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        IconButton(
                                                          icon: Icon(
                                                            isSaved
                                                                ? Icons.favorite
                                                                : Icons
                                                                    .favorite_border_outlined,
                                                            color: Colors
                                                                .redAccent,
                                                          ),
                                                          onPressed: () {
                                                            if (isSaved) {
                                                              removeSavedRecipe(
                                                                  id);
                                                            } else {
                                                              saveRecipe(
                                                                  recipe);
                                                            }
                                                          },
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
