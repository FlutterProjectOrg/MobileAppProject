import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mobile_app_project/database/LocalDb.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  int? _currentUserId;
  String? _currentUserRole;
  String? _currentUserName;
  String? _currentUserEmail;

  // ---------- Getters ----------
  int? get currentUserId => _currentUserId;
  String? get currentUserRole => _currentUserRole;
  String? get currentUserName => _currentUserName;
  String? get currentUserEmail => _currentUserEmail;

  // ---------- Utils ----------
  String _hash(String plain) => sha256.convert(utf8.encode(plain)).toString();

  String _generateCode() {
    final rng = Random();
    return (1000 + rng.nextInt(9000)).toString();
  }

  UserRole _mapRole(String r) {
    switch (r.toLowerCase()) {
      case 'owner':
        return UserRole.owner;
      case 'delivery':
        return UserRole.delivery;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.user;
    }
  }

  // Initialize from shared preferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final userRole = prefs.getString('role');
      final userName = prefs.getString('userName');
      final userEmail = prefs.getString('userEmail');

      debugPrint('🔐 Initializing AuthService - UserID: $userId, Role: $userRole, Name: $userName');

      if (userId != null) {
        _currentUserId = userId;
        _currentUserRole = userRole;
        _currentUserName = userName;
        _currentUserEmail = userEmail;
        debugPrint('✅ AuthService initialized with user: $userId, role: $userRole, name: $userName');
      } else {
        debugPrint('⚠️ AuthService initialized - No user logged in');
      }
    } catch (e) {
      debugPrint('❌ Error initializing AuthService: $e');
    }
  }

  // Set the current user (call this after login/registration)
  Future<void> setCurrentUser(int userId, String role, String name, String email) async {
    debugPrint('🔐 Setting current user: $userId, role: $role, name: $name');

    _currentUserId = userId;
    _currentUserRole = role;
    _currentUserName = name;
    _currentUserEmail = email;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
    await prefs.setString('role', role);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);

    debugPrint('✅ Current user set successfully');
  }

  // Clear the current user (call this on logout)
  Future<void> clearCurrentUser() async {
    debugPrint('🔐 Clearing current user');

    _currentUserId = null;
    _currentUserRole = null;
    _currentUserName = null;
    _currentUserEmail = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('role');
    await prefs.remove('userName');
    await prefs.remove('userEmail');

    debugPrint('✅ Current user cleared');
  }

  // Check if user is logged in
  bool get isLoggedIn {
    final loggedIn = _currentUserId != null;
    debugPrint('🔐 Is logged in: $loggedIn (user ID: $_currentUserId)');
    return loggedIn;
  }

  // ---------- Auth ----------
  Future<int?> register(
      String email,
      String password,
      String? name,
      String role,
      ) async {
    try {
      final db = await LocalDb.instance.db;
      final userRole = _mapRole(role);

      // Check if email already exists
      final existingUser = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (existingUser.isNotEmpty) {
        debugPrint('❌ Email already exists: $email');
        return null;
      }

      final userId = await db.insert('users', {
        'email': email,
        'password': _hash(password),
        'name': name ?? '',
        'role': userRole.name,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.abort);

      debugPrint('✅ User registered with ID: $userId');

      // Créer le profil selon le rôle
      switch (userRole) {
        case UserRole.owner:
          await db.insert('owner_profiles', {
            'user_id': userId,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
          break;
        case UserRole.delivery:
          await db.insert('delivery_profiles', {
            'user_id': userId,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
          break;
        default:
          await db.insert('user_profiles', {
            'user_id': userId,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      // Set the current user
      await setCurrentUser(userId, userRole.name, name ?? '', email);

      return userId;
    } catch (e) {
      debugPrint('❌ Register error: $e');
      return null;
    }
  }

  Future<int?> login(String email, String password) async {
    try {
      final db = await LocalDb.instance.db;
      final res = await db.query(
        'users',
        columns: ['id', 'password', 'role', 'name', 'email'],
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (res.isEmpty) {
        debugPrint('❌ No user found with email: $email');
        return null;
      }

      final stored = res.first['password'] as String;
      if (stored != _hash(password)) {
        debugPrint('❌ Invalid password for email: $email');
        return null;
      }

      final userId = res.first['id'] as int;
      final userRole = res.first['role'] as String? ?? 'user';
      final userName = res.first['name'] as String? ?? 'Utilisateur';
      final userEmail = res.first['email'] as String? ?? email;

      debugPrint('✅ User logged in: $userId, role: $userRole, name: $userName');

      // Set the current user
      await setCurrentUser(userId, userRole, userName, userEmail);

      return userId;
    } catch (e) {
      debugPrint('❌ Login error: $e');
      return null;
    }
  }

  Future<User?> getUserById(int userId) async {
    try {
      final db = await LocalDb.instance.db;
      final res = await db.query(
        'users',
        columns: ['id', 'email', 'name', 'role'],
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (res.isEmpty) return null;
      return User.fromJson(res.first);
    } catch (e) {
      debugPrint('❌ getUserById error: $e');
      return null;
    }
  }

  // ---------- Profils ----------
  Future<UserProfile?> getProfile(int userId) async {
    try {
      final db = await LocalDb.instance.db;
      final rows = await db.rawQuery(
        """
        SELECT u.id, u.email, u.name, u.role,
               up.location, up.cuisine_preferences, up.budget,
               up.dietary_restrictions, up.notifications_enabled, 
               up.dark_mode_enabled, up.avatar_url
        FROM users u
        LEFT JOIN user_profiles up ON u.id = up.user_id
        WHERE u.id = ?
        """,
        [userId],
      );

      if (rows.isEmpty) return null;
      final r = rows.first;
      final prefsStr = (r['cuisine_preferences'] as String?) ?? '';
      final prefs = prefsStr.isEmpty
          ? <String>[]
          : prefsStr.split(',').where((e) => e.isNotEmpty).toList();

      return UserProfile.fromJson({
        'id': r['id'],
        'email': r['email'],
        'name': r['name'],
        'role': r['role'],
        'location': r['location'] ?? '',
        'cuisine_preferences': prefs,
        'budget': (r['budget'] as num?)?.toDouble() ?? 25.0,
        'dietary_restrictions': (r['dietary_restrictions'] ?? 0) == 1,
        'notifications_enabled': (r['notifications_enabled'] ?? 1) == 1,
        'dark_mode_enabled': (r['dark_mode_enabled'] ?? 0) == 1,
        'avatar_url': r['avatar_url'] ?? '',
      });
    } catch (e) {
      debugPrint('❌ getProfile error: $e');
      return null;
    }
  }

  Future<bool> updateProfile(UserProfile profile) async {
    try {
      final db = await LocalDb.instance.db;
      final dietary = profile.dietaryRestrictions ? 1 : 0;
      final notif = profile.notificationsEnabled ? 1 : 0;
      final dark = profile.darkModeEnabled ? 1 : 0;

      final batch = db.batch();

      // Update users table
      batch.update(
        'users',
        {
          'email': profile.email,
          'name': profile.name,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [profile.id],
      );

      // Insert or update user_profiles
      batch.insert('user_profiles', {
        'user_id': profile.id,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      batch.update(
        'user_profiles',
        {
          'location': profile.location,
          'cuisine_preferences': profile.cuisinePreferences.join(','),
          'budget': profile.budget,
          'dietary_restrictions': dietary,
          'notifications_enabled': notif,
          'dark_mode_enabled': dark,
          'avatar_url': profile.avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ?',
        whereArgs: [profile.id],
      );

      await batch.commit(noResult: true);

      // Update current user info
      if (profile.id == _currentUserId) {
        _currentUserName = profile.name;
        _currentUserEmail = profile.email;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', profile.name);
        await prefs.setString('userEmail', profile.email);
      }

      debugPrint('✅ Profile updated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ updateProfile error: $e');
      return false;
    }
  }

  Future<OwnerProfile?> getOwnerProfile(int userId) async {
    try {
      final db = await LocalDb.instance.db;
      final rows = await db.rawQuery(
        """
        SELECT u.id, u.email, u.name,
               op.restaurant_name, op.restaurant_address, 
               op.cuisine_types, op.avatar_url
        FROM users u
        LEFT JOIN owner_profiles op ON u.id = op.user_id
        WHERE u.id = ? AND u.role = 'owner'
        """,
        [userId],
      );

      if (rows.isEmpty) return null;
      final r = rows.first;
      final cuisineStr = (r['cuisine_types'] as String?) ?? '';
      final cuisines = cuisineStr.isEmpty
          ? <String>[]
          : cuisineStr.split(',').where((e) => e.isNotEmpty).toList();

      return OwnerProfile.fromJson({
        'id': r['id'],
        'email': r['email'],
        'name': r['name'],
        'restaurant_name': r['restaurant_name'] ?? '',
        'restaurant_address': r['restaurant_address'] ?? '',
        'cuisine_types': cuisines,
        'avatar_url': r['avatar_url'] ?? '',
      });
    } catch (e) {
      debugPrint('❌ getOwnerProfile error: $e');
      return null;
    }
  }

  Future<bool> updateOwnerProfile(OwnerProfile profile) async {
    try {
      final db = await LocalDb.instance.db;
      final batch = db.batch();

      batch.update(
        'users',
        {
          'email': profile.email,
          'name': profile.name,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [profile.id],
      );

      batch.insert('owner_profiles', {
        'user_id': profile.id,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      batch.update(
        'owner_profiles',
        {
          'restaurant_name': profile.restaurantName,
          'restaurant_address': profile.restaurantAddress,
          'cuisine_types': profile.cuisineTypes.join(','),
          'avatar_url': profile.avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ?',
        whereArgs: [profile.id],
      );

      await batch.commit(noResult: true);

      // Update current user info
      if (profile.id == _currentUserId) {
        _currentUserName = profile.name;
        _currentUserEmail = profile.email;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', profile.name);
        await prefs.setString('userEmail', profile.email);
      }

      debugPrint('✅ Owner profile updated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ updateOwnerProfile error: $e');
      return false;
    }
  }

  Future<DeliveryProfile?> getDeliveryProfile(int userId) async {
    try {
      final db = await LocalDb.instance.db;
      final rows = await db.rawQuery(
        """
        SELECT u.id, u.email, u.name,
               dp.phone_number, dp.vehicle_type, dp.avatar_url
        FROM users u
        LEFT JOIN delivery_profiles dp ON u.id = dp.user_id
        WHERE u.id = ? AND u.role = 'delivery'
        """,
        [userId],
      );

      if (rows.isEmpty) return null;
      return DeliveryProfile.fromJson(rows.first);
    } catch (e) {
      debugPrint('❌ getDeliveryProfile error: $e');
      return null;
    }
  }

  Future<bool> updateDeliveryProfile(DeliveryProfile profile) async {
    try {
      final db = await LocalDb.instance.db;
      final batch = db.batch();

      batch.update(
        'users',
        {
          'email': profile.email,
          'name': profile.name,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [profile.id],
      );

      batch.insert('delivery_profiles', {
        'user_id': profile.id,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      batch.update(
        'delivery_profiles',
        {
          'phone_number': profile.phoneNumber,
          'vehicle_type': profile.vehicleType,
          'avatar_url': profile.avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'user_id = ?',
        whereArgs: [profile.id],
      );

      await batch.commit(noResult: true);

      // Update current user info
      if (profile.id == _currentUserId) {
        _currentUserName = profile.name;
        _currentUserEmail = profile.email;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', profile.name);
        await prefs.setString('userEmail', profile.email);
      }

      debugPrint('✅ Delivery profile updated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ updateDeliveryProfile error: $e');
      return false;
    }
  }

  // ---------- Avatars ----------
  Future<String?> uploadAvatar(int userId, Uint8List bytes) async {
    try {
      final path = await _saveAvatarFile(userId, bytes);
      await _updateAvatarInDb(userId, path);
      return path;
    } catch (e) {
      debugPrint('❌ uploadAvatar error: $e');
      return null;
    }
  }

  Future<String?> uploadOwnerAvatar(int userId, Uint8List bytes) async {
    return await uploadAvatar(userId, bytes);
  }

  Future<String?> uploadDeliveryAvatar(int userId, Uint8List bytes) async {
    return await uploadAvatar(userId, bytes);
  }

  Future<String> _saveAvatarFile(int userId, Uint8List bytes) async {
    final dir = await getApplicationDocumentsDirectory();
    final avatarDir = Directory(p.join(dir.path, 'avatars'));
    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }
    final filePath = p.join(avatarDir.path, 'user_$userId.png');
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return filePath;
  }

  Future<void> _updateAvatarInDb(int userId, String path) async {
    final db = await LocalDb.instance.db;
    // Mettre à jour dans toutes les tables de profils
    await db.update(
      'user_profiles',
      {'avatar_url': path},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    await db.update(
      'owner_profiles',
      {'avatar_url': path},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    await db.update(
      'delivery_profiles',
      {'avatar_url': path},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // ---------- Mot de passe oublié ----------
  Future<void> sendVerificationCode(String email) async {
    try {
      final db = await LocalDb.instance.db;
      final users = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (users.isEmpty) {
        throw Exception('Aucun compte associé à cet email');
      }

      final code = await _createPasswordResetCode(email);
      await _sendEmailCode(email, code);

      debugPrint('✅ Code envoyé à $email : $code');
    } catch (e) {
      debugPrint('❌ Erreur sendVerificationCode: $e');
      throw Exception('Erreur lors de l\'envoi du code : $e');
    }
  }

  Future<void> verifyCode(String email, String code) async {
    final valid = await _verifyPasswordResetCode(email, code);
    if (!valid) {
      throw Exception('Code incorrect ou expiré');
    }
  }

  Future<void> resetPassword(String email, String newPassword) async {
    final success = await _resetPassword(email, newPassword);
    if (!success) {
      throw Exception('Impossible de réinitialiser le mot de passe');
    }
  }

  Future<String> _createPasswordResetCode(String email) async {
    final db = await LocalDb.instance.db;
    final code = _generateCode();
    final expiresAt = DateTime.now()
        .add(Duration(minutes: 15))
        .millisecondsSinceEpoch;

    await db.insert('password_reset_codes', {
      'email': email,
      'code': code,
      'created_at': expiresAt,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return code;
  }

  Future<bool> _verifyPasswordResetCode(String email, String code) async {
    final db = await LocalDb.instance.db;
    final rows = await db.query(
      'password_reset_codes',
      where: 'email = ? AND code = ?',
      whereArgs: [email, code],
      limit: 1,
    );
    if (rows.isEmpty) return false;

    final expiresAt = rows.first['created_at'] as int;
    if (DateTime.now().millisecondsSinceEpoch > expiresAt) {
      await db.delete(
        'password_reset_codes',
        where: 'email = ?',
        whereArgs: [email],
      );
      return false;
    }
    return true;
  }

  Future<bool> _resetPassword(String email, String newPassword) async {
    final db = await LocalDb.instance.db;
    final hashedPassword = _hash(newPassword);
    final count = await db.update(
      'users',
      {
        'password': hashedPassword,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'email = ?',
      whereArgs: [email],
    );

    await db.delete(
      'password_reset_codes',
      where: 'email = ?',
      whereArgs: [email],
    );
    return count == 1;
  }

  Future<void> _sendEmailCode(String recipientEmail, String code) async {
    try {
      // For local development, just log the code
      debugPrint('📧 Mock email sent to $recipientEmail with code: $code');
      debugPrint('✅ Email envoyé à $recipientEmail');
    } catch (e) {
      debugPrint('⚠️ Erreur envoi email: $e');
      // For local development, we'll just log the code instead of failing
      debugPrint('📧 Development mode - Code for $recipientEmail: $code');
    }
  }

  // Biometric methods
  int? getBiometricUserId() {
    return _currentUserId;
  }

  // Debug method to print current state
  void debugAuthState() {
    debugPrint('''
🔐 AUTH SERVICE DEBUG:
  - Current User ID: $_currentUserId
  - Current User Role: $_currentUserRole
  - Current User Name: $_currentUserName
  - Current User Email: $_currentUserEmail
  - Is Logged In: ${_currentUserId != null}
''');
  }
}

// ---------- Enums ----------
enum UserRole {
  user,
  owner,
  delivery,
  admin,
}

// ---------- Models ----------
class User {
  final int id;
  final String email;
  final String name;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] is int) ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role,
  };
}

class UserProfile {
  final int id;
  final String email;
  final String name;
  final String location;
  final List<String> cuisinePreferences;
  final double budget;
  final bool dietaryRestrictions;
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.location = '',
    this.cuisinePreferences = const [],
    this.budget = 25.0,
    this.dietaryRestrictions = false,
    this.notificationsEnabled = true,
    this.darkModeEnabled = false,
    this.avatarUrl = '',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['id'] is int) ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      cuisinePreferences: List<String>.from(json['cuisine_preferences'] ?? []),
      budget: (json['budget'] as num?)?.toDouble() ?? 25.0,
      dietaryRestrictions: json['dietary_restrictions'] as bool? ?? false,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      darkModeEnabled: json['dark_mode_enabled'] as bool? ?? false,
      avatarUrl: json['avatar_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'location': location,
    'cuisine_preferences': cuisinePreferences,
    'budget': budget,
    'dietary_restrictions': dietaryRestrictions,
    'notifications_enabled': notificationsEnabled,
    'dark_mode_enabled': darkModeEnabled,
    'avatar_url': avatarUrl,
  };
}

class OwnerProfile {
  int id;
  String email;
  String name;
  String restaurantName;
  String restaurantAddress;
  List<String> cuisineTypes;
  String? avatarUrl;

  OwnerProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.restaurantName,
    required this.restaurantAddress,
    this.cuisineTypes = const [],
    this.avatarUrl = '',
  });

  factory OwnerProfile.fromJson(Map<String, dynamic> json) {
    return OwnerProfile(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      restaurantName: json['restaurant_name'] ?? '',
      restaurantAddress: json['restaurant_address'] ?? '',
      cuisineTypes: List<String>.from(json['cuisine_types'] ?? []),
      avatarUrl: json['avatar_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'restaurant_name': restaurantName,
    'restaurant_address': restaurantAddress,
    'cuisine_types': cuisineTypes,
    'avatar_url': avatarUrl,
  };
}

class DeliveryProfile {
  int id;
  String email;
  String name;
  String phoneNumber;
  String vehicleType;
  String? avatarUrl;

  DeliveryProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.phoneNumber,
    required this.vehicleType,
    this.avatarUrl = '',
  });

  factory DeliveryProfile.fromJson(Map<String, dynamic> json) {
    return DeliveryProfile(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      vehicleType: json['vehicle_type'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'phone_number': phoneNumber,
    'vehicle_type': vehicleType,
    'avatar_url': avatarUrl,
  };
}