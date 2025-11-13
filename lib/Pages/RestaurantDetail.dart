import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app_project/Pages/UI/RestaurantReviewsSection.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';
import 'package:mobile_app_project/services/Restaurant/RestaurantService.dart';
import 'package:mobile_app_project/services/Restaurant/DishService.dart';
import 'package:mobile_app_project/services/Review/ReviewService.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class RestaurantDetail extends StatefulWidget {
  final int restaurantId;
  final VoidCallback onBack;

  const RestaurantDetail({
    Key? key,
    required this.restaurantId,
    required this.onBack,
  }) : super(key: key);

  @override
  State<RestaurantDetail> createState() => _RestaurantDetailState();
}

class _RestaurantDetailState extends State<RestaurantDetail>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  bool _isLoading = true;
  late TabController _tabController;

  Map<String, dynamic>? _restaurantData;
  List<Map<String, dynamic>> _dishes = [];
  double _averageRating = 0.0;
  int _totalReviews = 0;
  String _restaurantName = '';
  String _restaurantAddress = '';
  String _restaurantPhone = '';
  String _priceRange = '€€';
  List<String> _pictures = [];
  List<Map<String, dynamic>> _workTime = [];
  bool _isOpenNow = false;
  String _openingStatus = 'Fermé';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRestaurantData();
  }

  Future<void> _loadRestaurantData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch restaurant data
      final restaurantData = await RestaurantService.instance.getRestaurant(
        widget.restaurantId,
      );

      if (restaurantData == null) {
        throw Exception('Restaurant not found');
      }

      // Fetch dishes for the restaurant
      final dishes = await DishService.instance.getDishesByRestaurant(
        widget.restaurantId,
      );

      // Fetch rating data
      final ratingData = await ReviewService.instance.getRestaurantRating(
        widget.restaurantId,
      );

      if (mounted) {
        setState(() {
          _restaurantData = restaurantData;
          _restaurantName = restaurantData['name'] as String;
          _restaurantAddress = restaurantData['adresse'] as String;
          _restaurantPhone = restaurantData['phone'] as String? ?? '';
          _priceRange = restaurantData['price_range'] as String? ?? '€€';
          _pictures = (restaurantData['pictures'] as List<dynamic>)
              .cast<String>();
          _workTime = (restaurantData['work_time'] as List<dynamic>)
              .cast<Map<String, dynamic>>();
          _dishes = dishes;
          _averageRating = ratingData != null
              ? (ratingData['average_rating'] as num?)?.toDouble() ?? 0.0
              : 0.0;
          _totalReviews = ratingData != null
              ? (ratingData['total_reviews'] as int?) ?? 0
              : 0;
          _calculateOpeningStatus();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading restaurant data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddressModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryOrange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Adresse',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Fermer',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  _restaurantAddress.isNotEmpty
                      ? _restaurantAddress
                      : 'Adresse non disponible',
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                // Map preview
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.map,
                                  size: 48,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Carte interactive',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Icon(
                            Icons.location_on,
                            size: 40,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.directions, color: Colors.white),
                              SizedBox(width: 12),
                              Text('Ouverture de la carte à venir'),
                            ],
                          ),
                          backgroundColor: AppColors.primaryOrange,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Obtenir l\'itinéraire'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOpeningHoursModal() {
    // Map English days to French
    final dayTranslations = {
      'Monday': 'Lundi',
      'Tuesday': 'Mardi',
      'Wednesday': 'Mercredi',
      'Thursday': 'Jeudi',
      'Friday': 'Vendredi',
      'Saturday': 'Samedi',
      'Sunday': 'Dimanche',
    };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          elevation: 10,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryOrange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Horaires d\'ouverture',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Fermer',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_workTime.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Horaires non disponibles',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                  )
                else
                  ..._workTime.map((schedule) {
                    final dayEnglish = schedule['day'] as String? ?? '';
                    final dayFrench = dayTranslations[dayEnglish] ?? dayEnglish;
                    final openTime = schedule['open_time'] as String? ?? '';
                    final closeTime = schedule['close_time'] as String? ?? '';
                    final isClosed = schedule['is_closed'] as bool? ?? false;
                    final isToday = _isToday(dayEnglish);

                    String hours;
                    if (isClosed) {
                      hours = 'Fermé';
                    } else if (openTime.isNotEmpty && closeTime.isNotEmpty) {
                      hours = '$openTime - $closeTime';
                    } else {
                      hours = 'Non renseigné';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: isToday ? AppColors.gradientPrimary : null,
                        color: isToday ? null : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: isToday
                            ? null
                            : Border.all(
                                color: AppColors.primaryOrange.withOpacity(0.1),
                              ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (isToday)
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: const BoxDecoration(
                                    color: Colors.greenAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Text(
                                dayFrench,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isToday
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isToday
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            hours,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isClosed
                                  ? (isToday ? Colors.white70 : Colors.red)
                                  : (isToday
                                      ? Colors.white
                                      : AppColors.primaryOrange),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPhoneModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryOrange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Contact',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'Fermer',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_restaurantPhone.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Numéro de téléphone non disponible',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                  )
                else ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryOrange.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Numéro de téléphone',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _restaurantPhone,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primaryOrange),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.copy,
                              color: AppColors.primaryOrange,
                            ),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: _restaurantPhone),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        'Numéro copié dans le presse-papier',
                                      ),
                                    ],
                                  ),
                                  backgroundColor: AppColors.primaryOrange,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            tooltip: 'Copier',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await _makePhoneCall(_restaurantPhone);
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Appeler'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isToday(String day) {
    final now = DateTime.now();
    final weekday = now.weekday;
    final dayName = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ][weekday - 1];
    return day.toLowerCase().contains(dayName.toLowerCase());
  }

  void _calculateOpeningStatus() {
    if (_workTime.isEmpty) {
      _isOpenNow = false;
      _openingStatus = 'Horaires non disponibles';
      return;
    }

    final now = DateTime.now();
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final currentDay = dayNames[now.weekday - 1];

    // Find today's schedule
    final todaySchedule = _workTime.firstWhere(
      (schedule) => schedule['day'] == currentDay,
      orElse: () => {},
    );

    if (todaySchedule.isEmpty) {
      _isOpenNow = false;
      _openingStatus = 'Fermé';
      return;
    }

    final isClosed = todaySchedule['is_closed'] as bool? ?? true;
    if (isClosed) {
      _isOpenNow = false;
      _openingStatus = 'Fermé aujourd\'hui';
      return;
    }

    final openTime = todaySchedule['open_time'] as String? ?? '';
    final closeTime = todaySchedule['close_time'] as String? ?? '';

    if (openTime.isEmpty || closeTime.isEmpty) {
      _isOpenNow = false;
      _openingStatus = 'Fermé';
      return;
    }

    // Parse times
    try {
      final openParts = openTime.split(':');
      final closeParts = closeTime.split(':');
      
      final openHour = int.parse(openParts[0]);
      final openMinute = int.parse(openParts[1]);
      final closeHour = int.parse(closeParts[0]);
      final closeMinute = int.parse(closeParts[1]);

      final currentMinutes = now.hour * 60 + now.minute;
      final openMinutes = openHour * 60 + openMinute;
      final closeMinutes = closeHour * 60 + closeMinute;

      if (currentMinutes >= openMinutes && currentMinutes < closeMinutes) {
        _isOpenNow = true;
        _openingStatus = 'Ouvert jusqu\'à $closeTime';
      } else if (currentMinutes < openMinutes) {
        _isOpenNow = false;
        _openingStatus = 'Ouvre à $openTime';
      } else {
        _isOpenNow = false;
        _openingStatus = 'Fermé';
      }
    } catch (e) {
      debugPrint('Error parsing opening hours: $e');
      _isOpenNow = false;
      _openingStatus = 'Fermé';
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Remove all spaces and special characters except + and numbers
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri telUri = Uri(scheme: 'tel', path: cleanNumber);
    
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Impossible d\'ouvrir l\'application téléphone'),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching phone: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Erreur: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Widget _buildRestaurantImage() {
    if (_pictures.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 80, color: Colors.grey[500]),
            const SizedBox(height: 12),
            Text(
              'Image non disponible',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
    }

    final picturePath = _pictures[0];

    // Check if it's a local file
    if (picturePath.isNotEmpty && !picturePath.startsWith('http')) {
      final file = File(picturePath);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    // Try loading as network image
    if (picturePath.startsWith('http')) {
      return Image.network(
        picturePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 80, color: Colors.grey[500]),
              const SizedBox(height: 12),
              Text(
                'Image non disponible',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    // Fallback
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 80, color: Colors.grey[500]),
          const SizedBox(height: 12),
          Text(
            'Image non disponible',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDishImage(String dishImage) {
    if (dishImage.isEmpty) {
      return Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          gradient: AppColors.gradientPrimary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.restaurant, color: Colors.white, size: 36),
      );
    }

    // Check if it's a local file
    if (!dishImage.startsWith('http')) {
      final file = File(dishImage);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(file, width: 90, height: 90, fit: BoxFit.cover),
        );
      }
    }

    // Try loading as network image
    if (dishImage.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          dishImage,
          width: 90,
          height: 90,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: AppColors.gradientPrimary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.broken_image,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
      );
    }

    // Fallback
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.restaurant, color: Colors.white, size: 36),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.gradientPrimary,
            ),
          ),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: widget.onBack,
          ),
          title: const Text(
            'Chargement...',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange),
        ),
      );
    }

    if (_restaurantData == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.gradientPrimary,
            ),
          ),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: widget.onBack,
          ),
          title: const Text(
            'Erreur',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Restaurant introuvable',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: widget.onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header avec image
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
              ),
              onPressed: widget.onBack,
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : AppColors.textPrimary,
                    size: 20,
                  ),
                ),
                onPressed: () => setState(() => _isFavorite = !_isFavorite),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.share,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.share, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Partage à venir'),
                        ],
                      ),
                      backgroundColor: AppColors.primaryOrange,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildRestaurantImage(),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _restaurantName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryYellow,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$_totalReviews avis',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _priceRange,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Cartes d'info rapide
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showAddressModal(),
                          child: _QuickInfoCard(
                            icon: Icons.location_on,
                            label: _restaurantAddress.isNotEmpty
                                ? _restaurantAddress.split(',').first
                                : 'Adresse',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showOpeningHoursModal(),
                          child: _QuickInfoCard(
                            icon: Icons.access_time,
                            label: _openingStatus,
                            isOpen: _isOpenNow,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showPhoneModal(),
                          child: const _QuickInfoCard(
                            icon: Icons.phone,
                            label: 'Appeler',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryOrange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      tabs: [
                        const Tab(text: 'Menu'),
                        Tab(text: 'Avis ($_totalReviews)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contenu des tabs
                  SizedBox(
                    height: 600,
                    child: TabBarView(
                      controller: _tabController,
                      children: [_buildMenuTab(), _buildReviewsTab()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTab() {
    if (_dishes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOrange.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant_menu,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun plat disponible',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Le menu sera bientôt disponible',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _dishes.length,
      itemBuilder: (context, index) {
        final dish = _dishes[index];
        final dishName = dish['name'] as String;
        final dishCategory = dish['category'] as String;
        final dishPrice = (dish['price'] as num?)?.toDouble() ?? 0.0;
        final dishPreparationTime = dish['preparation_time'] as String? ?? '';
        final dishPictures = (dish['pictures'] as List<dynamic>).cast<String>();
        final dishImage = dishPictures.isNotEmpty ? dishPictures[0] : '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dishName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          dishCategory,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (dishPreparationTime.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dishPreparationTime,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientPrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${dishPrice.toStringAsFixed(2)}€',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (dishImage.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  _buildDishImage(dishImage),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    // Use the new RestaurantReviewsSection component
    return SingleChildScrollView(
      child: RestaurantReviewsSection(
        restaurantId: widget.restaurantId,
        restaurantName: _restaurantName,
      ),
    );
  }
}

class _QuickInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool? isOpen;

  const _QuickInfoCard({
    required this.icon,
    required this.label,
    this.isOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: isOpen == true
                        ? const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : (isOpen == false
                            ? const LinearGradient(
                                colors: [Color(0xFFEF5350), Color(0xFFE53935)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : AppColors.gradientPrimary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                if (isOpen != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isOpen! ? Colors.greenAccent : Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isOpen == true
                    ? const Color(0xFF4CAF50)
                    : (isOpen == false
                        ? const Color(0xFFEF5350)
                        : AppColors.textSecondary),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
