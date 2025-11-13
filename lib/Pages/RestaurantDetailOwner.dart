import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/AddDishModal.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';
import 'package:mobile_app_project/services/Restaurant/RestaurantService.dart';
import 'package:mobile_app_project/services/Restaurant/DishService.dart';
import 'package:mobile_app_project/Pages/UI/ConfirmDeleteDialog.dart';
import 'package:mobile_app_project/Pages/UI/RestaurantReviewsSection.dart';
import 'dart:io';

class RestaurantDetailOwner extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailOwner({Key? key, required this.restaurantId})
    : super(key: key);

  @override
  State<RestaurantDetailOwner> createState() => _RestaurantDetailOwnerState();
}

class WorkTime {
  final String day;
  final String openTime;
  final String closeTime;
  final bool isClosed;

  WorkTime({
    required this.day,
    required this.openTime,
    required this.closeTime,
    required this.isClosed,
  });

  factory WorkTime.fromJson(Map<String, dynamic> json) {
    return WorkTime(
      day: json['day'] ?? '',
      openTime: json['open_time'] ?? '',
      closeTime: json['close_time'] ?? '',
      isClosed: json['is_closed'] ?? false,
    );
  }
}

class Dish {
  final int id;
  final String name;
  final String category;
  final double price;
  final String preparationTime;
  final List<String> pictures;

  Dish({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.preparationTime,
    required this.pictures,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      preparationTime: json['preparation_time'] ?? '',
      pictures: List<String>.from(json['pictures'] ?? []),
    );
  }
}

class RestaurantDetailData {
  final int id;
  final String name;
  final String phone;
  final String adresse;
  final List<String> pictures;
  final List<WorkTime> workTime;

  RestaurantDetailData({
    required this.id,
    required this.name,
    required this.phone,
    required this.adresse,
    required this.pictures,
    required this.workTime,
  });

