# ReviewService Documentation

## Overview
`ReviewService` is a comprehensive service class that manages all operations related to restaurant reviews and ratings in the FoodFinder app. It provides methods for creating, updating, deleting, and querying reviews, as well as maintaining aggregated rating data for restaurants.

## Database Schema

### reviews Table
Stores all user ratings and comments for restaurants.

```sql
CREATE TABLE reviews (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  restaurant_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  rating REAL CHECK (rating >= 0 AND rating <= 5),
  comment TEXT DEFAULT '',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### restaurant_ratings Table
Stores pre-calculated average ratings and total number of reviews per restaurant for faster display.

```sql
CREATE TABLE restaurant_ratings (
  restaurant_id INTEGER PRIMARY KEY,
  average_rating REAL DEFAULT 0.0,
  total_reviews INTEGER DEFAULT 0,
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id) ON DELETE CASCADE
);
```

## Usage

### Singleton Instance
```dart
ReviewService.instance
```

## Methods

### 1. addReview
Add a new review for a restaurant. If the user has already reviewed this restaurant, it will update the existing review.

**Signature:**
```dart
Future<int> addReview({
  required int restaurantId,
  required int userId,
  required double rating,
  String comment = '',
})
```

**Parameters:**
- `restaurantId`: The ID of the restaurant being reviewed
- `userId`: The ID of the user submitting the review
- `rating`: The rating value (0.0 to 5.0)
- `comment`: Optional comment text

**Returns:** The review ID

**Example:**
```dart
final reviewId = await ReviewService.instance.addReview(
  restaurantId: 1,
  userId: 123,
  rating: 4.5,
  comment: 'Great food and excellent service!',
);
```

---

### 2. updateReview
Update an existing review.

**Signature:**
```dart
Future<bool> updateReview({
  required int reviewId,
  required double rating,
  String comment = '',
})
```

**Parameters:**
- `reviewId`: The ID of the review to update
- `rating`: The new rating value (0.0 to 5.0)
- `comment`: The new comment text

**Returns:** `true` if successful, `false` otherwise

**Example:**
```dart
final success = await ReviewService.instance.updateReview(
  reviewId: 456,
  rating: 5.0,
  comment: 'Updated: Even better on my second visit!',
);
```

---

### 3. deleteReview
Delete a review.

**Signature:**
```dart
Future<bool> deleteReview(int reviewId)
```

**Parameters:**
- `reviewId`: The ID of the review to delete

**Returns:** `true` if successful, `false` otherwise

**Example:**
```dart
final success = await ReviewService.instance.deleteReview(456);
```

---

### 4. getRestaurantReviews
Get all reviews for a specific restaurant with user information.

**Signature:**
```dart
Future<List<Map<String, dynamic>>> getRestaurantReviews(int restaurantId)
```

**Parameters:**
- `restaurantId`: The ID of the restaurant

**Returns:** List of reviews with user details

**Example:**
```dart
final reviews = await ReviewService.instance.getRestaurantReviews(1);
for (final review in reviews) {
  print('${review['user_name']}: ${review['rating']} stars');
  print('${review['comment']}');
}
```

---

### 5. getUserReviewForRestaurant
Get a specific review by user and restaurant.

**Signature:**
```dart
Future<Map<String, dynamic>?> getUserReviewForRestaurant({
  required int restaurantId,
  required int userId,
})
```

**Parameters:**
- `restaurantId`: The ID of the restaurant
- `userId`: The ID of the user

**Returns:** The review map or `null` if not found

**Example:**
```dart
final myReview = await ReviewService.instance.getUserReviewForRestaurant(
  restaurantId: 1,
  userId: 123,
);
if (myReview != null) {
  print('You rated this restaurant: ${myReview['rating']} stars');
}
```

---

### 6. getRestaurantRating
Get restaurant rating summary.

**Signature:**
```dart
Future<Map<String, dynamic>?> getRestaurantRating(int restaurantId)
```

**Parameters:**
- `restaurantId`: The ID of the restaurant

**Returns:** Rating summary map containing `average_rating` and `total_reviews`

**Example:**
```dart
final rating = await ReviewService.instance.getRestaurantRating(1);
if (rating != null) {
  print('Average: ${rating['average_rating']} (${rating['total_reviews']} reviews)');
}
```

---

### 7. getRestaurantsWithRatings
Get all restaurants with their rating summaries.

**Signature:**
```dart
Future<List<Map<String, dynamic>>> getRestaurantsWithRatings()
```

**Returns:** List of restaurants with rating data

**Example:**
```dart
final restaurants = await ReviewService.instance.getRestaurantsWithRatings();
for (final restaurant in restaurants) {
  print('${restaurant['name']}: ${restaurant['average_rating']} stars');
}
```

---

### 8. getTopRatedRestaurants
Get top-rated restaurants ordered by rating and review count.

**Signature:**
```dart
Future<List<Map<String, dynamic>>> getTopRatedRestaurants({int limit = 10})
```

**Parameters:**
- `limit`: Maximum number of restaurants to return (default: 10)

**Returns:** List of top-rated restaurants

**Example:**
```dart
final topRestaurants = await ReviewService.instance.getTopRatedRestaurants(limit: 5);
```

---

### 9. getUserReviews
Get all reviews submitted by a specific user.

**Signature:**
```dart
Future<List<Map<String, dynamic>>> getUserReviews(int userId)
```

**Parameters:**
- `userId`: The ID of the user

**Returns:** List of user's reviews with restaurant information

**Example:**
```dart
final myReviews = await ReviewService.instance.getUserReviews(123);
print('You have submitted ${myReviews.length} reviews');
```

---

### 10. hasUserReviewedRestaurant
Check if a user has reviewed a specific restaurant.

**Signature:**
```dart
Future<bool> hasUserReviewedRestaurant({
  required int restaurantId,
  required int userId,
})
```

**Parameters:**
- `restaurantId`: The ID of the restaurant
- `userId`: The ID of the user

**Returns:** `true` if user has reviewed, `false` otherwise

**Example:**
```dart
final hasReviewed = await ReviewService.instance.hasUserReviewedRestaurant(
  restaurantId: 1,
  userId: 123,
);
if (hasReviewed) {
  print('You have already reviewed this restaurant');
}
```

---

### 11. getRatingDistribution
Get the distribution of ratings for a restaurant.

**Signature:**
```dart
Future<Map<int, int>> getRatingDistribution(int restaurantId)
```

**Parameters:**
- `restaurantId`: The ID of the restaurant

**Returns:** Map with rating values (1-5) as keys and counts as values

**Example:**
```dart
final distribution = await ReviewService.instance.getRatingDistribution(1);
print('5 stars: ${distribution[5]} reviews');
print('4 stars: ${distribution[4]} reviews');
// ... etc
```

---

### 12. deleteRestaurantReviews
Delete all reviews for a restaurant (typically used when deleting a restaurant).

**Signature:**
```dart
Future<bool> deleteRestaurantReviews(int restaurantId)
```

**Parameters:**
- `restaurantId`: The ID of the restaurant

**Returns:** `true` if successful

**Example:**
```dart
await ReviewService.instance.deleteRestaurantReviews(1);
```

---

## Automatic Rating Updates

The service automatically maintains the `restaurant_ratings` table:

1. When a review is added, updated, or deleted
2. The average rating and total review count are recalculated
3. The `restaurant_ratings` table is updated using `INSERT OR REPLACE`

This ensures rating data is always up-to-date and queries for restaurant listings are fast.

## Error Handling

All methods include try-catch blocks and use `debugPrint` for logging. Errors are re-thrown to allow calling code to handle them appropriately.

## Database Migrations

The tables are created in `LocalDb.dart` version 5. The migration logic handles upgrades from previous versions automatically.

## Best Practices

1. Always check return values for success/failure
2. Handle null returns when querying for optional data
3. Validate user permissions before allowing review operations
4. Consider rate limiting to prevent spam reviews
5. Use transactions for operations that modify multiple tables

## Future Enhancements

Potential features to add:
- Review moderation/reporting
- Helpful review voting
- Photo attachments to reviews
- Restaurant owner responses
- Review editing history
- Spam detection
