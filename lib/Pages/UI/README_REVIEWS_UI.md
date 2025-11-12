# Restaurant Reviews UI Implementation Guide

## Overview
This guide explains how to integrate the reviews system UI components into your Flutter restaurant app.

## Components Created

### 1. StarRating Widget (`lib/Pages/UI/StarRating.dart`)
Reusable widgets for displaying and selecting star ratings.

**StarRating (Display Only)**
- Shows star ratings with support for half stars
- Customizable size, color, and star count
- Example: ★★★★☆ (4.5/5)

**InteractiveStarRating (User Input)**
- Allows users to select a rating by tapping stars
- Callback function for rating changes
- Used in the Add/Edit Review Modal

### 2. ReviewCard Widget (`lib/Pages/UI/ReviewCard.dart`)
Displays individual review information in a card format.

**Features:**
- User avatar and name
- Star rating display
- Review comment text
- Date of submission
- Edit/Delete actions (when user owns the review)
- Optional restaurant name display

### 3. AddReviewModal (`lib/Pages/AddReviewModal.dart`)
Modal bottom sheet for adding or editing reviews.

**Features:**
- Interactive star selector (1-5 stars)
- Optional text input for comments (max 500 characters)
- Real-time rating description ("Excellent!", "Bien", etc.)
- Submit button with loading state
- Automatic update if user already reviewed
- Error handling and success feedback

### 4. RestaurantReviewsSection (`lib/Pages/UI/RestaurantReviewsSection.dart`)
Complete reviews section for restaurant detail screens.

**Features:**
- Average rating display with star visualization
- Total review count
- Rating distribution bars (5★, 4★, 3★, 2★, 1★)
- Add/Edit review button
- List of all reviews with user information
- Empty state when no reviews exist
- Automatic refresh after adding/editing reviews

### 5. OwnerReviewsDashboard (`lib/Pages/OwnerReviewsDashboard.dart`)
Dashboard screen for restaurant owners to view customer feedback.

**Features:**
- Restaurant selector dropdown (when owner has multiple restaurants)
- Summary statistics cards:
  - Average rating with stars
  - Total reviews count
  - Recent reviews (last 7 days)
- Complete reviews list with customer details
- Read-only mode (owners cannot edit customer reviews)
- Pull-to-refresh functionality

---

## Integration Instructions

### Step 1: Add Reviews Section to Restaurant Detail Screen

Open your existing restaurant detail screen (e.g., `RestaurantDetail.dart`) and add the reviews section:

```dart
import 'package:mobile_app_project/Pages/UI/RestaurantReviewsSection.dart';

// In your build method, add this after restaurant info:
Column(
  children: [
    // ... existing restaurant info widgets ...
    
    // Add reviews section
    RestaurantReviewsSection(
      restaurantId: widget.restaurantId,
      restaurantName: restaurantName,
    ),
    
    const SizedBox(height: 24),
  ],
)
```

### Step 2: Add Reviews Tab to Owner Dashboard

Update your `OwnerDashboard.dart` to include a reviews section:

**Option A: Add as a new tab/screen**
```dart
import 'package:mobile_app_project/Pages/OwnerReviewsDashboard.dart';

// Add a button or tab that navigates to:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const OwnerReviewsDashboard(),
  ),
);
```

**Option B: Add as a navigation item in main.dart**
```dart
// In your navigation logic, add:
case 'owner_reviews':
  return const OwnerReviewsDashboard();
```

### Step 3: Update Navigation for Owners

In `main.dart`, update the bottom navigation for owners to include a reviews button:

```dart
_userRole == 'owner'
  ? _buildNavButton(
      icon: Icons.rate_review,
      label: 'Avis',
      screen: 'owner_reviews',
    )
  : _buildNavButton(...),
```

---

## Usage Examples

### Display Restaurant Reviews
```dart
// Simple integration
RestaurantReviewsSection(
  restaurantId: 123,
  restaurantName: "Le Bon Restaurant",
)
```

### Show Add Review Modal
```dart
void _showAddReviewModal() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AddReviewModal(
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        onReviewSubmitted: () {
          // Refresh the reviews list
          setState(() {});
        },
      ),
    ),
  );
}
```

### Display Individual Review Card
```dart
ReviewCard(
  review: {
    'id': 1,
    'user_name': 'Jean Dupont',
    'rating': 4.5,
    'comment': 'Excellent restaurant!',
    'created_at': '2025-11-12T10:30:00',
    'user_avatar': 'https://...',
  },
  canEdit: false,
)
```

---

## User Experience Flow

### For Regular Users:

1. **View Restaurant**
   - User opens restaurant detail page
   - Sees average rating and total reviews at top
   - Scrolls down to see all customer reviews

