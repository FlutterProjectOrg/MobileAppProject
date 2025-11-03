import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '461459606233-4v4098qv045ncn6sph1666v6scmn0mg2.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );
  static final String baseUrl =
      dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000';
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) return null;

      final userData = {
        'email': account.email,
        'password': 'google_auth',
        'name': account.displayName ?? '',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Utilisateur créé
        final data = jsonDecode(response.body);
        return {
          'id': data['id'],
          'email': data['email'] ?? userData['email'],
          'name': data['name'] ?? userData['name'],
        };
      } else if (response.statusCode == 400) {
        // Déjà enregistré → on tente un login direct
        final loginResponse = await http.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': account.email, 'password': 'google_auth'}),
        );

        if (loginResponse.statusCode == 200) {
          final data = jsonDecode(loginResponse.body);
          return {
            'id': data['id'],
            'email': data['email'],
            'name': data['name'],
          };
        }
      }

      print('Erreur backend: ${response.body}');
      return null;
    } catch (e) {
      print('Erreur Google Sign-In: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
