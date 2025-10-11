// Mock data for the food finder app

class Restaurant {
  final int id;
  final String name;
  final String cuisine;
  final double rating;
  final int reviews;
  final String distance;
  final String priceRange;
  final String image;
  final bool isOpen;
  final String? openUntil;

  Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.rating,
    required this.reviews,
    required this.distance,
    required this.priceRange,
    required this.image,
    required this.isOpen,
    this.openUntil,
  });
}

class Review {
  final int id;
  final String userName;
  final int rating;
  final String date;
  final String comment;
  final int helpful;

  Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.date,
    required this.comment,
    required this.helpful,
  });
}

class MenuItem {
  final int id;
  final String name;
  final String description;
  final double price;
  final bool isPopular;
  final String? image;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isPopular,
    this.image,
  });
}

class Reservation {
  final int id;
  final String restaurantName;
  final String restaurantImage;
  final String cuisine;
  final String date;
  final String time;
  final int guests;
  final String status; // 'confirmed', 'completed', 'cancelled'

  Reservation({
    required this.id,
    required this.restaurantName,
    required this.restaurantImage,
    required this.cuisine,
    required this.date,
    required this.time,
    required this.guests,
    required this.status,
  });
}

// Mock Restaurants Data
final List<Restaurant> mockRestaurants = [
  Restaurant(
    id: 1,
    name: 'La Bella Italia',
    cuisine: 'Italien',
    rating: 4.7,
    reviews: 324,
    distance: '1.2 km',
    priceRange: '€€',
    image:
        'https://images.unsplash.com/photo-1715607873797-a173a95fd47c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxpdGFsaWFuJTIwcmVzdGF1cmFudCUyMGZvb2R8ZW58MXx8fHwxNzU5NDg1MDY1fDA&ixlib=rb-4.1.0&q=80&w=1080',
    isOpen: true,
    openUntil: '23:00',
  ),
  Restaurant(
    id: 2,
    name: 'Sakura Sushi',
    cuisine: 'Japonais',
    rating: 4.9,
    reviews: 512,
    distance: '0.8 km',
    priceRange: '€€€',
    image:
        'https://images.unsplash.com/photo-1639650538773-ffe1d8ad9d3f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxqYXBhbmVzZSUyMHN1c2hpJTIwcmVzdGF1cmFudHxlbnwxfHx8fDE3NTk1ODc4OTJ8MA&ixlib=rb-4.1.0&q=80&w=1080',
    isOpen: true,
    openUntil: '22:30',
  ),
  Restaurant(
    id: 3,
    name: 'Le Petit Bistrot',
    cuisine: 'Français',
    rating: 4.5,
    reviews: 289,
    distance: '2.1 km',
    priceRange: '€€',
    image:
        'https://images.unsplash.com/photo-1599211469310-9b0b50a2955a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmcmVuY2glMjBiaXN0cm8lMjBmb29kfGVufDF8fHx8MTc1OTU4Nzg5Mnww&ixlib=rb-4.1.0&q=80&w=1080',
    isOpen: false,
  ),
  Restaurant(
    id: 4,
    name: 'Taco Loco',
    cuisine: 'Mexicain',
    rating: 4.3,
    reviews: 178,
    distance: '3.5 km',
    priceRange: '€',
    image:
        'https://images.unsplash.com/photo-1700625915228-f2b3d88c6676?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtZXhpY2FuJTIwdGFjb3MlMjByZXN0YXVyYW50fGVufDF8fHx8MTc1OTUwNjA5MHww&ixlib=rb-4.1.0&q=80&w=1080',
    isOpen: true,
    openUntil: '23:30',
  ),
  Restaurant(
    id: 5,
    name: 'Taj Mahal',
    cuisine: 'Indien',
    rating: 4.6,
    reviews: 402,
    distance: '1.9 km',
    priceRange: '€€',
    image:
        'https://images.unsplash.com/photo-1567337710282-00832b415979?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxpbmRpYW4lMjBjdXJyeSUyMGZvb2R8ZW58MXx8fHwxNzU5NTUzMzg4fDA&ixlib=rb-4.1.0&q=80&w=1080',
    isOpen: true,
    openUntil: '22:00',
  ),
];

// Mock Reviews Data
final List<Review> mockReviews = [
  Review(
    id: 1,
    userName: 'Marie Dubois',
    rating: 5,
    date: 'Il y a 2 jours',
    comment:
        'Excellent restaurant! La cuisine est authentique et le service impeccable. Je recommande vivement!',
    helpful: 12,
  ),
  Review(
    id: 2,
    userName: 'Pierre Martin',
    rating: 4,
    date: 'Il y a 1 semaine',
    comment:
        'Très bon rapport qualité-prix. L\'ambiance est agréable, parfait pour un dîner en famille.',
    helpful: 8,
  ),
  Review(
    id: 3,
    userName: 'Sophie Laurent',
    rating: 5,
    date: 'Il y a 2 semaines',
    comment:
        'Les plats sont délicieux et généreusement servis. Le personnel est très accueillant.',
    helpful: 15,
  ),
];

