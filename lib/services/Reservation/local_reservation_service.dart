import 'package:flutter/material.dart';
import 'package:mobile_app_project/database/LocalDb.dart';
import 'package:mobile_app_project/services/Restaurant/RestaurantService.dart';
import 'package:sqflite/sqflite.dart';

class LocalReservationService {
  LocalReservationService._();
  static final LocalReservationService instance = LocalReservationService._();

  bool _isInitialized = false;
  bool _isCreatingSampleData = false; // Flag to prevent infinite loops

  // Initialize the service and create sample data if needed
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 Initializing LocalReservationService...');

      // Ensure database is initialized
      await LocalDb.instance.init();

      // Ensure reservations table exists
      await ensureTableExists();

      _isInitialized = true;
      debugPrint('✅ LocalReservationService initialized');

      // Create sample data in background with protection
      _createSampleDataInBackground();

    } catch (e, stackTrace) {
      debugPrint('❌ LocalReservationService initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      _isInitialized = true; // Mark as initialized anyway to prevent loops
    }
  }

  // Ensure reservations table exists
  Future<void> ensureTableExists() async {
    try {
      final db = await LocalDb.instance.db;
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reservations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          restaurant_id INTEGER NOT NULL,
          reservation_date TEXT NOT NULL,
          reservation_time TEXT NOT NULL,
          number_of_guests INTEGER NOT NULL DEFAULT 1,
          status TEXT NOT NULL DEFAULT 'pending',
          special_requests TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id),
          FOREIGN KEY (restaurant_id) REFERENCES restaurants (id)
        )
      ''');

      // Create indexes
      await db.execute('CREATE INDEX IF NOT EXISTS idx_reservations_user_id ON reservations(user_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_reservations_restaurant_id ON reservations(restaurant_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_reservations_date ON reservations(reservation_date)');

      debugPrint('✅ Reservations table ensured');
    } catch (e) {
      debugPrint('❌ Error ensuring reservations table: $e');
      rethrow;
    }
  }

  // Move sample data creation to background with protection
  void _createSampleDataInBackground() {
    Future.delayed(Duration(seconds: 2), () {
      if (!_isCreatingSampleData) {
        createSampleData().catchError((e) {
          debugPrint('❌ Background sample data creation failed: $e');
        });
      }
    });
  }

  // Create sample data for testing - FIXED VERSION
  Future<void> createSampleData() async {
    // Prevent multiple simultaneous calls
    if (_isCreatingSampleData) {
      debugPrint('⏳ Sample data creation already in progress, skipping...');
      return;
    }

    _isCreatingSampleData = true;

    try {
      await initialize(); // Ensure service is initialized first
      final db = await LocalDb.instance.db;

      debugPrint('=== CREATING SAMPLE DATA ===');

      // Check if sample data already exists to avoid duplicates
      final existingUsers = await db.query('users', limit: 1);
      final existingRestaurants = await db.query('restaurants', limit: 1);

      // If data already exists, skip creation
      if (existingUsers.isNotEmpty && existingRestaurants.isNotEmpty) {
        debugPrint('✅ Sample data already exists, skipping creation');
        return;
      }

      debugPrint('Creating sample user...');

      // Create a sample user if none exists
      if (existingUsers.isEmpty) {
        final now = DateTime.now().toIso8601String();
        final userId = await db.insert('users', {
          'email': 'test@example.com',
          'password': 'password123',
          'name': 'Test User',
          'role': 'user',
          'created_at': now,
          'updated_at': now,
        });
        debugPrint('✅ Sample user created with ID: $userId');
      } else {
        debugPrint('✅ Sample user already exists');
      }

      // Create sample restaurants if none exist
      if (existingRestaurants.isEmpty) {
        debugPrint('Creating sample restaurants...');
        final now = DateTime.now().toIso8601String();

        await db.insert('restaurants', {
          'name': 'Le Gourmet Français',
          'phone': '01 23 45 67 89',
          'adresse': '123 Rue de la Gastronomie, 75001 Paris',
          'pictures': '["https://via.placeholder.com/300x200/4CAF50/white?text=Restaurant+1"]',
          'work_time': '[{"day": "Monday", "open": "08:00", "close": "22:00"}]',
          'owner_id': 1,
          'created_at': now,
          'updated_at': now,
        });

        await db.insert('restaurants', {
          'name': 'La Bella Italia',
          'phone': '01 34 56 78 90',
          'adresse': '456 Avenue des Spécialités, 75002 Paris',
          'pictures': '["https://via.placeholder.com/300x200/2196F3/white?text=Restaurant+2"]',
          'work_time': '[{"day": "Monday", "open": "09:00", "close": "23:00"}]',
          'owner_id': 1,
          'created_at': now,
          'updated_at': now,
        });

        debugPrint('✅ Sample restaurants created');
      } else {
        debugPrint('✅ Sample restaurants already exist');
      }

      debugPrint('✅ Sample data creation completed');
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating sample data: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _isCreatingSampleData = false; // Always reset the flag
    }
  }

  // Create a new reservation
  Future<Reservation?> createReservation(Reservation reservation) async {
    try {
      // Ensure service is initialized
      await initialize();

      final db = await LocalDb.instance.db;

      debugPrint('=== CREATING RESERVATION ===');
      debugPrint('User ID: ${reservation.userId}');
      debugPrint('Restaurant ID: ${reservation.restaurantId}');
      debugPrint('Date: ${reservation.reservationDate}');
      debugPrint('Time: ${reservation.reservationTime}');
      debugPrint('Guests: ${reservation.numberOfGuests}');
      debugPrint('Status: ${reservation.status}');

      // Check if user exists
      final userCheck = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [reservation.userId],
        limit: 1,
      );

      if (userCheck.isEmpty) {
        debugPrint('❌ User with ID ${reservation.userId} does not exist');
        return null;
      }

      // Check if restaurant exists
      final restaurantCheck = await db.query(
        'restaurants',
        where: 'id = ?',
        whereArgs: [reservation.restaurantId],
        limit: 1,
      );

      if (restaurantCheck.isEmpty) {
        debugPrint('❌ Restaurant with ID ${reservation.restaurantId} does not exist');
        return null;
      }

      final now = DateTime.now();
      final reservationId = await db.insert('reservations', {
        'user_id': reservation.userId,
        'restaurant_id': reservation.restaurantId,
        'reservation_date': reservation.reservationDate.toIso8601String().split('T')[0],
        'reservation_time': reservation.reservationTime,
        'number_of_guests': reservation.numberOfGuests,
        'status': reservation.status,
        'special_requests': reservation.specialRequests,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      debugPrint('✅ Reservation created successfully with ID: $reservationId');

      // Return the created reservation with the new ID
      return reservation.copyWith(id: reservationId);
    } catch (e, stackTrace) {
      debugPrint('❌ Create reservation error: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  // Get reservation by ID
  Future<Reservation?> getReservationById(int reservationId) async {
    try {
      await initialize();
      final db = await LocalDb.instance.db;
      final res = await db.query(
        'reservations',
        where: 'id = ?',
        whereArgs: [reservationId],
        limit: 1,
      );

      if (res.isEmpty) return null;
      return await _enrichReservationWithRestaurantData(Reservation.fromJson(res.first));
    } catch (e) {
      debugPrint('Get reservation by ID error: $e');
      return null;
    }
  }

  // Get reservations by user ID
  Future<List<Reservation>> getReservationsByUserId(int userId) async {
    try {
      await initialize();
      final db = await LocalDb.instance.db;
      final res = await db.query(
        'reservations',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'reservation_date DESC, reservation_time DESC',
      );

      final reservations = res.map((json) => Reservation.fromJson(json)).toList();
      return await _enrichReservationsWithRestaurantData(reservations);
    } catch (e) {
      debugPrint('Get reservations by user ID error: $e');
      return [];
    }
  }

  // Get reservations by restaurant ID
  Future<List<Reservation>> getReservationsByRestaurantId(int restaurantId) async {
    try {
      await initialize();
      final db = await LocalDb.instance.db;
      final res = await db.query(
        'reservations',
        where: 'restaurant_id = ?',
        whereArgs: [restaurantId],
        orderBy: 'reservation_date DESC, reservation_time DESC',
      );

      final reservations = res.map((json) => Reservation.fromJson(json)).toList();
      return await _enrichReservationsWithRestaurantData(reservations);
    } catch (e) {
      debugPrint('Get reservations by restaurant ID error: $e');
      return [];
    }
  }

  // Get all reservations
  Future<List<Reservation>> getAllReservations() async {
    try {
      await initialize();
      final db = await LocalDb.instance.db;
      final res = await db.query(
        'reservations',
        orderBy: 'reservation_date DESC, reservation_time DESC',
      );

      final reservations = res.map((json) => Reservation.fromJson(json)).toList();
      return await _enrichReservationsWithRestaurantData(reservations);
    } catch (e) {
      debugPrint('Get all reservations error: $e');
      return [];
    }
  }

  // Update reservation
  Future<bool> updateReservation(Reservation reservation) async {
    try {
      await initialize();
      final db = await LocalDb.instance.db;
      final count = await db.update(
        'reservations',
        {
          'user_id': reservation.userId,
          'restaurant_id': reservation.restaurantId,
          'reservation_date': reservation.reservationDate.toIso8601String().split('T')[0],
          'reservation_time': reservation.reservationTime,
          'number_of_guests': reservation.numberOfGuests,
          'status': reservation.status,
          'special_requests': reservation.specialRequests,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [reservation.id],
      );

      return count == 1;
    } catch (e) {
      debugPrint('Update reservation error: $e');
      return false;
    }
  }

  // Delete reservation
  Future<bool> deleteReservation(int reservationId) async {
    try {
      await initialize();
      final db = await LocalDb.instance.db;
      final count = await db.delete(
        'reservations',
        where: 'id = ?',
        whereArgs: [reservationId],
      );

      return count == 1;
    } catch (e) {
      debugPrint('Delete reservation error: $e');
      return false;
    }
  }

  // Update reservation status
  Future<bool> updateReservationStatus(int reservationId, String status) async {
    try {
      await initialize();
      final db = await LocalDb.instance.db;
      final count = await db.update(
        'reservations',
        {
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [reservationId],
      );

      return count == 1;
    } catch (e) {
      debugPrint('Update reservation status error: $e');
      return false;
    }
  }

  // Helper methods to enrich reservation data with restaurant info
  Future<Reservation> _enrichReservationWithRestaurantData(Reservation reservation) async {
    try {
      final restaurant = await RestaurantService.instance.getRestaurant(reservation.restaurantId);
      if (restaurant != null) {
        return reservation.copyWith(
          restaurantName: restaurant['name'] as String? ?? 'Restaurant',
          restaurantImage: (restaurant['pictures'] as List).isNotEmpty
              ? (restaurant['pictures'] as List).first as String
              : 'https://via.placeholder.com/150',
          restaurantAddress: restaurant['adresse'] as String? ?? '',
          restaurantPhone: restaurant['phone'] as String? ?? '',
        );
      }
      return reservation;
    } catch (e) {
      debugPrint('Error enriching reservation: $e');
      return reservation;
    }
  }

  Future<List<Reservation>> _enrichReservationsWithRestaurantData(List<Reservation> reservations) async {
    final enrichedReservations = <Reservation>[];
    for (final reservation in reservations) {
      final enriched = await _enrichReservationWithRestaurantData(reservation);
      enrichedReservations.add(enriched);
    }
    return enrichedReservations;
  }

  Future<Reservation?> getLatestReservationForUser(int userId) async {
    try {
      await initialize();
      final db = await LocalDb.instance.db; // Use LocalDb.instance.db instead of database
      final maps = await db.query(
        'reservations',
        where: 'user_id = ?', // Use correct column name (user_id, not userId)
        whereArgs: [userId],
        orderBy: 'created_at DESC', // Use correct column name (created_at, not createdAt)
        limit: 1,
      );

      if (maps.isNotEmpty) {
        return Reservation.fromJson(maps.first); // Use fromJson instead of fromMap
      }
      return null;
    } catch (e) {
      debugPrint('Get latest reservation error: $e');
      return null;
    }
  }

  // Debug method to check database state
  Future<void> debugCheckDatabase() async {
    try {
      await initialize();
      final db = await LocalDb.instance.db;

      // Check if reservations table exists
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='reservations'"
      );
      debugPrint('Reservations table exists: ${tables.isNotEmpty}');

      if (tables.isNotEmpty) {
        // Check table structure
        final columns = await db.rawQuery("PRAGMA table_info(reservations)");
        debugPrint('Reservations table columns:');
        for (final column in columns) {
          debugPrint('  ${column['name']} - ${column['type']}');
        }

        // Check reservation count
        final count = await db.rawQuery("SELECT COUNT(*) as count FROM reservations");
        debugPrint('Total reservations: ${count.first['count']}');
      }

      // Check users
      final users = await db.query('users', limit: 5);
      debugPrint('Users in database: ${users.length}');

      // Check restaurants
      final restaurants = await db.query('restaurants', limit: 5);
      debugPrint('Restaurants in database: ${restaurants.length}');

    } catch (e) {
      debugPrint('Database debug error: $e');
    }
  }
}

class Reservation {
  final int id;
  final int userId;
  final int restaurantId;
  final DateTime reservationDate;
  final String reservationTime;
  final int numberOfGuests;
  final String status;
  final String? specialRequests;
  final DateTime createdAt;
  final DateTime updatedAt;

  // UI properties
  final String? restaurantName;
  final String? restaurantImage;
  final String? restaurantAddress;
  final String? restaurantPhone;

  Reservation({
    this.id = 0,
    required this.userId,
    required this.restaurantId,
    required this.reservationDate,
    required this.reservationTime,
    required this.numberOfGuests,
    this.status = 'pending',
    this.specialRequests,
    required this.createdAt,
    required this.updatedAt,
    this.restaurantName,
    this.restaurantImage,
    this.restaurantAddress,
    this.restaurantPhone,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: (json['id'] is int) ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      userId: (json['user_id'] is int) ? json['user_id'] : int.tryParse('${json['user_id']}') ?? 0,
      restaurantId: (json['restaurant_id'] is int) ? json['restaurant_id'] : int.tryParse('${json['restaurant_id']}') ?? 0,
      reservationDate: DateTime.parse('${json['reservation_date']}'),
      reservationTime: json['reservation_time'] as String,
      numberOfGuests: (json['number_of_guests'] is int) ? json['number_of_guests'] : int.tryParse('${json['number_of_guests']}') ?? 1,
      status: json['status'] as String? ?? 'pending',
      specialRequests: json['special_requests'] as String?,
      createdAt: DateTime.parse('${json['created_at']}'),
      updatedAt: DateTime.parse('${json['updated_at']}'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'restaurant_id': restaurantId,
    'reservation_date': reservationDate.toIso8601String().split('T')[0],
    'reservation_time': reservationTime,
    'number_of_guests': numberOfGuests,
    'status': status,
    'special_requests': specialRequests,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  Reservation copyWith({
    int? id,
    int? userId,
    int? restaurantId,
    DateTime? reservationDate,
    String? reservationTime,
    int? numberOfGuests,
    String? status,
    String? specialRequests,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? restaurantName,
    String? restaurantImage,
    String? restaurantAddress,
    String? restaurantPhone,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      reservationDate: reservationDate ?? this.reservationDate,
      reservationTime: reservationTime ?? this.reservationTime,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      status: status ?? this.status,
      specialRequests: specialRequests ?? this.specialRequests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      restaurantName: restaurantName ?? this.restaurantName,
      restaurantImage: restaurantImage ?? this.restaurantImage,
      restaurantAddress: restaurantAddress ?? this.restaurantAddress,
      restaurantPhone: restaurantPhone ?? this.restaurantPhone,
    );
  }

  // UI getters for compatibility with existing screen
  String get date => "${reservationDate.day}/${reservationDate.month}/${reservationDate.year}";
  String get time => reservationTime;
  int get guests => numberOfGuests;

  @override
  String toString() {
    return 'Reservation(id: $id, userId: $userId, restaurantId: $restaurantId, date: $date, time: $time, guests: $guests, status: $status)';
  }
}