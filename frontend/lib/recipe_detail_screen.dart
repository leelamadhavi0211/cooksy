/*import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;
  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map<String, dynamic>? recipe;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetail();
  }

  Future<void> fetchRecipeDetail() async {
    try {
      final url = Uri.parse(
          "http://10.124.153.137:5000/recipes/${widget.recipeId}"); // Backend should support this endpoint
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          recipe = json.decode(response.body);
          isLoading = false;
        });
      } else {
        print("Failed to load recipe detail: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching recipe detail: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe?['title'] ?? 'Recipe Detail')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recipe == null
              ? const Center(child: Text("Recipe not found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      recipe!['image'] != null
                          ? Image.network(
                              "http://10.124.153.137:5000/proxy-image?url=${Uri.encodeComponent(recipe!['image'])}",
                              fit: BoxFit.cover,
                            )
                          : const SizedBox(),
                      const SizedBox(height: 16),
                      Text(
                        recipe!['title'] ?? '',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Ready in: ${recipe!['readyInMinutes'] ?? 'N/A'} minutes",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Servings: ${recipe!['servings'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        recipe!['instructions'] ?? 'No instructions available',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Map recipe = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails(widget.recipeId);
  }

  Future<void> fetchRecipeDetails(String id) async {
    try {
      final url = Uri.parse("http://10.124.153.137:5000/recipes/$id");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recipe = data;
          isLoading = false;
        });
      } else {
        print("Failed to load recipe: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching recipe: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['title'] ?? "Recipe Details"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recipe.isEmpty
              ? const Center(child: Text("Recipe not found."))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ Image with proper aspect ratio
                      if (recipe['image'] != null)
                        SizedBox(
                          width: double.infinity,
                          height: 250,
                          child: Image.network(
                            recipe['image'],
                            fit: BoxFit.contain, // entire image visible
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image_not_supported, size: 50);
                            },
                          ),
                        ),
                      const SizedBox(height: 16),

                      // ✅ Recipe Title
                      Text(
                        recipe['title'] ?? '',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // ✅ Ingredients
                      if (recipe['ingredients'] != null &&
                          recipe['ingredients'] is List)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Ingredients",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            ...List.generate(
                              recipe['ingredients'].length,
                              (index) => Text(
                                "• ${recipe['ingredients'][index]}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                       // ✅ Watch Video Button
    if (recipe['youtube'] != null && recipe['youtube'] != "")
      TextButton.icon(
        onPressed: () async {
          final url = Uri.parse(recipe['youtube']);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open video')),
            );
          }
        },
        icon: const Icon(Icons.video_library),
        label: const Text("Watch Video"),
      ),
                      // ✅ Instructions
                      if (recipe['instructions'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Instructions",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text(
                              recipe['instructions'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }
}
