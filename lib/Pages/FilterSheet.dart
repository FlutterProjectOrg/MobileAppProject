import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class RestaurantFilters {
  List<String> cuisine;
  List<String> priceRange;
  double rating;
  double distance;

  RestaurantFilters({
    required this.cuisine,
    required this.priceRange,
    required this.rating,
    required this.distance,
  });

  RestaurantFilters copyWith({
    List<String>? cuisine,
    List<String>? priceRange,
    double? rating,
    double? distance,
  }) {
    return RestaurantFilters(
      cuisine: cuisine ?? this.cuisine,
      priceRange: priceRange ?? this.priceRange,
      rating: rating ?? this.rating,
      distance: distance ?? this.distance,
    );
  }
}

class FilterSheet extends StatefulWidget {
  final bool open;
  final VoidCallback onClose;
  final RestaurantFilters filters;
  final Function(RestaurantFilters) onFiltersChange;

  const FilterSheet({
    Key? key,
    required this.open,
    required this.onClose,
    required this.filters,
    required this.onFiltersChange,
  }) : super(key: key);

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late RestaurantFilters _currentFilters;

  final List<String> cuisineTypes = [
    'Italien',
    'Français',
    'Japonais',
    'Indien',
    'Mexicain',
    'Chinois',
    'Thaï',
    'Vietnamien',
  ];

  final List<String> priceRanges = ['€', '€€', '€€€', '€€€€'];

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.filters;
  }

  @override
  void didUpdateWidget(FilterSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filters != oldWidget.filters) {
      _currentFilters = widget.filters;
    }
  }

  void _toggleCuisine(String cuisine) {
    setState(() {
      if (_currentFilters.cuisine.contains(cuisine)) {
        _currentFilters = _currentFilters.copyWith(
          cuisine: _currentFilters.cuisine.where((c) => c != cuisine).toList(),
        );
      } else {
        _currentFilters = _currentFilters.copyWith(
          cuisine: [..._currentFilters.cuisine, cuisine],
        );
      }
    });
  }

  void _togglePrice(String price) {
    setState(() {
      if (_currentFilters.priceRange.contains(price)) {
        _currentFilters = _currentFilters.copyWith(
          priceRange: _currentFilters.priceRange
              .where((p) => p != price)
              .toList(),
        );
      } else {
        _currentFilters = _currentFilters.copyWith(
          priceRange: [..._currentFilters.priceRange, price],
        );
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _currentFilters = RestaurantFilters(
        cuisine: [],
        priceRange: [],
        rating: 0,
        distance: 10,
      );
    });
  }

  void _applyFilters() {
    widget.onFiltersChange(_currentFilters);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.open) return const SizedBox.shrink();

    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // Empêche la fermeture lors du clic sur le sheet
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 500,
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOrange.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  Flexible(child: _buildContent()),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPrimary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Icon(Icons.tune, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Filtres',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCuisineSection(),
          const SizedBox(height: 24),
          _buildPriceSection(),
          const SizedBox(height: 24),
          _buildRatingSection(),
          const SizedBox(height: 24),
          _buildDistanceSection(),
        ],
      ),
    );
  }

  Widget _buildCuisineSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.restaurant, size: 20, color: AppColors.primaryOrange),
            SizedBox(width: 8),
            Text(
              'Type de cuisine',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cuisineTypes.map((cuisine) {
            final isSelected = _currentFilters.cuisine.contains(cuisine);
            return GestureDetector(
              onTap: () => _toggleCuisine(cuisine),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.gradientPrimary : null,
                  color: isSelected ? null : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : AppColors.primaryOrange.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryOrange.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  cuisine,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.euro, size: 20, color: AppColors.primaryOrange),
            SizedBox(width: 8),
            Text(
              'Gamme de prix',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: priceRanges.map((price) {
            final isSelected = _currentFilters.priceRange.contains(price);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => _togglePrice(price),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.gradientPrimary : null,
                      color: isSelected ? null : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.primaryOrange.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primaryOrange.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        price,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.star, size: 20, color: AppColors.primaryYellow),
                SizedBox(width: 8),
                Text(
                  'Note minimum',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary.scale(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 16,
                    color: AppColors.primaryYellow,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _currentFilters.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primaryOrange,
            inactiveTrackColor: AppColors.primaryOrange.withOpacity(0.2),
            thumbColor: AppColors.primaryOrange,
            overlayColor: AppColors.primaryOrange.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: _currentFilters.rating,
            min: 0,
            max: 5,
            divisions: 10,
            onChanged: (value) {
              setState(() {
                _currentFilters = _currentFilters.copyWith(rating: value);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 20,
                  color: AppColors.primaryOrange,
                ),
                SizedBox(width: 8),
                Text(
                  'Distance maximale',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary.scale(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${_currentFilters.distance.toInt()} km',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primaryOrange,
            inactiveTrackColor: AppColors.primaryOrange.withOpacity(0.2),
            thumbColor: AppColors.primaryOrange,
            overlayColor: AppColors.primaryOrange.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: _currentFilters.distance,
            min: 0,
            max: 50,
            divisions: 50,
            onChanged: (value) {
              setState(() {
                _currentFilters = _currentFilters.copyWith(distance: value);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.primaryOrange.withOpacity(0.1)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _resetFilters,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: AppColors.primaryOrange.withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Réinitialiser',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppColors.gradientPrimary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  child: const Text(
                    'Appliquer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