  factory RestaurantDetailData.fromJson(Map<String, dynamic> json) {
    return RestaurantDetailData(
      id: json['id'],
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      adresse: json['adresse'] ?? '',
      pictures: List<String>.from(json['pictures'] ?? []),
      workTime:
          (json['work_time'] as List<dynamic>?)
              ?.map((item) => WorkTime.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class _RestaurantDetailOwnerState extends State<RestaurantDetailOwner> {
  RestaurantDetailData? _restaurant;
  bool _isLoading = true;
  String? _error;
  int _currentImageIndex = 0;
  List<Dish> _dishes = [];
  bool _isLoadingDishes = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurantDetails();
    _loadDishes();
  }

  Future<void> _loadRestaurantDetails() async {
    try {
      // Fetch restaurant from local SQLite database
      final data = await RestaurantService.instance.getRestaurant(
        widget.restaurantId,
      );

      if (data != null && mounted) {
        setState(() {
          _restaurant = RestaurantDetailData.fromJson(data);
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _error = 'Restaurant non trouvé';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading restaurant details: $e');
      if (mounted) {
        setState(() {
          _error = 'Erreur lors du chargement: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadDishes() async {
    try {
      // Fetch dishes from local SQLite database
      final data = await DishService.instance.getDishesByRestaurant(
        widget.restaurantId,
      );

      if (mounted) {
        setState(() {
          _dishes = data.map((json) => Dish.fromJson(json)).toList();
          _isLoadingDishes = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading dishes: $e');
      if (mounted) {
        setState(() {
          _isLoadingDishes = false;
        });
      }
    }
  }

  void _showAddDishModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddDishModal(
          restaurantId: widget.restaurantId,
          onDishAdded: () {
            // Reload dishes after adding
            _loadDishes();
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDeleteDialog(
        title: 'Supprimer le restaurant',
        message:
            'Êtes-vous sûr de vouloir supprimer "${_restaurant?.name}" ? Cette action est irréversible et supprimera également tous les plats associés.',
        onConfirm: _deleteRestaurant,
      ),
    );
  }

  Future<void> _deleteRestaurant() async {
    try {
      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryOrange),
          ),
        );
      }

      // Delete restaurant from database
      final success = await RestaurantService.instance.deleteRestaurant(
        widget.restaurantId,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Restaurant supprimé avec succès'),
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

        // Navigate back to dashboard
        Navigator.of(context).pop();
      } else if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Erreur lors de la suppression'),
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
    } catch (e) {
      debugPrint('Error deleting restaurant: $e');

      // Close loading dialog if still open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erreur: ${e.toString()}')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange),
            )
          : _error != null
          ? _buildErrorState()
          : _restaurant == null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Restaurant introuvable',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_restaurant!.pictures.isNotEmpty) _buildImageCarousel(),
              _buildRestaurantInfo(),
              _buildContactSection(),
              _buildWorkHoursSection(),
              _buildDishesSection(),
              _buildReviewsSection(),
              _buildDeleteSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.gradientPrimary),
        ),
        title: Text(
          _restaurant!.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            // TODO: Navigate to edit screen
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Fonctionnalité à venir: Modifier le restaurant',
                ),
                backgroundColor: AppColors.primaryOrange,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    if (_restaurant!.pictures.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            PageView.builder(
              itemCount: _restaurant!.pictures.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final picturePath = _restaurant!.pictures[index];
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(color: Colors.grey),
                  child:
                      picturePath.isNotEmpty && File(picturePath).existsSync()
                      ? Image.file(File(picturePath), fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey[300],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 64,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Image non disponible',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                );
              },
            ),
            // Image counter
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${_restaurant!.pictures.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Page indicators (dots)
            if (_restaurant!.pictures.length > 1)
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _restaurant!.pictures.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _restaurant!.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Restaurant',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations de contact',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.phone,
            'Téléphone',
            _restaurant!.phone,
            AppColors.textPrimary,
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            Icons.location_on,
            'Adresse',
            _restaurant!.adresse,
            AppColors.primaryOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWorkHoursSection() {
    if (_restaurant!.workTime.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort days
    final daysOrder = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    final sortedWorkTime = List<WorkTime>.from(_restaurant!.workTime);
    sortedWorkTime.sort((a, b) {
      final indexA = daysOrder.indexOf(a.day);
      final indexB = daysOrder.indexOf(b.day);
      return indexA.compareTo(indexB);
    });

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: AppColors.primaryOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Horaires d\'ouverture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sortedWorkTime
              .map((workTime) => _buildWorkTimeRow(workTime))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildWorkTimeRow(WorkTime workTime) {
    final isToday = _isToday(workTime.day);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.primaryOrange.withOpacity(0.05)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? AppColors.primaryOrange.withOpacity(0.3)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          if (isToday)
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primaryOrange,
                borderRadius: BorderRadius.circular(2),
              ),
              margin: const EdgeInsets.only(right: 12),
            ),
          Expanded(
            flex: 2,
            child: Text(
              workTime.day,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                color: isToday
                    ? AppColors.primaryOrange
                    : AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: workTime.isClosed
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Fermé',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: isToday
                            ? AppColors.primaryOrange
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workTime.openTime} - ${workTime.closeTime}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isToday
                              ? AppColors.primaryOrange
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishesSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: AppColors.primaryOrange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Menu',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              if (!_isLoadingDishes && _dishes.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_dishes.length} plat${_dishes.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const Spacer(),
              // Add Dish Button
              Container(
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showAddDishModal,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'Ajouter',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingDishes)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(
                  color: AppColors.primaryOrange,
                ),
              ),
            )
          else if (_dishes.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.no_meals, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun plat pour le moment',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _showAddDishModal,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ajouter un plat'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryOrange,
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: _dishes.map((dish) => _buildDishCard(dish)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return RestaurantReviewsSection(
      restaurantId: widget.restaurantId,
      restaurantName: _restaurant?.name ?? 'Restaurant',
      showAddReviewButton: false,
    );
  }

  Widget _buildDeleteSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Zone de danger',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Une fois supprimé, le restaurant et tous ses plats seront définitivement perdus.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showDeleteConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.delete_forever, size: 20),
              label: const Text(
                'Supprimer le restaurant',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishCard(Dish dish) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          // Dish Image
          if (dish.pictures.isNotEmpty && File(dish.pictures[0]).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(dish.pictures[0]),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 24,
              ),
            ),
          const SizedBox(width: 12),
          // Dish Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        dish.category,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Price
                    Icon(Icons.euro, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${dish.price.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (dish.preparationTime.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dish.preparationTime,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Edit/View button
          IconButton(
            icon: const Icon(Icons.more_vert),
            color: Colors.grey[600],
            onPressed: () {
              // TODO: Show options (edit, delete, view)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Fonctionnalité à venir: Gérer le plat'),
                  backgroundColor: AppColors.primaryOrange,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isToday(String day) {
    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday

    final daysMap = {
      1: 'Lundi',
      2: 'Mardi',
      3: 'Mercredi',
      4: 'Jeudi',
      5: 'Vendredi',
      6: 'Samedi',
      7: 'Dimanche',
    };

    return daysMap[weekday] == day;
  }
}
