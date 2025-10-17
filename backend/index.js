import express from "express";
import cors from "cors";
import axios from "axios";
import admin from "firebase-admin";
import dotenv from "dotenv";

dotenv.config(); // load .env variables

const serviceAccount = {
  type: "service_account",
  project_id: process.env.FIREBASE_PROJECT_ID,
  client_email: process.env.FIREBASE_CLIENT_EMAIL,
  private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
};

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});


const db = admin.firestore();
const app = express();
app.use(cors());
app.use(express.json());

app.get("/recipes", async (req, res) => {
  try {
    // 1️⃣ Fetch Indian recipes
    const indianRes = await axios.get(
      "https://www.themealdb.com/api/json/v1/1/filter.php?a=Indian"
    );

    // 2️⃣ Fetch vegetarian recipes
    const vegRes = await axios.get(
      "https://www.themealdb.com/api/json/v1/1/filter.php?c=Vegetarian"
    );

    // 3️⃣ Combine lists (remove duplicates)
    const combined = [...indianRes.data.meals, ...vegRes.data.meals].filter(
      (v, i, a) => a.findIndex(t => t.idMeal === v.idMeal) === i
    );

    res.json(combined);
  } catch (error) {
    console.error(error.message);
    res.status(500).json({ error: "Failed to fetch recipes" });
  }
});

/* ============================
   ✅ 2. GET recipe details by ID
============================ */
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

    // Format details nicely
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

/* ============================
   ✅ Start Server
============================ */
app.listen(5000, () => console.log("✅ Backend running on http://localhost:5000"));
