// Pages/Auth/AuthScreen.dart
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mobile_app_project/Pages/Auth/ForgotPasswordDialog.dart';
import 'package:mobile_app_project/services/Auth/auth_service.dart';
import 'package:mobile_app_project/services/Auth/LocalGoogleAuth.dart';
import 'package:mobile_app_project/services/Auth/biometric_service.dart';
import 'package:mobile_app_project/services/Auth/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AuthScreen({Key? key, required this.onAuthenticated}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _isSignup = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final StorageService storage = StorageService();
  final BiometricService biometric = BiometricService();
  String selectedRole = 'user';
  final Map<String, Map<String, dynamic>> roleOptions = {
    'user': {
      'label': 'Client',
      'icon': Icons.person,
      'description': 'Commander et découvrir',
    },
    'owner': {
      'label': 'Propriétaire',
      'icon': Icons.store,
      'description': 'Gérer votre restaurant',
    },
    'delivery': {
      'label': 'Livreur',
      'icon': Icons.delivery_dining,
      'description': 'Livrer les commandes',
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        int? userId;

        if (_isSignup) {
          userId = await _authService.register(
            _emailController.text,
            _passwordController.text,
            _nameController.text,
            selectedRole,
          );
          debugPrint('Registered user ID: $userId');
          debugPrint('Selected role: $selectedRole');
        } else {
          userId = await _authService.login(
            _emailController.text,
            _passwordController.text,
          );
          debugPrint('Logged in user ID: $userId');
        }

        setState(() => _isLoading = false);

        if (userId != null) {
          // User is automatically set in AuthService, just proceed
          await storage.saveUserId(userId);

          // 🧩 Étape biométrie : proposer l'activation si non déjà activée
          final biometricEnabled = await storage.read('biometric_enabled');
          final biometricUserId = await storage.read('biometric_user_id');

          if (biometricEnabled != 'true' || biometricUserId != userId.toString()) {
            final shouldEnable = await _showEnableBiometricDialog(context);
            if (shouldEnable == true) {
              await storage.write('biometric_enabled', 'true');
              await storage.write('biometric_user_id', userId.toString());
              _showSuccessSnackBar("Connexion biométrique activée");
            }
          }

          widget.onAuthenticated();
        } else {
          _showErrorSnackBar("Échec de l'authentification");
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackBar("Erreur: $e");
      }
    }
  }
  Future<bool?> _showEnableBiometricDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Activer la connexion par empreinte ?"),
        content: const Text(
          "Souhaitez-vous activer la reconnaissance biométrique pour ce compte ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Non"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Oui"),
          ),
        ],
      ),
    );
  }
  Future<void> _loginWithBiometrics() async {
    final auth = LocalAuthentication();
    final canCheck = await auth.canCheckBiometrics;

    if (!canCheck) {
      _showErrorSnackBar("Biométrie non disponible sur cet appareil");
      return;
    }

    final didAuthenticate = await auth.authenticate(
      localizedReason: 'Authentifiez-vous pour vous connecter',
      options: const AuthenticationOptions(biometricOnly: true),
    );

    if (didAuthenticate) {
      final biometricEnabled = await storage.read('biometric_enabled');
      final biometricUserId = await storage.read('biometric_user_id');

      if (biometricEnabled == 'true' && biometricUserId != null) {
        await storage.saveUserId(int.parse(biometricUserId));
        widget.onAuthenticated();
      } else {
        _showErrorSnackBar("Aucun compte biométrique trouvé");
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Erreur',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 4),
        elevation: 8,
      ),
    );
  }


  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Succès',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 13, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 4),
        elevation: 8,
      ),
    );
  }

  void _toggleSignup() {
    setState(() {
      _isSignup = !_isSignup;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF7ED), // orange-50
              Color(0xFFFEF3C7), // amber-50
              Color(0xFFFEE2E2), // red-50
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 448),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildForm(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.restaurant, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 16),
        const Text(
          'Food Finder',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isSignup ? 'Créez votre compte' : 'Connectez-vous à votre compte',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isSignup) ...[
            _buildLabel('Nom complet'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _nameController,
              hint: 'Jean Dupont',
              icon: Icons.person,
              validator: (value) {
                if (_isSignup && (value == null || value.isEmpty)) {
                  return 'Veuillez entrer votre nom';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
          ],
          _buildLabel('Email'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailController,
            hint: 'vous@exemple.com',
            icon: Icons.mail,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre email';
              }
              if (!value.contains('@')) {
                return 'Veuillez entrer un email valide';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildLabel('Mot de passe'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _passwordController,
            hint: '••••••••',
            icon: Icons.lock,
            obscureText: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer votre mot de passe';
              }
              if (value.length < 6) {
                return 'Le mot de passe doit contenir au moins 6 caractères';
              }
              return null;
            },
          ),
          if (_isSignup) ...[
            const SizedBox(height: 16),
            _buildLabel('Type de compte'),
            const SizedBox(height: 8),
            _buildRoleDropdown(),
          ],
          const SizedBox(height: 24),
          _buildSubmitButton(),
          const SizedBox(height: 24),
          _isSignup ? const SizedBox.shrink() : _buildBiometricButton(),
          const SizedBox(height: 24),
          _isSignup
              ? const SizedBox.shrink()
              : TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const ForgotPasswordDialog(),
              );
            },
            child: const Text(
              'Mot de passe oublié?',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          _buildDivider(),
          const SizedBox(height: 24),

          _buildGoogleButton(),
          const SizedBox(height: 16),

          const SizedBox(height: 16),
          _buildToggleSignup(),
        ],
      ),
    );
  }


  Widget _buildBiometricButton() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFF3B82F6)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3B82F6).withOpacity(0.4),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: CircleBorder(),
        child: InkWell(
          onTap: _loginWithBiometrics,
          customBorder: CircleBorder(),
          child: Center(
            child: Icon(Icons.fingerprint, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: selectedRole,
        decoration: InputDecoration(
          prefixIcon: Icon(
            roleOptions[selectedRole]!['icon'] as IconData,
            color: Colors.grey[700],
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 8,
        isExpanded: true,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF1F2937),
          fontWeight: FontWeight.w500,
        ),
        selectedItemBuilder: (BuildContext context) {
          return roleOptions.entries.map((entry) {
            return Row(
              children: [
                const SizedBox(width: 8),
                Text(
                  entry.value['label'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            );
          }).toList();
        },
        items: roleOptions.entries.map((entry) {
          return DropdownMenuItem<String>(
            value: entry.key,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(
                    entry.value['icon'] as IconData,
                    size: 22,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.value['label'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.value['description'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            selectedRole = val ?? 'user';
          });
        },
        validator: (value) {
          if (_isSignup && (value == null || value.isEmpty)) {
            return 'Veuillez sélectionner un type de compte';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }


  Widget _buildSubmitButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(
          _isSignup ? 'Créer un compte' : 'Se connecter',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Ou',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: _handleGoogleSignIn,
        icon: Image.network(
          'https://www.google.com/favicon.ico',
          width: 20,
          height: 20,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.login, size: 20);
          },
        ),
        label: const Text(
          'Continuer avec Google',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1F2937),
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    final googleAuth = LocalGoogleAuth();
    final user = await googleAuth.signInWithGoogle();

    setState(() => _isLoading = false);

    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user['id']);
      await prefs.setString('role', user['role']);
      await storage.saveUserId(user['id']!);

      // ✅ Vérifie si biométrie activée
      final biometricEnabled = await storage.isBiometricEnabled();
      final biometricUserId = await storage.getBiometricUserId();

      // ✅ Si pas encore activée pour cet utilisateur, proposer
      if (!biometricEnabled || biometricUserId != user['id']) {
        final shouldEnable = await _showEnableBiometricDialog(context);
        if (shouldEnable == true) {
          await storage.saveBiometricEnabled(true);
          await storage.saveBiometricUserId(user['id']);
          _showSuccessSnackBar("Connexion biométrique activée");
        }
      }
      widget.onAuthenticated();
    } else {
      _showErrorSnackBar("Connexion Google annulée ou échouée");
    }
  }

  Widget _buildToggleSignup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isSignup
              ? 'Vous avez déjà un compte?'
              : "Vous n'avez pas de compte?",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: _toggleSignup,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _isSignup ? 'Se connecter' : "S'inscrire",
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3B82F6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}