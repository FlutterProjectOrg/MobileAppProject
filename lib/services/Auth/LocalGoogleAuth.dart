import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobile_app_project/services/Auth/LocalAuthService.dart';

class LocalGoogleAuth {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '461459606233-4v4098qv045ncn6sph1666v6scmn0mg2.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  final LocalAuthService _localAuth = LocalAuthService.instance;

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // 1. Déconnecter la session précédente
      await _googleSignIn.signOut();

      // 2. Déclencher le flux de connexion Google
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        // L'utilisateur a annulé
        return null;
      }

      // 3. Mot de passe pseudo pour Google Auth (non utilisé réellement)
      const String pseudoPassword = 'google_auth';

      // 4. Tenter de se connecter avec l'email (si déjà enregistré)
      int? userId = await _localAuth.login(account.email, pseudoPassword);

      // 5. Si pas encore enregistré, créer un nouveau compte
      if (userId == null) {
        userId = await _localAuth.register(
          account.email,
          pseudoPassword,
          account.displayName,
          'user', // Rôle par défaut
        );

        if (userId == null) {
          // Échec de l'inscription
          return null;
        }
      }

      // 6. Récupérer les infos utilisateur complètes
      final user = await _localAuth.getUserById(userId);
      if (user == null) return null;

      // 7. Retourner les données formatées
      return {
        'id': user.id,
        'email': user.email,
        'name': user.name,
        'role': user.role,
      };
    } catch (e) {
      print('❌ Erreur Google Sign-In: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      print('✅ Déconnexion Google réussie');
    } catch (e) {
      print('⚠️ Erreur lors de la déconnexion Google: $e');
    }
  }

  /// Récupérer le compte Google actuellement connecté (si existe)
  Future<GoogleSignInAccount?> getCurrentUser() async {
    return await _googleSignIn.signInSilently();
  }

  /// Vérifier si un utilisateur Google est connecté
  bool get isSignedIn => _googleSignIn.currentUser != null;
}