2. **Add Review**
   - Clicks "Laisser un avis" button
   - Modal opens with star selector and comment field
   - Selects rating (1-5 stars)
   - Optionally writes comment
   - Clicks "Publier l'avis"
   - Review is saved and page refreshes automatically

3. **Edit Review**
   - If user already reviewed, button shows "Modifier mon avis"
   - Modal opens with existing rating and comment pre-filled
   - User modifies rating/comment
   - Clicks "Mettre à jour"
   - Review is updated and page refreshes

4. **Delete Review**
   - User finds their own review in the list
   - Clicks three-dot menu on their review card
   - Selects "Supprimer"
   - Confirmation dialog appears
   - Review is deleted after confirmation

### For Restaurant Owners:

1. **View Dashboard**
   - Owner opens "Avis" section from navigation
   - Sees summary cards with key metrics
   - Views all customer reviews for their restaurant(s)

2. **Switch Restaurants**
   - If owner has multiple restaurants
   - Uses dropdown to switch between them
   - Data refreshes automatically

3. **Monitor Feedback**
   - Sees who reviewed and when
   - Reads customer comments
   - Cannot edit or delete customer reviews
   - Uses feedback to improve service

---

## Customization Options

### Colors
Change the primary color scheme by updating:
```dart
const Color(0xFF10B981) // Green color
const Color(0xFFFFC107) // Gold star color
```

### Star Count
Modify the number of stars (default is 5):
```dart
StarRating(
  rating: 4.5,
  starCount: 10, // Change to 10 stars
)
```

### Comment Length
Adjust maximum comment length in `AddReviewModal.dart`:
```dart
maxLength: 500, // Change to your preferred limit
```

### Date Format
Customize date display in `ReviewCard.dart`:
```dart
DateFormat('dd MMM yyyy', 'fr_FR').format(date)
// Change to: 'yyyy-MM-dd' or any format you prefer
```

---

## Best Practices

### 1. User Authentication
Always check if user is logged in before allowing reviews:
```dart
final prefs = await SharedPreferences.getInstance();
final userId = prefs.getInt('userId');
if (userId == null) {
  // Show login prompt
  return;
}
```

### 2. Loading States
Show loading indicators while fetching data:
```dart
if (_isLoading) {
  return const CircularProgressIndicator();
}
```

### 3. Error Handling
Display user-friendly error messages:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text('Erreur: $error')),
);
```

### 4. Refresh After Changes
Always reload data after adding/editing/deleting reviews:
```dart
onReviewSubmitted: () {
  _loadData(); // Refresh the reviews list
}
```

### 5. Empty States
Show helpful messages when no reviews exist:
```dart
if (reviews.isEmpty) {
  return Center(
    child: Text('Aucun avis pour le moment'),
  );
}
```

---

## Testing Checklist

- [ ] User can view restaurant ratings and reviews
- [ ] User can add a new review with rating and comment
- [ ] User can edit their own review
- [ ] User can delete their own review
- [ ] User cannot review the same restaurant twice (without editing)
- [ ] Average rating updates correctly after each review change
- [ ] Review count updates correctly
- [ ] Owner can view all reviews for their restaurants
- [ ] Owner cannot edit customer reviews
- [ ] Date formats correctly in French
- [ ] Star ratings display properly (including half stars)
- [ ] Loading states show during data fetches
- [ ] Error messages display when operations fail
- [ ] Success messages show after successful operations
- [ ] Modal closes after successful submission
- [ ] Page refreshes automatically after changes

---

## Future Enhancements

Consider adding these features:
- Review photos/images
- Restaurant owner responses to reviews
- Helpful/unhelpful voting on reviews
- Report inappropriate reviews
- Filter reviews by rating
- Sort reviews (newest, highest rated, etc.)
- Review moderation for admins
- Email notifications for new reviews
- Review response templates for owners
- Analytics dashboard with rating trends

---

## Troubleshooting

### Reviews not showing
- Check if database migration ran successfully (version 5)
- Verify ReviewService is properly initialized
- Check console for error messages

### User cannot add review
- Verify user is logged in (userId exists in SharedPreferences)
- Check rating is between 0 and 5
- Ensure restaurant exists in database

### Ratings not updating
- Check if `_updateRestaurantRating()` is being called
- Verify `restaurant_ratings` table exists
- Check for SQL errors in console

### Date format issues
- Ensure intl package is installed: `flutter pub add intl`
- Import DateFormat: `import 'package:intl/intl.dart';`
- Check date string format from database

---

## Support

For issues or questions:
1. Check console logs for detailed error messages
2. Verify database schema matches documentation
3. Ensure all dependencies are installed
4. Review the ReviewService documentation
