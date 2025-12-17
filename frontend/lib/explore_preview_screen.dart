import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class ExplorePreviewScreen extends StatefulWidget {
  const ExplorePreviewScreen({super.key});

  @override
  State<ExplorePreviewScreen> createState() => _ExplorePreviewScreenState();
}

class _ExplorePreviewScreenState extends State<ExplorePreviewScreen> {
  List recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSampleRecipes();
  }

  Future<void> fetchSampleRecipes() async {
    try {
      final response = await http.get(
        Uri.parse("https://cooksy-backend-z82c.onrender.com/recipes"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recipes = (data is List ? data : data['meals']).take(8).toList();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching sample recipes: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffffaf5),
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Text(
          "Explore Recipes 🍳",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsive column count
                        int crossAxisCount = constraints.maxWidth > 1000
                            ? 4
                            : constraints.maxWidth > 600
                                ? 3
                                : 2;

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8, // 👈 Reduced height
                          ),
                          itemCount: recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = recipes[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9, // 👈 keeps image shape consistent
                                      child: Image.network(
                                        recipe['strMealThumb'] ??
                                            recipe['image'] ??
                                            '',
                                        fit: BoxFit.cover, // 👈 Prevents stretching
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.image,
                                                    size: 60,
                                                    color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      recipe['strMeal'] ??
                                          recipe['title'] ??
                                          'Untitled',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      "Login to Explore More 🍲",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
