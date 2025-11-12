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
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Header with logo
                        _buildHeader(),

                        // Features grid
                        _buildFeaturesGrid(),

                        // CTA Button + Terms
                        Column(
                          children: [
                            _buildCTAButton(),
                            const SizedBox(height: 12),
                            _buildTermsText(),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ],
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

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        SlideTransition(
          position: _logoSlideAnimation,
          child: ScaleTransition(
            scale: _logoScaleAnimation,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOrange.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 36,
                color: AppColors.primaryOrange,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Title and subtitle
        FadeTransition(
          opacity: _titleFadeAnimation,
          child: Column(
            children: [
              const Text(
                'Bienvenue sur',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textPrimary,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.gradientPrimary.createShader(bounds),
                child: const Text(
                  'FoodFinder',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Découvrez et réservez les meilleurs restaurants\nde votre ville en quelques clics',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid() {
    return AnimatedBuilder(
      animation: _featuresController,
      builder: (context, child) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
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
                child: _FeatureCard(feature: _features[index]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCTAButton() {
    return FadeTransition(
      opacity: _buttonController,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
            ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: widget.onGetStarted,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(16),
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Commencer',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return FadeTransition(
      opacity: _buttonController,
      child: Text(
        'En continuant, vous acceptez nos conditions d\'utilisation',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          color: AppColors.textSecondary.withOpacity(0.7),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final FeatureItem feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary.scale(0.2),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(feature.icon, color: AppColors.primaryOrange, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            feature.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            feature.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
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
