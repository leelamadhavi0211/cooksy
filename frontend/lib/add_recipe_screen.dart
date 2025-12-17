import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

/*class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}*/
class AddRecipeScreen extends StatefulWidget {
  final String? recipeId; // <-- New
  final Map<String, dynamic>? recipeData; // <-- New

  const AddRecipeScreen({super.key, this.recipeId, this.recipeData}); // <-- New constructor

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _imageController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _videoController = TextEditingController();
  bool isSaving = false;

  Future<void> saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please log in first!")),
        );
        return;
      }

      // 👇 Save under users/<uid>/recipes/
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('recipes')
          .add({
        'name': _nameController.text,
        'image': _imageController.text,
        'instructions': _instructionsController.text,
        'video': _videoController.text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Recipe added successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding recipe: $e")),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text("Add New Recipe"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Recipe Name"),
                validator: (value) =>
                    value!.isEmpty ? "Enter recipe name" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: "Image URL"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _instructionsController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: "Instructions"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _videoController,
                decoration:
                    const InputDecoration(labelText: "Video Link (optional)"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSaving ? null : saveRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                ),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Save Recipe",
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