// Mock Menu Items Data
final List<MenuItem> mockMenuItems = [
  MenuItem(
    id: 1,
    name: 'Pizza Margherita',
    description: 'Tomate, mozzarella, basilic frais',
    price: 12,
    isPopular: true,
    image:
        'https://images.unsplash.com/photo-1715607873797-a173a95fd47c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxpdGFsaWFuJTIwcmVzdGF1cmFudCUyMGZvb2R8ZW58MXx8fHwxNzU5NDg1MDY1fDA&ixlib=rb-4.1.0&q=80&w=1080',
  ),
  MenuItem(
    id: 2,
    name: 'Pâtes Carbonara',
    description: 'Guanciale, œuf, pecorino, poivre noir',
    price: 14,
    isPopular: true,
  ),
  MenuItem(
    id: 3,
    name: 'Risotto aux Champignons',
    description: 'Champignons de saison, parmesan, vin blanc',
    price: 16,
    isPopular: false,
  ),
  MenuItem(
    id: 4,
    name: 'Tiramisu Maison',
    description: 'Mascarpone, café, cacao',
    price: 7,
    isPopular: true,
  ),
];

// Mock Reservations Data
final List<Reservation> mockReservations = [
  Reservation(
    id: 1,
    restaurantName: 'La Bella Italia',
    restaurantImage:
        'https://images.unsplash.com/photo-1715607873797-a173a95fd47c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxpdGFsaWFuJTIwcmVzdGF1cmFudCUyMGZvb2R8ZW58MXx8fHwxNzU5NDg1MDY1fDA&ixlib=rb-4.1.0&q=80&w=1080',
    cuisine: 'Italien',
    date: '15 Oct 2025',
    time: '19:30',
    guests: 4,
    status: 'confirmed',
  ),
  Reservation(
    id: 2,
    restaurantName: 'Sakura Sushi',
    restaurantImage:
        'https://images.unsplash.com/photo-1639650538773-ffe1d8ad9d3f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxqYXBhbmVzZSUyMHN1c2hpJTIwcmVzdGF1cmFudHxlbnwxfHx8fDE3NTk1ODc4OTJ8MA&ixlib=rb-4.1.0&q=80&w=1080',
    cuisine: 'Japonais',
    date: '18 Oct 2025',
    time: '20:00',
    guests: 2,
    status: 'confirmed',
  ),
  Reservation(
    id: 3,
    restaurantName: 'Le Petit Bistrot',
    restaurantImage:
        'https://images.unsplash.com/photo-1599211469310-9b0b50a2955a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmcmVuY2glMjBiaXN0cm8lMjBmb29kfGVufDF8fHx8MTc1OTU4Nzg5Mnww&ixlib=rb-4.1.0&q=80&w=1080',
    cuisine: 'Français',
    date: '1 Oct 2025',
    time: '13:00',
    guests: 2,
    status: 'completed',
  ),
];

// Helper function to get a restaurant by ID
Restaurant? getRestaurantById(int id) {
  try {
    return mockRestaurants.firstWhere((restaurant) => restaurant.id == id);
  } catch (e) {
    return null;
  }
}

// Helper function to filter restaurants by cuisine
List<Restaurant> getRestaurantsByCuisine(String cuisine) {
  return mockRestaurants
      .where((restaurant) => restaurant.cuisine == cuisine)
      .toList();
}

// Helper function to get open restaurants
List<Restaurant> getOpenRestaurants() {
  return mockRestaurants.where((restaurant) => restaurant.isOpen).toList();
}

// Helper function to filter restaurants by price range
List<Restaurant> getRestaurantsByPriceRange(String priceRange) {
  return mockRestaurants
      .where((restaurant) => restaurant.priceRange == priceRange)
      .toList();
}

// Helper function to sort restaurants by rating
List<Restaurant> getTopRatedRestaurants() {
  final sorted = List<Restaurant>.from(mockRestaurants);
  sorted.sort((a, b) => b.rating.compareTo(a.rating));
  return sorted;
}

// Helper function to get upcoming reservations
List<Reservation> getUpcomingReservations() {
  return mockReservations
      .where((reservation) => reservation.status == 'confirmed')
      .toList();
}

// Helper function to get past reservations
List<Reservation> getPastReservations() {
  return mockReservations
      .where((reservation) => reservation.status == 'completed')
      .toList();
}
