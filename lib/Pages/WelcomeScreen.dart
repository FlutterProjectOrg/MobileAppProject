import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onGetStarted;

  const WelcomeScreen({Key? key, required this.onGetStarted}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _featuresController;
  late AnimationController _buttonController;

  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _logoSlideAnimation;
  late Animation<double> _titleFadeAnimation;

  final List<FeatureItem> _features = [
    FeatureItem(
      icon: Icons.restaurant,
      title: 'Restaurants sélectionnés',
      description: 'Découvrez les meilleurs restaurants près de chez vous',
    ),
    FeatureItem(
      icon: Icons.calendar_today,
      title: 'Réservation facile',
      description: 'Réservez votre table en quelques clics',
    ),
    FeatureItem(
      icon: Icons.favorite,
      title: 'Vos favoris',
      description: 'Sauvegardez vos restaurants préférés',
    ),
    FeatureItem(
      icon: Icons.auto_awesome,
      title: 'Recommandations IA',
      description: 'Des suggestions personnalisées pour vous',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _featuresController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoScaleAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.elasticOut,
    );

    _logoSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
        );

    _titleFadeAnimation = CurvedAnimation(
      parent: _headerController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _headerController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _featuresController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _featuresController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive breakpoints
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isExtraLarge = screenWidth >= 900;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.background,
              AppColors.primaryOrange.withOpacity(0.1),
              AppColors.primaryYellow.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  // Max width for very large screens
                  constraints: BoxConstraints(
                    maxWidth: isExtraLarge ? 1200 : double.infinity,
                  ),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16 : (isTablet ? 48 : 24),
                          vertical: isSmallScreen ? 16 : 20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Header with logo
                            _buildHeader(
                              isSmallScreen: isSmallScreen,
                              isTablet: isTablet,
                            ),

                            SizedBox(
                              height: isSmallScreen ? 24 : (isTablet ? 40 : 32),
                            ),

                            // Features grid
                            _buildFeaturesGrid(
                              isSmallScreen: isSmallScreen,
                              isTablet: isTablet,
                              isExtraLarge: isExtraLarge,
                              screenWidth: screenWidth,
                            ),

                            SizedBox(
                              height: isSmallScreen ? 24 : (isTablet ? 40 : 32),
                            ),

                            // CTA Button + Terms
                            _buildBottomSection(
                              isSmallScreen: isSmallScreen,
                              isTablet: isTablet,
                              screenWidth: screenWidth,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({required bool isSmallScreen, required bool isTablet}) {
    return Column(
      children: [
        // Logo
        SlideTransition(
          position: _logoSlideAnimation,
          child: ScaleTransition(
            scale: _logoScaleAnimation,
            child: Container(
              width: isSmallScreen ? 60 : (isTablet ? 90 : 70),
              height: isSmallScreen ? 60 : (isTablet ? 90 : 70),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isTablet ? 22 : 18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOrange.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: isSmallScreen ? 30 : (isTablet ? 44 : 36),
                color: AppColors.primaryOrange,
              ),
            ),
          ),
        ),

        SizedBox(height: isSmallScreen ? 16 : (isTablet ? 28 : 20)),

        // Title and subtitle
        FadeTransition(
          opacity: _titleFadeAnimation,
          child: Column(
            children: [
              Text(
                'Bienvenue sur',
                style: TextStyle(
                  fontSize: isSmallScreen ? 22 : (isTablet ? 36 : 28),
                  fontWeight: FontWeight.w300,
                  color: AppColors.textPrimary,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.gradientPrimary.createShader(bounds),
                child: Text(
                  'FoodFinder',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 26 : (isTablet ? 42 : 32),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : (isTablet ? 16 : 12)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 0),
                child: Text(
                  'Découvrez et réservez les meilleurs restaurants\nde votre ville en quelques clics',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : (isTablet ? 16 : 13),
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid({
    required bool isSmallScreen,
    required bool isTablet,
    required bool isExtraLarge,
    required double screenWidth,
  }) {
    // Determine grid columns based on screen size
    int crossAxisCount = 2; // Default
    if (isExtraLarge) {
      crossAxisCount = 4;
    } else if (isTablet) {
      crossAxisCount = 3;
    } else if (isSmallScreen) {
      crossAxisCount = 2;
    }

    // Adjust spacing
    final spacing = isSmallScreen ? 10.0 : (isTablet ? 16.0 : 12.0);

    // Adjust aspect ratio
    double aspectRatio = 0.95;
    if (isTablet) {
      aspectRatio = 1.0;
    } else if (isSmallScreen) {
      aspectRatio = 0.9;
    }

    return AnimatedBuilder(
      animation: _featuresController,
      builder: (context, child) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
          ),
          itemCount: _features.length,
          itemBuilder: (context, index) {
            final delay = index * 0.1;
            double animValue = _featuresController.value - delay;

            // Clamp manually between 0.0 and 1.0
            if (animValue < 0.0) animValue = 0.0;
            if (animValue > 1.0) animValue = 1.0;

            return Transform.scale(
              scale: animValue,
              child: Opacity(
                opacity: animValue,
                child: _FeatureCard(
                  feature: _features[index],
                  isSmallScreen: isSmallScreen,
                  isTablet: isTablet,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomSection({
    required bool isSmallScreen,
    required bool isTablet,
    required double screenWidth,
  }) {
    return Column(
      children: [
        _buildCTAButton(
          isSmallScreen: isSmallScreen,
          isTablet: isTablet,
          screenWidth: screenWidth,
        ),
        SizedBox(height: isSmallScreen ? 10 : 12),
        _buildTermsText(isSmallScreen: isSmallScreen, isTablet: isTablet),
        SizedBox(height: isSmallScreen ? 8 : 8),
      ],
    );
  }

  Widget _buildCTAButton({
    required bool isSmallScreen,
    required bool isTablet,
    required double screenWidth,
  }) {
    // Limit button width on large screens
    final buttonWidth = isTablet
        ? (screenWidth > 900 ? 400.0 : double.infinity)
        : double.infinity;

    return FadeTransition(
      opacity: _buttonController,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
            ),
        child: Center(
          child: SizedBox(
            width: buttonWidth,
            height: isSmallScreen ? 48 : (isTablet ? 58 : 52),
            child: ElevatedButton(
              onPressed: widget.onGetStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(isTablet ? 18 : 16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Commencer',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 15 : (isTablet ? 19 : 17),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: isTablet ? 10 : 8),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: isSmallScreen ? 18 : (isTablet ? 22 : 20),
                      ),
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

  Widget _buildTermsText({
    required bool isSmallScreen,
    required bool isTablet,
  }) {
    return FadeTransition(
      opacity: _buttonController,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 0),
        child: Text(
          'En continuant, vous acceptez nos conditions d\'utilisation',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmallScreen ? 9 : (isTablet ? 12 : 10),
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final FeatureItem feature;
  final bool isSmallScreen;
  final bool isTablet;

  const _FeatureCard({
    required this.feature,
    required this.isSmallScreen,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : (isTablet ? 16 : 12)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(isTablet ? 20 : 18),
        border: Border.all(
          color: AppColors.primaryOrange.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: isSmallScreen ? 40 : (isTablet ? 52 : 44),
            height: isSmallScreen ? 40 : (isTablet ? 52 : 44),
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary.scale(0.2),
              borderRadius: BorderRadius.circular(isTablet ? 13 : 11),
            ),
            child: Icon(
              feature.icon,
              color: AppColors.primaryOrange,
              size: isSmallScreen ? 20 : (isTablet ? 26 : 22),
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : (isTablet ? 10 : 8)),
          Text(
            feature.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : (isTablet ? 15 : 13),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: isSmallScreen ? 4 : (isTablet ? 8 : 6)),
          Text(
            feature.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 9 : (isTablet ? 13 : 10),
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
