# 📱 Flutter App Pages Analysis

## App Structure Overview

Your Flutter app is a **Restaurant Discovery & Reservation App** with the following architecture:

```
main.dart (AppScreen)
├── AuthScreen (Login/Register)
└── Authenticated App
    ├── HomeScreen (Search & Discover)
    ├── FavoritesScreen (Saved Restaurants)
    ├── ReservationsScreen (Manage Bookings)
    ├── ProfileScreen (User/Owner/Delivery)
    ├── RestaurantDetail (Full Restaurant Info)
    └── AIChatbot (AI Assistant Overlay)
```

---

## 🏠 Main Pages Description

### 1. **HomeScreen** (`lib/Pages/HomeScreen.dart`)
- **Purpose**: Main discovery page for restaurants
- **Features**:
  - Search bar with filters
  - Quick cuisine filters (Italien, Français, Japonais, etc.)
  - Restaurant cards list
  - Map view toggle
  - Filter sheet overlay (price, rating, distance, cuisine)
- **State**: Search query, filters, map/list view
- **Navigation**: Click restaurant → RestaurantDetail

---

### 2. **FavoritesScreen** (`lib/Pages/FavoritesScreen.dart`)
- **Purpose**: User's saved and recommended restaurants
- **Features**:
  - 3 tabs:
    - **Favoris**: Saved favorite restaurants
    - **Récemment vus**: Recently viewed
    - **Recommandations**: AI recommendations
  - Restaurant cards with quick actions
  - Statistics (total favorites, average rating)
- **Data**: Uses `mockRestaurants` (needs backend integration)

---

### 3. **ReservationsScreen** (`lib/Pages/ReservationsScreen.dart`)
- **Purpose**: Manage restaurant reservations
- **Features**:
  - 3 tabs:
    - **À venir**: Upcoming confirmed reservations
    - **Passées**: Past completed reservations
    - **Annulées**: Cancelled reservations
  - Reservation cards with:
    - Restaurant info (image, name, cuisine)
    - Date, time, number of guests
    - Action buttons (cancel, view details)
  - QR code generation for confirmed bookings
- **Data**: Uses `mockReservations` (needs backend integration)

---

### 4. **RestaurantDetail** (`lib/Pages/RestaurantDetail.dart`)
- **Purpose**: Full restaurant information page
- **Features**:
  - Hero image with parallax scroll
  - Favorite & share buttons
  - Restaurant info (name, rating, price range, distance)
  - 3 tabs:
    - **Menu**: List of dishes with prices
    - **À propos**: Description, hours, address, map
    - **Avis**: Reviews and ratings
  - Floating reservation button
  - Call & directions buttons
- **State**: Favorite status, selected tab

---

### 5. **ProfileScreen** (`lib/Pages/Auth/ProfileScreen.dart`) ⭐
**This is your current focus - detailed below**

---

### 6. **AIChatbot** (`lib/Pages/AIChatbot.dart`)
- **Purpose**: AI assistant for restaurant recommendations
- **Features**:
  - Slide-in drawer overlay
  - Chat interface with AI responses
  - Suggestion chips for quick queries
  - Message history
  - Voice input option
- **Use cases**: "Restaurant italien près de moi", "Meilleur sushi à Paris"

---

## 👤 ProfileScreen - Complete Breakdown

### **Three Role-Specific Interfaces**

#### **1. USER Profile** (role: 'user')
Shows:
- **Header**: Avatar, name, email
- **Personal Info Card**: Name, email, location (editable)
- **Culinary Preferences Card**:
  - Cuisine type chips (add/remove)
  - Budget slider (0-100€)
  - Dietary restrictions toggle
- **Settings Card**:
  - Notifications toggle
  - Dark mode toggle
  - Biometric login toggle
- **Action Buttons**: Save changes, Logout

#### **2. DELIVERY Profile** (role: 'delivery')
Shows:
- **Header**: Avatar, name, email, "Livreur actif" badge
- **Personal Info Card**: Name, email
- **Contact Card**: Phone number, vehicle type
- **Settings Card**: Notifications, biometric login
- **Action Buttons**: Save, Logout

#### **3. OWNER Profile** (role: 'owner') 🎯 **Your Focus**
Shows:
- **Header**: 
  - Avatar with edit button
  - Owner name & email
  - Restaurant name badge (green theme)
- **Personal Info Card**: 
  - Owner name
  - Contact email
- **Restaurant Details Card**:
  - Restaurant name
  - Restaurant address
- **Cuisine Types Card**:
  - Add/remove cuisine chips
  - Visual chips with green gradient
