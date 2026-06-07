#  Cooksy – Recipe Sharing Web Application

## Introduction

Cooksy is a Flutter Web-based recipe sharing and management platform that allows users to explore recipes, save favorites, and create their own personalized recipe collections. The application provides a user-friendly interface for discovering meals, viewing recipe details, and managing custom recipes securely through Firebase Authentication and Cloud Firestore.

The primary goal of Cooksy is to provide a centralized platform where users can browse existing recipes, save recipes for future reference, and contribute their own recipes while maintaining secure access to personal data.

---

## Frontend

The frontend of Cooksy is developed using **Flutter Web** and **Dart**, providing a responsive and modern user interface.

### Frontend Features

* User Registration and Login
* Recipe Browsing and Search
* Recipe Detail View
* Save Favorite Recipes
* Add New Recipes
* Edit Existing Recipes
* Delete Recipes
* User Profile Management
* Responsive Web Interface
* Route Protection using AuthGuard

### Flutter Widgets Used

* MaterialApp
* Scaffold
* AppBar
* TextField
* GridView
* ListView
* Card
* ElevatedButton
* StreamBuilder
* FutureBuilder
* Navigator
* PopupMenuButton
* SnackBar

---

## Backend

Cooksy uses a hybrid backend architecture consisting of:

### 1. Node.js + Express Backend

A custom REST API backend built using Node.js and Express is deployed on Render.

Responsibilities:

* Fetch recipes from external APIs
* Process recipe search requests
* Handle category-based filtering
* Provide recipe details to the Flutter frontend

### Backend URL

[https://cooksy-backend-z82c.onrender.com]

### Main API Endpoints

#### Get Recipes

GET /recipes

Returns available recipes.

#### Search Recipes

GET /recipes?q=keyword

Searches recipes by category or name.

#### Recipe Details

GET /recipes/:id

Returns complete details of a selected recipe.

---

## External API Integration

Cooksy uses **TheMealDB API** as its primary recipe data source.

### APIs Used

#### Fetch Recipes by Category

[https://www.themealdb.com/api/json/v1/1/filter.php?c=Category]

#### Fetch Recipes by Area

[https://www.themealdb.com/api/json/v1/1/filter.php?a=Indian]

#### Search Recipes

[https://www.themealdb.com/api/json/v1/1/search.php?s=RecipeName]

#### Fetch Recipe Details

[https://www.themealdb.com/api/json/v1/1/lookup.php?i=RecipeID]

The backend communicates with TheMealDB API and forwards the processed data to the Flutter frontend.

---

## Database

Cooksy uses **Firebase Cloud Firestore** as its primary database.

### Collections Used

#### Users Collection

users

Stores:

* User ID
* Email
* Profile Information

#### User Recipes Collection

users/{uid}/recipes

Stores:

* Recipe Name
* Image URL
* Instructions
* Video URL
* Creation Timestamp

#### Saved Recipes Collection

users/{uid}/savedRecipes

Stores recipes bookmarked by users.

---

## Authentication

Cooksy uses **Firebase Authentication**.

### Supported Features

* User Registration
* User Login
* User Logout
* Session Management
* Protected Routes

Only authenticated users can:

* Add recipes
* Edit recipes
* Delete recipes
* Save recipes
* Access profile information

---

## Application Workflow

1. User visits Dashboard.
2. User logs in or registers.
3. Home screen loads recipes from backend APIs.
4. User can search or filter recipes.
5. User can view recipe details.
6. User can save favorite recipes.
7. User can create custom recipes.
8. Custom recipes are stored in Firestore.
9. User can edit or delete their recipes.
10. User profile displays personal information and recipe collections.

---

## Security Features

### Frontend Security

* Route protection using AuthGuard.
* Restricted access to authenticated pages.
* Automatic redirection to Login after logout.

### Backend Security

* Firebase Authentication validation.
* Firestore security rules.
* User-specific data isolation.

### Firestore Rules

Users can only access their own recipes and saved data.

---

## Deployment

### Frontend Hosting

Firebase Hosting

Website:

[https://cooksy-24914.web.app/]

### Backend Hosting

Render

Backend API:

[https://cooksy-backend-z82c.onrender.com]

---

## Technologies Used

### Frontend

* Flutter Web
* Dart
* Material Design
* Google Fonts

### Backend

* Node.js
* Express.js
* Axios
* REST APIs

### Database

* Firebase Firestore

### Authentication

* Firebase Authentication

### Hosting

* Firebase Hosting
* Render

---

# 8. Screens

## Figure 8.1: Dashboard Screen

<img width="1366" height="768" alt="Screenshot (129)" src="https://github.com/user-attachments/assets/ccac436e-5284-4020-af5c-c5c2eca0059b" />

The Dashboard Screen serves as the landing page of the Cooksy application. It provides users with an introduction to the platform and highlights the key functionalities available. Users can choose to explore recipes, sign up for a new account, or log in to access personalized features.

**Features:**

* Welcome section
* Navigation to Login and Signup
* Explore Recipes preview
* User-friendly interface

---

## Figure 8.2: Login Screen

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/c875d23f-0ec9-4381-9c26-d1cfd84745c6" />

The Login Screen allows registered users to securely access their accounts using their email address and password. Firebase Authentication is used to validate user credentials and maintain secure sessions.

**Features:**

* Email authentication
* Password authentication
* Form validation
* Secure login using Firebase Auth

---

## Figure 8.3: Signup Screen

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/d811f8e6-69d2-4463-95ac-93971c43982a" />

The Signup Screen enables new users to create an account in the Cooksy application. User information is stored securely through Firebase Authentication and Firestore.

**Features:**

* New account registration
* Input validation
* Firebase Authentication integration
* User profile creation

---

## Figure 8.4: Recipes Dashboard (Home Screen)

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/da347093-0098-4350-be28-27916b9a3992" />


The Recipes Dashboard is the main interface where users can browse and discover recipes. Recipes are fetched from the backend API and displayed in an organized layout. Users can search recipes, view details, and save favorite recipes.

**Features:**

* Recipe listing
* Search functionality
* Category filtering
* Save recipes
* Recipe detail navigation

---
### Figure 8.5:Recipe Detail Screen

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/8a1ef967-7e6b-4e09-b13a-32773387aa84" />


The Recipe Detail Screen provides comprehensive information about a selected recipe. It displays the recipe image, ingredients, cooking instructions, and other relevant details fetched from the backend API. This screen helps users understand the complete preparation process before attempting the recipe.

Features:

Recipe image display
Detailed cooking instructions
Ingredients information
API-driven content
User-friendly layout

## Figure 8.5: Create New Recipe Screen

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/b3771b54-e281-46cc-9705-0bd835151584" />

The Create New Recipe Screen allows authenticated users to add their own recipes to the platform. Users can enter recipe details such as recipe name, image URL, instructions, and an optional video link. The recipe data is stored in Firebase Firestore under the user's account.

**Features:**

* Add custom recipes
* Recipe image support
* Cooking instructions
* Optional video links
* Firestore database integration



## Future Enhancements

* AI-based meal recommendations
* Nutritional analysis
* Recipe ratings and reviews
* Social sharing features
* Meal planner integration
* Image upload support
* Recipe recommendation system

---

## Conclusion

Cooksy is a full-stack Flutter Web application that combines Flutter, Firebase, Node.js, and REST APIs to provide a secure and interactive recipe management platform. The application demonstrates frontend development, backend API integration, authentication, database management, CRUD operations, and cloud deployment in a single project.

