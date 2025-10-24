import express from "express";
import cors from "cors";
import axios from "axios";
import admin from "firebase-admin";
import { createRequire } from "module";
const require = createRequire(import.meta.url);
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const app = express();


// ✅ Allow all origins (for testing purposes)
app.use(cors());
app.use(express.json());

/**
 * 🍱 Fetch recipes dynamically
 * Supports:
 *   /recipes               → Indian + Vegetarian
 *   /recipes?q=Breakfast   → Breakfast
 *   /recipes?q=Seafood     → Seafood
 *   /recipes?q=Dessert     → Dessert
 *   /recipes?q=Vegetarian  → Vegetarian
 */
app.get("/recipes", async (req, res) => {
  const query = req.query.q?.toLowerCase();
  console.log(`📦 Fetching recipes for query: ${query || "all"}`);

  try {
    let apiUrl;

    // 🧡 Default: Combine Indian + Vegetarian
    if (!query || query === "all") {
      const indianRes = await axios.get(
        "https://www.themealdb.com/api/json/v1/1/filter.php?a=Indian"
      );
      const vegRes = await axios.get(
        "https://www.themealdb.com/api/json/v1/1/filter.php?c=Vegetarian"
      );

      const combined = [...indianRes.data.meals, ...vegRes.data.meals].filter(
        (v, i, a) => a.findIndex((t) => t.idMeal === v.idMeal) === i
      );

      return res.json(combined);
    }

    // 🥗 Category-specific fetch
    const validCategories = ["breakfast", "dessert", "seafood", "vegetarian"];
    if (validCategories.includes(query)) {
      const formatted =
        query.charAt(0).toUpperCase() + query.slice(1).toLowerCase();
      apiUrl = `https://www.themealdb.com/api/json/v1/1/filter.php?c=${formatted}`;
    } else {
      // 🕵️ Search fallback
      apiUrl = `https://www.themealdb.com/api/json/v1/1/search.php?s=${query}`;
    }

    const response = await axios.get(apiUrl);
    const meals = response.data.meals || [];

    if (!meals.length) {
      return res.status(404).json({ message: "No recipes found" });
    }

    res.json(meals);
  } catch (error) {
    console.error("❌ Error fetching recipes:", error.message);
    res.status(500).json({ error: "Failed to fetch recipes" });
  }
});

/**
 * 🍲 Fetch recipe details by ID
 */
app.get("/recipes/:id", async (req, res) => {
  const recipeId = req.params.id;
  const url = `https://www.themealdb.com/api/json/v1/1/lookup.php?i=${recipeId}`;
  console.log(`🔍 Fetching recipe by ID: ${recipeId}`);

  try {
    const response = await axios.get(url);
    const meal = response.data.meals ? response.data.meals[0] : null;

    if (!meal) {
      return res.status(404).json({ error: "Recipe not found" });
    }

    const recipeDetails = {
      id: meal.idMeal,
      title: meal.strMeal,
      image: meal.strMealThumb,
      category: meal.strCategory,
      area: meal.strArea,
      instructions: meal.strInstructions,
      youtube: meal.strYoutube,
      ingredients: Object.keys(meal)
        .filter((key) => key.startsWith("strIngredient") && meal[key])
        .map((key) => meal[key]),
    };

    res.json(recipeDetails);
  } catch (error) {
    console.error("❌ Error fetching recipe details:", error.message);
    res.status(500).json({ error: "Failed to fetch recipe details" });
  }
});

// ✅ For Render (uses PORT env variable)
const PORT = process.env.PORT || 5000;
app.listen(PORT, () =>
  console.log(`✅ Backend running on port ${PORT}`)
);