- **Settings Card**:
  - Notifications
  - Biometric login
- **Action Buttons**: 
  - Save changes (green button)
  - Logout (red outlined)

---

## 🔄 Data Flow

### Current State:
- **Auth**: User logs in → userId & role saved in SharedPreferences
- **Profile Load**: ProfileScreen reads userId/role → loads from backend
- **Profile Save**: Updates sent to backend via AuthService

### Backend Integration Points:
```dart
AuthService:
- getProfile(userId) → UserProfile
- getOwnerProfile(userId) → OwnerProfile
- getDeliveryProfile(userId) → DeliveryProfile
- updateProfile(profile) → bool
- updateOwnerProfile(profile) → bool
- updateDeliveryProfile(profile) → bool
- uploadAvatar(userId, base64) → url
- uploadOwnerAvatar(userId, base64) → url
```

---

## 🎨 UI Components Used

- **Custom Cards**: White background, rounded corners, shadow
- **Gradient Headers**: Blue-purple (user), Green (owner), Blue (delivery)
- **Avatar**: Circular with initials fallback, editable
- **Cuisine Chips**: Gradient tags with remove button
- **Text Fields**: Material design with icons
- **Switches**: For toggles (notifications, dark mode, biometric)
- **Sliders**: Budget selection
- **Buttons**: Elevated (save), Outlined (logout)

---

## 📊 Owner-Specific Features (Current)

### What the Owner Profile Has:
✅ Avatar upload
✅ Personal info (name, email)
✅ Restaurant name & address
✅ Cuisine types selection (multiple)
✅ Notification settings
✅ Biometric login
✅ Save/logout actions

### What's Missing for Full Owner Dashboard:
❌ Restaurant list (if owner has multiple)
❌ Dish management (add/edit dishes)
❌ Menu builder
❌ Reservation management
❌ Analytics/stats
❌ Restaurant images upload
❌ Hours of operation editor
❌ Direct link to restaurant CRUD APIs

---

## 🔗 Next Steps for Owner Role

Since you now have:
- ✅ Restaurant CRUD API (`/restaurants/`)
- ✅ Dish CRUD API (`/dishes/`)
- ✅ Owner profile system

You should add to ProfileScreen (Owner):
1. **"Mes Restaurants" button** → Navigate to restaurant list
2. **Create new restaurant** → Form using your API
3. **Edit restaurant** → Update via PUT /restaurants/{id}
4. **Manage dishes** → Add/edit dishes per restaurant
5. **View reservations** → Filter by owner's restaurants

---

## 🎯 ProfileScreen Full Code

The complete ProfileScreen.dart code (2035 lines) includes:

### Key Methods:
- `_initializeProfile()` - Loads user data on mount
- `_loadUserProfile()` - Fetches user data
- `_loadOwnerProfile()` - Fetches owner data ⭐
- `_loadDeliveryProfile()` - Fetches delivery data
- `_saveChanges()` - Saves profile updates
- `_pickAndUploadAvatar()` - Image picker & upload
- `_showAddCuisineDialog()` - Multi-select cuisine picker
- `_toggleBiometric()` - Enable/disable fingerprint

### UI Builders:
- `_buildHeader()` - Gradient header with avatar
- `_buildPersonalInfoCard()` - Name, email, location
- `_buildCulinaryPreferencesCard()` - Cuisines, budget
- `_buildSettingsCard()` - Toggles
- `_buildActionButtons()` - Save & logout

### Owner-Specific:
- `_buildRestaurantHeader()` - Green gradient header
- `_buildRestaurantPersonalInfoCard()` - Owner info
- `_buildRestaurantDetailsCard()` - Restaurant name & address
- `_buildRestaurantCuisinesCard()` - Cuisine chips
- `_buildRestaurantSettingsCard()` - Settings
- `_buildRestaurantActionButtons()` - Green save button

---

## 📝 Summary for You

**You asked for ProfileScreen content - here it is!**

The ProfileScreen adapts to 3 roles:
1. **User** - Personal preferences & favorites
2. **Delivery** - Contact & vehicle info
3. **Owner** - Restaurant management basics ⭐

**For your owner dashboard**, you need to:
1. Add navigation to restaurant list
2. Connect to your new `/restaurants/` API
3. Add dish management UI using `/dishes/` API
4. Build restaurant creation/edit forms

Would you like me to:
- Create a new **OwnerDashboard page** with restaurant & dish management?
- Add restaurant list view to the profile?
- Create forms to add/edit restaurants using your API?
