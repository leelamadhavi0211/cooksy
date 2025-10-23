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
const port=5000
app.use(
  cors({
    origin: "https://cooksy-24914.web.app", // your Firebase app URL
  })
);
app.use(express.json());

/**
 * 🍱 Dynamic Recipes Route
 * Supports:
 *  /recipes               → Indian + Vegetarian
 *  /recipes?q=Breakfast   → Breakfast only
 *  /recipes?q=Seafood     → Seafood only
 *  /recipes?q=Dessert     → Dessert only
 *  /recipes?q=Vegetarian  → Vegetarian only
 */
app.get("/recipes", async (req, res) => {
  const query = req.query.q?.toLowerCase();

  try {
    let apiUrl;

    if (!query || query === "all") {
      // Default → Indian + Vegetarian
      const indianRes = await axios.get(
        "https://www.themealdb.com/api/json/v1/1/filter.php?a=Indian"
      );
      const vegRes = await axios.get(
        "https://www.themealdb.com/api/json/v1/1/filter.php?c=Vegetarian"
      );

      // Combine and remove duplicates
      const combined = [...indianRes.data.meals, ...vegRes.data.meals].filter(
        (v, i, a) => a.findIndex((t) => t.idMeal === v.idMeal) === i
      );
      return res.json(combined);
    }

    // Handle category-based filters
    const validCategories = ["breakfast", "dessert", "seafood", "vegetarian"];

    if (validCategories.includes(query)) {
      apiUrl = `https://www.themealdb.com/api/json/v1/1/filter.php?c=${query
        .charAt(0)
        .toUpperCase()}${query.slice(1)}`;
    } else {
      // fallback: search by meal name
      apiUrl = `https://www.themealdb.com/api/json/v1/1/search.php?s=${query}`;
    }

    const response = await axios.get(apiUrl);
    const meals = response.data.meals || [];

    if (meals.length === 0) {
      return res.status(404).json({ message: "No recipes found" });
    }

    res.json(meals);
  } catch (error) {
    console.error("Error fetching recipes:", error.message);
    res.status(500).json({ error: "Failed to fetch recipes" });
  }
});

/**
 * 🍲 Fetch recipe details by ID
 */
app.get("/recipes/:id", async (req, res) => {
  const recipeId = req.params.id;
  const url = `https://www.themealdb.com/api/json/v1/1/lookup.php?i=${recipeId}`;

  try {
    console.log(`Fetching recipe by ID: ${recipeId}`);
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
    console.error("Error fetching recipe details:", error.message);
    res.status(500).json({ error: "Failed to fetch recipe details" });
  }
});

app.listen(port, () =>
  console.log(`Backend running on http://localhost:${port}`)
);
