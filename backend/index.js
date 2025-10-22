import express from "express";
import cors from "cors";
import axios from "axios";

const app = express();
app.use(cors({
  origin: "https://cooksy-24914.web.app" // your frontend URL
}));
app.use(express.json());

/* ============================
   ✅ In-memory cache
============================ */
let cachedRecipes = [];
let lastFetched = 0;
const CACHE_DURATION = 1000 * 60 * 10; // 10 minutes

/* ============================
   ✅ Get combined recipes
============================ */
app.get("/recipes", async (req, res) => {
  try {
    // Return cached data if fresh
    if (cachedRecipes.length && (Date.now() - lastFetched < CACHE_DURATION)) {
      return res.json(cachedRecipes);
    }

    // Fetch Indian recipes
    const indianRes = await axios.get("https://www.themealdb.com/api/json/v1/1/filter.php?a=Indian");
    // Fetch Vegetarian recipes
    const vegRes = await axios.get("https://www.themealdb.com/api/json/v1/1/filter.php?c=Vegetarian");

    // Combine & remove duplicates
    const combined = [...indianRes.data.meals, ...vegRes.data.meals].filter(
      (v, i, a) => a.findIndex(t => t.idMeal === v.idMeal) === i
    );

    // Update cache
    cachedRecipes = combined;
    lastFetched = Date.now();

    res.json(combined);
  } catch (error) {
    console.error("Error fetching recipes:", error.message);
    res.status(500).json({ error: "Failed to fetch recipes" });
  }
});

/* ============================
   ✅ Get recipe by ID
============================ */
app.get("/recipes/:id", async (req, res) => {
  const recipeId = req.params.id;
  const url = `https://www.themealdb.com/api/json/v1/1/lookup.php?i=${recipeId}`;

  try {
    const response = await axios.get(url);
    const meal = response.data.meals ? response.data.meals[0] : null;

    if (!meal) return res.status(404).json({ error: "Recipe not found" });

    // Format details
    const recipeDetails = {
      id: meal.idMeal,
      title: meal.strMeal,
      image: meal.strMealThumb,
      category: meal.strCategory,
      area: meal.strArea,
      instructions: meal.strInstructions,
      youtube: meal.strYoutube,
      ingredients: Object.keys(meal)
        .filter(k => k.startsWith("strIngredient") && meal[k])
        .map(k => meal[k]),
    };

    res.json(recipeDetails);
  } catch (error) {
    console.error("Error fetching recipe details:", error.message);
    res.status(500).json({ error: "Failed to fetch recipe details" });
  }
});

/* ============================
   ✅ Start Server
============================ */
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`✅ Backend running on http://localhost:${PORT}`));
