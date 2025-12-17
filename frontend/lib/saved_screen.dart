import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // If user not logged in
    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xfffffaf5),
        body: Center(
          child: Text(
            "Please log in to see your saved recipes 🍳",
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_recipes');

    return Scaffold(
      backgroundColor: const Color(0xfffffaf5),
      appBar: AppBar(
        title: Text(
          "Saved Recipes ❤️",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
        elevation: 2,
      ),

      // 🔥 Real-time updates from Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: userRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "No saved recipes yet 😋",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final recipe = docs[index].data() as Map<String, dynamic>;
              final recipeId = docs[index].id;
              final name = recipe['strMeal'] ?? recipe['title'] ?? "Untitled Recipe";
              final image = recipe['strMealThumb'] ?? recipe['image'] ?? '';
              final category = recipe['strCategory'] ?? '';

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: image.isNotEmpty
                        ? Image.network(image, width: 60, height: 60, fit: BoxFit.cover)
                        : const Icon(Icons.fastfood, color: Colors.orangeAccent, size: 40),
                  ),
                  title: Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    category,
                    style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 13),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      await userRef.doc(recipeId).delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Recipe removed ❌")),
                      );
                    },
                  ),
                  onTap: () {
                    // Optionally navigate to recipe detail screen
                    // Navigator.pushNamed(context, '/recipeDetail', arguments: recipe);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
