/*import express from "express";
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
app.use(cors());
app.use(express.json());

// ✅ Example Recipe API (Spoonacular)
app.get("/recipes", async (req, res) => {
  const query = req.query.q || "pasta";
  const API_KEY = "20b14e165c5e4e8581c3957a9470cf41"; // Replace with your actual API key
  const url = `https://api.spoonacular.com/recipes/complexSearch?query=${query}&apiKey=${API_KEY}`;

  try {
    const response = await axios.get(url);
    res.json(response.data.results);
  } catch (error) {
    console.error("Error fetching recipes:", error.message);
    res.status(500).json({ error: "Failed to fetch recipes" });
  }
});

app.listen(5000, () => console.log("✅ Backend running on http://localhost:5000"));

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
app.use(cors());
app.use(express.json());

// ✅ Signup endpoint
app.post("/signup", async (req, res) => {
  const { email, password, name } = req.body;

  try {
    // Create user in Firebase Authentication
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: name,
    });

    // Save user data in Firestore
    await db.collection("users").doc(userRecord.uid).set({
      email,
      name,
      createdAt: new Date(),
    });

    res.json({ uid: userRecord.uid, email, name });
  } catch (error) {
    console.error("Error creating user:", error.message);
    res.status(500).json({ error: error.message });
  }
});

// ✅ Login endpoint (verify email/password)
app.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    // Firebase Admin SDK does not directly verify passwords.
    // For email/password login from backend, usually you authenticate via Firebase client SDK in Flutter/web.
    // Here we can just fetch user by email as a simple example:
    const userRecord = await admin.auth().getUserByEmail(email);
    res.json({ uid: userRecord.uid, email: userRecord.email, name: userRecord.displayName });
  } catch (error) {
    console.error("Login error:", error.message);
    res.status(400).json({ error: "User not found" });
  }
});

app.get("/recipes", async (req, res) => {
  const query = req.query.q || "indian";
  const url = `https://www.themealdb.com/api/json/v1/1/search.php?s=${query}`;

  try {
    const response = await axios.get(url);
    const meals = response.data.meals || [];
    res.json(meals);
  } catch (error) {
    console.error("Error fetching recipes:", error.message);
    res.status(500).json({ error: "Failed to fetch recipes" });
  }
});


app.get("/proxy-image", async (req, res) => {
  const imageUrl = req.query.url;
  try {
    const response = await axios.get(imageUrl, { responseType: "arraybuffer" });
    res.set("Content-Type", "image/jpeg");
    res.send(response.data);
  } catch (error) {
    res.status(500).send("Failed to load image");
  }
});
app.get("/recipes/:id", async (req, res) => {
  const recipeId = req.params.id;
  const url = `https://indian-food-api.vercel.app/api/recipes`;

  try {
    const response = await axios.get(url);
    const recipes = response.data;

    // Find recipe by ID
    const recipe = recipes.find(r => r.id.toString() === recipeId);

    if (recipe) {
      res.json(recipe);
    } else {
      res.status(404).json({ error: "Recipe not found" });
    }
  } catch (error) {
    console.error("Error fetching recipe by ID:", error.message);
    res.status(500).json({ error: "Failed to fetch recipe" });
  }
});


app.listen(5000, () => console.log("✅ Backend running on http://localhost:5000"));*/
import express from "express";
import cors from "cors";
import axios from "axios";
import admin from "firebase-admin";
import { createRequire } from "module";
const require = createRequire(import.meta.url);
const serviceAccount = require("./serviceAccountKey.json");

// 🔥 Initialize Firebase Admin
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
