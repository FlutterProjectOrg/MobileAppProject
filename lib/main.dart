import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:mobile_app_project/Pages/AICHATBOT.dart';
import 'package:mobile_app_project/Pages/Auth/AuthScreen.dart';
import 'package:mobile_app_project/Pages/FavoritesScreen.dart';
import 'package:mobile_app_project/Pages/HomeScreen.dart';
import 'package:mobile_app_project/Pages/Auth/ProfileScreen.dart';
import 'package:mobile_app_project/Pages/ReservationsScreen.dart';
import 'package:mobile_app_project/Pages/RestaurantDetail.dart';
import 'package:mobile_app_project/Pages/OwnerDashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await SharedPreferences.getInstance();
  await dotenv.load(fileName: ".env");
  runApp(OverlaySupport.global(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const AppScreen(),
    );
  }
}

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  bool _isAuthenticated = false;
  String _currentScreen =
      'home'; // 'home', 'favorites', 'dashboard', 'reservations', 'profile'
  int? _selectedRestaurant;
  bool _showChatbot = false;
  String? _userRole; // 'user', 'owner', 'delivery'

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role');
    if (mounted) {
      setState(() {
        _userRole = role;
      });
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
    setState(() {
      _showChatbot = !_showChatbot;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si non authentifié, afficher l'écran d'authentification
    if (!_isAuthenticated) {
      return AuthScreen(onAuthenticated: () => _setAuthenticated(true));
    }

    // Si un restaurant est sélectionné, afficher ses détails
    if (_selectedRestaurant != null) {
      return RestaurantDetail(
        restaurantId: _selectedRestaurant!,
        onBack: () => _setSelectedRestaurant(null),
      );
    }

    // Écran principal avec navigation
    return Scaffold(
      body: Stack(
        children: [
          // Contenu principal
          Column(
            children: [
              // Zone de contenu
              Expanded(child: _buildCurrentScreen()),
              // Navigation inférieure
              _buildBottomNavigation(),
            ],
          ),
          // Chatbot IA (drawer)
          if (_showChatbot)
            AIChatbot(onClose: () => setState(() => _showChatbot = false)),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
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
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
              // Show Dashboard for owners, Favorites for others
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
    final primaryColor = Theme.of(context).primaryColor;

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
                color: isActive
                    ? primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isActive ? primaryColor : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? primaryColor : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatbotButton() {
    return GestureDetector(
      onTap: _toggleChatbot,
      child: Transform.translate(
        offset: const Offset(0, -32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withBlue(255),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.message, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              'IA',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
