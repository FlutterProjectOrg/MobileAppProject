import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/mock_data.dart';
import 'dart:io';

class RestaurantCard extends StatefulWidget {
  final Restaurant restaurant;
  final VoidCallback onClick;

  const RestaurantCard({
    Key? key,
    required this.restaurant,
    required this.onClick,
  }) : super(key: key);

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClick,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildImageSection(), _buildInfoSection()],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Image du restaurant
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: Stack(
            children: [
              _buildRestaurantImage(),
              // Gradient overlay
              Container(
                width: double.infinity,
                height: 192,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.2)],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Bouton favori
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isFavorite ? Colors.red : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedScale(
                scale: _isFavorite ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
              ),
            ),
          ),
        ),

        // Badge Ouvert/Fermé
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.restaurant.isOpen
                  ? const Color(0xFF22C55E) // green-500
                  : Colors.red,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              widget.restaurant.isOpen ? 'Ouvert' : 'Fermé',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom et cuisine
          Text(
            widget.restaurant.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.restaurant.cuisine,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Rating et Distance
          Row(
            children: [
              // Rating
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7), // yellow-50
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Color(0xFFFACC15), // yellow-500
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.restaurant.rating.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${widget.restaurant.reviews})',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Distance
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Color(0xFF3B82F6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.restaurant.distance,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Prix et Horaires
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Prix
              Row(
                children: [
                  Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                  Text(
                    widget.restaurant.priceRange,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),

              // Horaires d'ouverture
              if (widget.restaurant.isOpen &&
                  widget.restaurant.openUntil != null)
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Color(0xFF22C55E), // green-600
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Ouvert jusqu\'à ${widget.restaurant.openUntil}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantImage() {
    final imagePath = widget.restaurant.image;

    if (imagePath.isEmpty) {
      return Container(
        width: double.infinity,
        height: 192,
        color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 60,
              color: Colors.grey[500],
            ),
            const SizedBox(height: 8),
            Text(
              'Image non disponible',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    // Check if it's a local file
    if (!imagePath.startsWith('http')) {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: double.infinity,
          height: 192,
          fit: BoxFit.cover,
        );
      }
    }

    // Try loading as network image
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: double.infinity,
        height: 192,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 192,
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image,
                  size: 60,
                  color: Colors.grey[500],
                ),
                const SizedBox(height: 8),
                Text(
                  'Image non disponible',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    // Fallback
    return Container(
      width: double.infinity,
      height: 192,
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 60,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 8),
          Text(
            'Image non disponible',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
