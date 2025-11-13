import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/AIChatbot.dart';
import 'package:mobile_app_project/Pages/Auth/AuthScreen.dart';
import 'package:mobile_app_project/Pages/Auth/ProfileScreen.dart';
import 'package:mobile_app_project/Pages/FavoritesScreen.dart';
import 'package:mobile_app_project/Pages/HomeScreen.dart';
import 'package:mobile_app_project/Pages/OwnerDashboard.dart';
import 'package:mobile_app_project/Pages/ReservationsScreen.dart';
import 'package:mobile_app_project/Pages/RestaurantDetail.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({Key? key}) : super(key: key);

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  bool _isAuthenticated = false;
  String _currentScreen = 'home';
  int? _selectedRestaurant;
  bool _showChatbot = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final role = prefs.getString('role');

      if (mounted) {
        setState(() {
          _isAuthenticated = userId != null;
          _userRole = role;
        });
      }
    } catch (e) {
      debugPrint('❌ Erreur checkAuthStatus: $e');
    }
  }

  Future<void> _loadUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('role');
      if (mounted) {
        setState(() {
          _userRole = role;
        });
      }
    } catch (e) {
      debugPrint('❌ Erreur loadUserRole: $e');
    }
  }

  void _setAuthenticated(bool value) {
    setState(() {
      _isAuthenticated = value;
    });
    if (value) {
      _loadUserRole();
    }
  }

  void _setCurrentScreen(String screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  void _setSelectedRestaurant(int? id) {
    setState(() {
      _selectedRestaurant = id;
    });
  }

  void _toggleChatbot() {
    // Immediate UI response - no delay
    setState(() {
      _showChatbot = !_showChatbot;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return AuthScreen(onAuthenticated: () => _setAuthenticated(true));
    }

    if (_selectedRestaurant != null) {
      return RestaurantDetail(
        restaurantId: _selectedRestaurant!,
        onBack: () => _setSelectedRestaurant(null),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildCurrentScreen()),
              _buildBottomNavigation(),
            ],
          ),
          if (_showChatbot)
            AIChatbot(onClose: () => setState(() => _showChatbot = false)),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    try {
      switch (_currentScreen) {
        case 'home':
          return HomeScreen(onRestaurantClick: _setSelectedRestaurant);
        case 'favorites':
          return FavoritesScreen(onRestaurantClick: _setSelectedRestaurant);
        case 'dashboard':
          return const OwnerDashboard();
        case 'reservations':
          return const ReservationsScreen();
        case 'profile':
          return ProfileScreen(onLogout: () => _setAuthenticated(false));
        default:
          return HomeScreen(onRestaurantClick: _setSelectedRestaurant);
      }
    } catch (e) {
      debugPrint('❌ Erreur buildCurrentScreen: $e');
      return Center(
        child: Text(
          'Erreur: $e',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      );
    }
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryOrange.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavButton(
                icon: Icons.home,
                label: 'Accueil',
                screen: 'home',
              ),
              _userRole == 'owner'
                  ? _buildNavButton(
                      icon: Icons.dashboard,
                      label: 'Tableau',
                      screen: 'dashboard',
                    )
                  : _buildNavButton(
                      icon: Icons.favorite,
                      label: 'Favoris',
                      screen: 'favorites',
                    ),
              _buildChatbotButton(),
              _buildNavButton(
                icon: Icons.calendar_today,
                label: 'Réservations',
                screen: 'reservations',
              ),
              _buildNavButton(
                icon: Icons.person,
                label: 'Profil',
                screen: 'profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required String screen,
  }) {
    final isActive = _currentScreen == screen;

    return GestureDetector(
      onTap: () => _setCurrentScreen(screen),
      child: AnimatedScale(
        scale: isActive ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: isActive
                    ? AppColors.gradientPrimary.scale(0.2)
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isActive
                    ? AppColors.primaryOrange
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive
                    ? AppColors.primaryOrange
                    : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatbotButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleChatbot,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primaryOrange.withOpacity(0.3),
        child: Transform.translate(
          offset: const Offset(0, -32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.message, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 8),
              const Text(
                'IA',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
