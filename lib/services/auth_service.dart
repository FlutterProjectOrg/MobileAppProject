import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000';

  int? currentUserId;
  Future<int?> register(String email, String password, String? name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );
      debugPrint('Register status: ${response.statusCode}');
      debugPrint('Register body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final candidate = data['user_id'] ?? data['id'] ?? data['userId'];
        int? id;
        if (candidate is int)
          id = candidate;
        else if (candidate is String)
          id = int.tryParse(candidate);
        currentUserId = id;
        debugPrint('Parsed register user id: $currentUserId');
        return currentUserId;
      } else {
        debugPrint('Register failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  Future<int?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      debugPrint('Login status: ${response.statusCode}');
      debugPrint('Login body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidate = data['user_id'] ?? data['id'] ?? data['userId'];
        int? id;
        if (candidate is int)
          id = candidate;
        else if (candidate is String)
          id = int.tryParse(candidate);
        currentUserId = id;
        debugPrint('Parsed login user id: $currentUserId');
        return currentUserId;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<UserProfile?> getProfile(int userId) async {
    try {
      debugPrint('Fetching profile for userId: $userId');
      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      debugPrint('Profile response: ${response.statusCode}');
      debugPrint('Profile body: ${response.body}');

      if (response.statusCode == 200) {
        return UserProfile.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }

  Future<bool> updateProfile(UserProfile profile) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/auth/profile/${profile.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profile.toJson()), // <- use toJson()
      );
      debugPrint('UpdateProfile status: ${response.statusCode}');
      debugPrint('UpdateProfile body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  Future<String?> uploadAvatar(int userId, String base64Image) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/profile/$userId/avatar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image_base64': base64Image}),
      );
      debugPrint('UploadProfile status: ${response.statusCode}');
      debugPrint('UploadProfile body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // defensive: ensure avatar_url exists and is string
        final avatarPathRaw = data['avatar_url'];
        if (avatarPathRaw == null) {
          debugPrint('uploadAvatar: avatar_url missing in response');
          return null;
        }
        final avatarPath = avatarPathRaw.toString();

        // build reachable URL for emulator/device
        final host = baseUrl; // baseUrl already set for emulator
        final fullUrl = avatarPath.startsWith('http')
            ? avatarPath
            : '$host$avatarPath';
        debugPrint('uploadAvatar -> $fullUrl');
        return fullUrl;
      } else {
        debugPrint(
          'uploadAvatar failed: ${response.statusCode} ${response.body}',
        );
      }
      return null;
    } catch (e, st) {
      debugPrint('Upload avatar error: $e\n$st');
      return null;
    }
  }
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
  final String avatarUrl;

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
