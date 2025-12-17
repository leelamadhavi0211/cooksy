import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffffaf5),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 800;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🟧 Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "🍳 Cooksy",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent.shade700,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: const Text("Login / Signup"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  // 🟧 Hero Section
                  Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left side — Text
                      Expanded(
                        flex: isWide ? 1 : 0,
                        child: Column(
                          crossAxisAlignment: isWide
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Discover Delicious, The Easy Way ⚡",
                              textAlign:
                                  isWide ? TextAlign.left : TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: isWide ? 42 : 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Discover easy, delicious, and healthy recipes crafted just for you. "
                              "Save favorites, organize new recipes, and enjoy cooking like never before.",
                              textAlign:
                                  isWide ? TextAlign.left : TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: isWide
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/login');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orangeAccent,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "Get Started",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                     OutlinedButton(
  onPressed: () {
    Navigator.pushNamed(
      context,
      '/explorePreview',
      arguments: {'fromExplore': true}, // 👈 Pass flag
    );
  },
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: Colors.orangeAccent.shade100, width: 2),
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text(
    "Explore Recipes",
    style: GoogleFonts.poppins(
      color: Colors.orangeAccent.shade700,
      fontWeight: FontWeight.w600,
    ),
  ),
),

                              ],
                            ),
                          ],
                        ),
                      ),

                      if (isWide) const SizedBox(width: 60),
                      const SizedBox(height: 40),

                      // Right side — Image (Updated & Working)
                      Expanded(
                        flex: isWide ? 1 : 0,
                        child:Image.network(
  "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80",
  height: isWide ? 400 : 300,
  fit: BoxFit.contain,
  errorBuilder: (context, error, stackTrace) {
    return SizedBox(
      height: isWide ? 400 : 300,
      child: Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey)),
    );
  },
),

                      ),
                    ],
                  ),

                  const SizedBox(height: 80),

                  // 🟧 Features Section
                  Text(
                    "Why Choose Cooksy?",
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 40,
                    runSpacing: 30,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.favorite,
                        title: "Save Recipes",
                        description:
                            "Keep your favorite meals in one place, ready anytime.",
                      ),
                      _buildFeatureCard(
                        icon: Icons.collections_bookmark,
                        title: "Create own recipe",
                        description:
                            "Organize your recipe easily.",
                      ),
                      _buildFeatureCard(
                        icon: Icons.restaurant_menu,
                        title: "Smart Suggestions",
                        description:
                            "Get meal ideas based on your taste and preferences.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 🧩 Reusable Feature Card
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.orangeAccent, size: 40),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
