import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Vérifie si la biométrie est disponible sur le téléphone
  Future<bool> isBiometricAvailable() async {
    return await auth.canCheckBiometrics;
  }

  /// Active ou désactive la biométrie
  Future<void> setBiometricEnabled(bool enabled, int userId) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
    await _storage.write(key: 'biometric_user_id', value: userId.toString());
  }

  /// Vérifie si l’utilisateur a activé la biométrie
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: 'biometric_enabled');
    return value == 'true';
  }

  /// Demande la reconnaissance faciale ou empreinte
  Future<bool> authenticateUser() async {
    try {
      return await auth.authenticate(
        localizedReason: 'Veuillez vous authentifier pour continuer',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print("Erreur biométrique: $e");
      return false;
    }
  }
}
