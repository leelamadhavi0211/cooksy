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
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails(widget.recipeId);
  }

  Future<void> fetchRecipeDetails(String id) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // ✅ Use HTTPS backend
      final url =
          Uri.parse("https://cooksy-backend-z82c.onrender.com/recipes/$id");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data == null || data.isEmpty) {
          setState(() {
            recipe = {};
            errorMessage = "Recipe not found.";
            isLoading = false;
          });
          return;
        }

        setState(() {
          recipe = data;
          isLoading = false;
        });
      } else {
        setState(() {
          recipe = {};
          errorMessage = "Failed to load recipe: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        recipe = {};
        errorMessage = "Error fetching recipe: $e";
        isLoading = false;
      });
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
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      if (recipe['image'] != null)
                        SizedBox(
                          width: double.infinity,
                          height: 250,
                          child: Image.network(
                            recipe['image'],
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Center(
                                  child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                    : null,
                              ));
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported,
                                size: 50,
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        recipe['title'] ?? '',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      // Ingredients
                      if (recipe['ingredients'] != null &&
                          recipe['ingredients'] is List)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Ingredients",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600)),
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

                      // YouTube Video
                      if (recipe['youtube'] != null &&
                          recipe['youtube'] != "")
                        TextButton.icon(
                          onPressed: () async {
                            final url = Uri.parse(recipe['youtube']);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Could not open video')),
                              );
                            }
                          },
                          icon: const Icon(Icons.video_library),
                          label: const Text("Watch Video"),
                        ),

                      const SizedBox(height: 16),

                      // Instructions
                      if (recipe['instructions'] != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Instructions",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text(
                              recipe['instructions'],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
    );
  }
}
