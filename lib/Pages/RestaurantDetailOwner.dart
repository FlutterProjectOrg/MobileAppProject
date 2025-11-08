import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_app_project/Pages/AddDishModal.dart';

class RestaurantDetailOwner extends StatefulWidget {
  final int restaurantId;

  const RestaurantDetailOwner({Key? key, required this.restaurantId}) : super(key: key);

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
  final List<String> pictures;

  Dish({
    required this.id,
    required this.name,
    required this.category,
    required this.pictures,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'],
      name: json['name'] ?? '',
      category: json['category'] ?? '',
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
      workTime: (json['work_time'] as List<dynamic>?)
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
      final baseUrl = dotenv.env['DB_URL'] ?? 'http://localhost:8000';
      final response = await http.get(
        Uri.parse('$baseUrl/restaurants/${widget.restaurantId}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _restaurant = RestaurantDetailData.fromJson(data);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Erreur lors du chargement du restaurant';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading restaurant details: $e');
      if (mounted) {
        setState(() {
          _error = 'Erreur de connexion';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadDishes() async {
    try {
      final baseUrl = dotenv.env['DB_URL'] ?? 'http://localhost:8000';
      final response = await http.get(
        Uri.parse('$baseUrl/dishes/restaurant/${widget.restaurantId}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _dishes = data.map((json) => Dish.fromJson(json)).toList();
            _isLoadingDishes = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingDishes = false;
          });
        }
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

  String _getImageUrl(String picturePath) {
    final baseUrl = dotenv.env['DB_URL'] ?? 'http://localhost:8000';
    // Remove leading slash if present
    final path = picturePath.startsWith('/') ? picturePath.substring(1) : picturePath;
    return '$baseUrl/$path';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
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
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? 'Restaurant introuvable',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
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
      backgroundColor: const Color(0xFF10B981),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
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
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () {
            // TODO: Navigate to edit screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Fonctionnalité à venir: Modifier le restaurant'),
                backgroundColor: Color(0xFF10B981),
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
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                  ),
                  child: Image.network(
                    _getImageUrl(picturePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
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
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            // Image counter
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
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
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Restaurant',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF10B981),
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
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.phone,
            'Téléphone',
            _restaurant!.phone,
            const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 12),
          _buildContactItem(
            Icons.location_on,
            'Adresse',
            _restaurant!.adresse,
            const Color(0xFFEF4444),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
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
                  color: Color(0xFF1F2937),
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
      'Dimanche'
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
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.access_time,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Horaires d\'ouverture',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sortedWorkTime.map((workTime) => _buildWorkTimeRow(workTime)).toList(),
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
            ? const Color(0xFF10B981).withOpacity(0.05)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday 
              ? const Color(0xFF10B981).withOpacity(0.3)
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
                color: const Color(0xFF10B981),
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
                color: isToday ? const Color(0xFF10B981) : const Color(0xFF1F2937),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: workTime.isClosed
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                        color: isToday ? const Color(0xFF10B981) : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${workTime.openTime} - ${workTime.closeTime}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                          color: isToday ? const Color(0xFF10B981) : Colors.grey[700],
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              if (!_isLoadingDishes && _dishes.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_dishes.length} plat${_dishes.length > 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
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
                  color: Color(0xFF10B981),
                ),
              ),
            )
          else if (_dishes.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.no_meals,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun plat pour le moment',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _showAddDishModal,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ajouter un plat'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF10B981),
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

  Widget _buildDishCard(Dish dish) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Dish Image
          if (dish.pictures.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _getImageUrl(dish.pictures[0]),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: Colors.grey[500],
                      size: 24,
                    ),
                  );
                },
              ),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.restaurant,
                color: Colors.grey[500],
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
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    dish.category,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
                const SnackBar(
                  content: Text('Fonctionnalité à venir: Gérer le plat'),
                  backgroundColor: Color(0xFF10B981),
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
