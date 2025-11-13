import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_app_project/database/LocalDb.dart';
import 'package:mobile_app_project/services/Reservation/local_reservation_service.dart';
import 'package:mobile_app_project/services/Auth/auth_service.dart';
import 'package:mobile_app_project/services/Review/review_service.dart';
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

import 'services/Like/like_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalDb.instance.init();
  await ReviewService.instance.initialize();
  await LikeService.instance.initialize();

  // Initialize services with timeout protection
  await _initializeServices();

  runApp(OverlaySupport.global(child: MyApp()));
}

// Helper function with timeout
Future<T> _initializeWithTimeout<T>(Future<T> Function() function, {int seconds = 5}) async {
  return await function().timeout(Duration(seconds: seconds), onTimeout: () {
    print('⏰ Timeout occurred for operation');
    throw TimeoutException('Operation timed out after $seconds seconds');
  });
}

Future<void> _initializeServices() async {
  try {
    print('🚀 Starting service initialization...');

    // Load environment variables
    await _initializeWithTimeout(() => dotenv.load(fileName: ".env"));
    print('✅ Environment loaded');

    // Initialize SharedPreferences
    await _initializeWithTimeout(() => SharedPreferences.getInstance());
    print('✅ SharedPreferences initialized');

    // Initialize Database
    await _initializeWithTimeout(() => LocalDb.instance.init());
    print('✅ Database initialized');

    // Initialize AuthService
    await _initializeWithTimeout(() => AuthService().initialize());
    print('✅ AuthService initialized');

    await _initializeWithTimeout(() => ReviewService.instance.initialize());
    print('✅ ReviewService initialized');

    print('🎉 Core services ready - Reservation service will load lazily');

  } catch (e) {
    print('❌ Service initialization error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        fontFamily: 'Inter',
      ),
      home: AppScreen(),
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
  String _currentScreen = 'home';
  int? _selectedRestaurant;
  bool _showChatbot = false;
  String? _userRole;
  bool _isAppReady = false;
  bool _isLoadingHeavyServices = false;
  String _loadingStatus = 'Chargement...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show UI immediately
    if (mounted) {
      setState(() {
        _isAppReady = true;
      });
    }

    // Quick authentication check
    await _quickAuthCheck();

    // Load heavy services with timeout
    await _loadHeavyServicesWithTimeout();
  }

  Future<void> _quickAuthCheck() async {
    try {
      final authService = AuthService();
      final isLoggedIn = authService.isLoggedIn;

      if (mounted) {
        setState(() {
          _isAuthenticated = isLoggedIn;
          _userRole = authService.currentUserRole;
        });
      }
    } catch (e) {
      print('❌ Quick auth check error: $e');
    }
  }

  Future<void> _loadHeavyServicesWithTimeout() async {
    if (mounted) {
      setState(() {
        _isLoadingHeavyServices = true;
        _loadingStatus = 'Finalisation du chargement...';
      });
    }

    try {
      // Set a timeout for heavy service loading
      await _loadHeavyServices().timeout(Duration(seconds: 10), onTimeout: () {
        print('⏰ Heavy services loading timeout - continuing without them');
        return;
      });
    } catch (e) {
      print('❌ Heavy services loading error: $e');
    } finally {
      // Always hide loading after timeout or completion
      if (mounted) {
        setState(() {
          _isLoadingHeavyServices = false;
        });
      }
    }
  }

  Future<void> _loadHeavyServices() async {
    try {
      print('🔄 Loading heavy services...');

      // Update loading status
      if (mounted) {
        setState(() {
          _loadingStatus = 'Initialisation des réservations...';
        });
      }

      // Try to initialize reservation service with strict timeout
      try {
        await LocalReservationService.instance.initialize().timeout(
          Duration(seconds: 3), // Shorter timeout
          onTimeout: () {
            print('⏰ Reservation service timeout - continuing without it');
            return;
          },
        );
        print('✅ Reservation service initialized');
      } catch (e) {
        print('❌ Reservation service error: $e');
        // Continue without reservation service
      }

      // Final authentication check
      await _checkAuthenticationStatus();
      await _loadUserRole();

      print('✅ Heavy services loading complete');

    } catch (e) {
      print('❌ Heavy service loading error: $e');
      // Don't rethrow - we want to continue anyway
    } finally {
      // Always hide loading after completion or error
      if (mounted) {
        setState(() {
          _isLoadingHeavyServices = false;
        });
      }
    }
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      final authService = AuthService();
      final isLoggedIn = authService.isLoggedIn;

      if (mounted) {
        setState(() {
          _isAuthenticated = isLoggedIn;
        });
      }
    } catch (e) {
      print('❌ Auth check error: $e');
    }
  }

  Future<void> _loadUserRole() async {
    try {
      final authService = AuthService();
      final role = authService.currentUserRole;

      if (mounted) {
        setState(() {
          _userRole = role;
        });
      }
    } catch (e) {
      print('❌ Error loading user role: $e');
    }
  }

  void _setAuthenticated(bool value) {
    setState(() {
      _isAuthenticated = value;
    });

    if (value) {
      _loadUserRole();
      _setCurrentScreen('home');
    } else {
      _clearUserData();
    }
  }

  Future<void> _clearUserData() async {
    try {
      final authService = AuthService();
      await authService.clearCurrentUser();
    } catch (e) {
      print('❌ Error clearing user data: $e');
    }

    setState(() {
      _userRole = null;
      _selectedRestaurant = null;
      _currentScreen = 'home';
    });
  }

  void _setCurrentScreen(String screen) {
    setState(() {
      _currentScreen = screen;
      _selectedRestaurant = null;
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

  Future<bool> _onWillPop() async {
    if (_showChatbot) {
      setState(() => _showChatbot = false);
      return false;
    }

    if (_selectedRestaurant != null) {
      _setSelectedRestaurant(null);
      return false;
    }

    return _currentScreen == 'home';
  }

  @override
  Widget build(BuildContext context) {
    // Show authentication screen if not authenticated
    if (!_isAuthenticated && !_isLoadingHeavyServices) {
      return AuthScreen(
        onAuthenticated: () => _setAuthenticated(true),
      );
    }

    // Show restaurant details if a restaurant is selected
    if (_selectedRestaurant != null) {
      return WillPopScope(
        onWillPop: _onWillPop,
        child: RestaurantDetail(
          restaurantId: _selectedRestaurant!,
          onBack: () => _setSelectedRestaurant(null),
        ),
      );
    }

    // Main app screen with navigation
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Content area
                Expanded(
                  child: _isAppReady
                      ? _buildCurrentScreen()
                      : _buildLoadingScreen(),
                ),
                // Bottom navigation
                if (_isAppReady) _buildBottomNavigation(),
              ],
            ),

            // Loading overlay for heavy services (with timeout protection)
            if (_isLoadingHeavyServices) _buildLoadingOverlay(),

            // AI Chatbot (overlay)
            if (_showChatbot)
              Positioned.fill(
                child: AIChatbot(onClose: () => setState(() => _showChatbot = false)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(height: 20),
          Text(
            'Chargement...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text(_loadingStatus),
              SizedBox(height: 10),
              Text(
                'Cette opération peut prendre quelques secondes...',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
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
          return ProfileScreen(
            onLogout: () => _setAuthenticated(false),
          );
        default:
          return HomeScreen(onRestaurantClick: _setSelectedRestaurant);
      }
    } catch (e) {
      print('❌ Error building screen $_currentScreen: $e');
      return _buildErrorScreen(e.toString());
    }
  }

  Widget _buildErrorScreen(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text('Erreur de chargement'),
          SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _setCurrentScreen('home'),
            child: Text('Retour à l\'accueil'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final primaryColor = Theme.of(context).primaryColor;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
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
                  icon: Icons.home_rounded,
                  label: 'Accueil',
                  screen: 'home',
                ),
                _userRole == 'owner'
                    ? _buildNavButton(
                  icon: Icons.dashboard_rounded,
                  label: 'Tableau',
                  screen: 'dashboard',
                )
                    : _buildNavButton(
                  icon: Icons.favorite_rounded,
                  label: 'Favoris',
                  screen: 'favorites',
                ),
                _buildChatbotButton(),
                _buildNavButton(
                  icon: Icons.calendar_today_rounded,
                  label: 'Réservations',
                  screen: 'reservations',
                ),
                _buildNavButton(
                  icon: Icons.person_rounded,
                  label: 'Profil',
                  screen: 'profile',
                ),
              ],
            ),
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
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? primaryColor : Colors.grey[600],
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? primaryColor : Colors.grey[600],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatbotButton() {
    final primaryColor = Theme.of(context).primaryColor;
    final isActive = _showChatbot;

    return GestureDetector(
      onTap: _toggleChatbot,
      behavior: HitTestBehavior.opaque,
      child: Transform.translate(
        offset: const Offset(0, -20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isActive
                      ? [primaryColor.withOpacity(0.8), primaryColor]
                      : [primaryColor, primaryColor.withBlue(255)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(isActive ? 0.4 : 0.3),
                    blurRadius: isActive ? 16 : 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: isActive
                    ? Border.all(color: Colors.white, width: 2)
                    : null,
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'IA',
              style: TextStyle(
                fontSize: 10,
                color: primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}