import 'package:flutter/material.dart';
import 'package:mobile_app_project/Pages/UI/PhoneInputField.dart';
import 'package:mobile_app_project/Pages/UI/AddressInputField.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';
import 'package:mobile_app_project/Pages/UI/MapLocationPicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';
import 'package:mobile_app_project/services/Restaurant/RestaurantService.dart';

class AddRestaurantModal extends StatefulWidget {
  final int ownerId;
  final VoidCallback onRestaurantAdded;
  final Map<String, dynamic>? restaurantToEdit;

  const AddRestaurantModal({
    Key? key,
    required this.ownerId,
    required this.onRestaurantAdded,
    this.restaurantToEdit,
  }) : super(key: key);

  @override
  State<AddRestaurantModal> createState() => _AddRestaurantModalState();
}

class _AddRestaurantModalState extends State<AddRestaurantModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isSubmitting = false;
  Country _selectedCountry = const Country(
    name: 'France',
    code: 'FR',
    dialCode: '+33',
    flag: '🇫🇷',
  );
  CountryData _selectedAddressCountry = const CountryData(
    name: 'France',
    code: 'FR',
    flag: '🇫🇷',
    states: [],
  );
  String? _selectedState;
  String _selectedCuisine = 'Français';
  String _selectedPriceRange = '€€';
  
  // Location coordinates
  double? _latitude;
  double? _longitude;

  final List<String> _cuisineTypes = [
    'Français',
    'Italien',
    'Japonais',
    'Chinois',
    'Indien',
    'Mexicain',
    'Thaï',
    'Vietnamien',
    'Méditerranéen',
    'Fast-food',
    'Végétarien',
    'Autre',
  ];

  final List<String> _priceRanges = ['€', '€€', '€€€', '€€€€'];

  // Pictures state
  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // Work hours state
  final Map<String, Map<String, dynamic>> _workHours = {
    'Monday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '22:00'},
    'Tuesday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '22:00'},
    'Wednesday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '22:00'},
    'Thursday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '22:00'},
    'Friday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '22:00'},
    'Saturday': {'isOpen': true, 'openTime': '09:00', 'closeTime': '22:00'},
    'Sunday': {'isOpen': false, 'openTime': '09:00', 'closeTime': '22:00'},
  };

  final Map<String, String> _dayTranslations = {
    'Monday': 'Lundi',
    'Tuesday': 'Mardi',
    'Wednesday': 'Mercredi',
    'Thursday': 'Jeudi',
    'Friday': 'Vendredi',
    'Saturday': 'Samedi',
    'Sunday': 'Dimanche',
  };

  @override
  void initState() {
    super.initState();
    debugPrint('🏪 AddRestaurantModal initState - Edit mode: ${widget.restaurantToEdit != null}');
    if (widget.restaurantToEdit != null) {
      debugPrint('📝 Pre-populating form with restaurant data');
      _prePopulateForm();
    }
  }

  void _prePopulateForm() {
    final restaurant = widget.restaurantToEdit!;
    
    // Set name
    _nameController.text = restaurant['name'] as String? ?? '';
    
    // Set address
    _addressController.text = restaurant['adresse'] as String? ?? '';
    
    // Set phone (extract without dial code)
    final phone = restaurant['phone'] as String? ?? '';
    if (phone.isNotEmpty) {
      // Remove dial code prefix if present
      final phoneWithoutCode = phone.replaceFirst(RegExp(r'^\+\d+\s*'), '');
      _phoneController.text = phoneWithoutCode;
    }
    
    // Set cuisine and price range
    _selectedCuisine = restaurant['cuisine'] as String? ?? 'Français';
    _selectedPriceRange = restaurant['price_range'] as String? ?? '€€';
    
    // Set location coordinates
    _latitude = restaurant['latitude'] as double?;
    _longitude = restaurant['longitude'] as double?;
    
    // Set pictures
    final pictures = restaurant['pictures'] as List<dynamic>? ?? [];
    _selectedImages = pictures
        .map((path) => XFile(path.toString()))
        .toList();
    
    // Set work hours
    final workTime = restaurant['work_time'] as List<dynamic>? ?? [];
    for (var schedule in workTime) {
      final day = schedule['day'] as String;
      final isOpen = !(schedule['is_closed'] as bool? ?? true);
      final openTime = schedule['open_time'] as String? ?? '09:00';
      final closeTime = schedule['close_time'] as String? ?? '18:00';
      
      if (_workHours.containsKey(day)) {
        _workHours[day] = {
          'isOpen': isOpen,
          'openTime': openTime,
          'closeTime': closeTime,
        };
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Build complete address
      final addressParts = <String>[_addressController.text.trim()];
      if (_selectedState != null) addressParts.add(_selectedState!);
      addressParts.add(_selectedAddressCountry.name);
      final fullAddress = addressParts.join(', ');

      // Build work_time array from _workHours map
      final workTimeList = _workHours.entries.map((entry) {
        return {
          'day': entry.key,
          'open_time': entry.value['isOpen']
              ? entry.value['openTime']
              : '00:00',
          'close_time': entry.value['isOpen']
              ? entry.value['closeTime']
              : '00:00',
          'is_closed': !entry.value['isOpen'],
        };
      }).toList();

      // Store image paths (local paths)
      List<String> picturePaths = [];
      for (var imageFile in _selectedImages) {
        picturePaths.add(imageFile.path);
      }

      // Prepare restaurant data
      final restaurantData = {
        'name': _nameController.text.trim(),
        'phone': '${_selectedCountry.dialCode} ${_phoneController.text.trim()}',
        'adresse': fullAddress,
        'pictures': picturePaths,
        'work_time': workTimeList,
        'owner_id': widget.ownerId,
        'cuisine': _selectedCuisine,
        'price_range': _selectedPriceRange,
        if (_latitude != null) 'latitude': _latitude,
        if (_longitude != null) 'longitude': _longitude,
      };

      // Check if we're editing or creating
      final isEditing = widget.restaurantToEdit != null;
      
      if (isEditing) {
        final restaurantId = widget.restaurantToEdit!['id'] as int;
        await RestaurantService.instance.updateRestaurant(restaurantId, restaurantData);
      } else {
        await RestaurantService.instance.createRestaurant(restaurantData);
      }

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Success
        widget.onRestaurantAdded();
        Navigator.of(context).pop();
        _showSuccessSnackBar(
          isEditing 
            ? 'Restaurant modifié avec succès!' 
            : 'Restaurant créé avec succès!'
        );
      }
    } catch (e) {
      debugPrint('Error creating restaurant: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        _showErrorSnackBar(
          'Erreur lors de la création du restaurant: ${e.toString()}',
        );
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
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
                    Icons.restaurant,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.restaurantToEdit != null 
                            ? 'Modifier le restaurant' 
                            : 'Nouveau restaurant',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        widget.restaurantToEdit != null 
                            ? 'Modifiez les informations' 
                            : 'Remplissez les informations',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Restaurant Name
                    const Text(
                      'Nom du restaurant *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Le Gourmet',
                        prefixIcon: const Icon(Icons.restaurant_menu, size: 20),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryOrange,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le nom est requis';
                        }
                        if (value.trim().length < 3) {
                          return 'Le nom doit contenir au moins 3 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Cuisine Type
                    const Text(
                      'Type de cuisine *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCuisine,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: const Icon(Icons.restaurant, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryOrange,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      items: _cuisineTypes.map((String cuisine) {
                        return DropdownMenuItem<String>(
                          value: cuisine,
                          child: Text(cuisine),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedCuisine = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    // Price Range
                    const Text(
                      'Gamme de prix *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedPriceRange,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[50],
                        prefixIcon: const Icon(Icons.euro, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primaryOrange,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      items: _priceRanges.map((String range) {
                        return DropdownMenuItem<String>(
                          value: range,
                          child: Text(range),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedPriceRange = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    // Phone Number
                    const Text(
                      'Numéro de téléphone *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    PhoneInputField(
                      controller: _phoneController,
                      onCountryChanged: (country) {
                        setState(() {
                          _selectedCountry = country;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    // Address
                    const Text(
                      'Adresse *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AddressInputField(
                      addressController: _addressController,
                      onCountryChanged: (country) {
                        setState(() {
                          _selectedAddressCountry = country;
                        });
                      },
                      onStateChanged: (state) {
                        setState(() {
                          _selectedState = state;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    // Location Section
                    const Text(
                      'Emplacement sur la carte',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final result = await showDialog<LatLng>(
                          context: context,
                          builder: (context) => MapLocationPicker(
                            initialLocation: _latitude != null && _longitude != null
                                ? LatLng(_latitude!, _longitude!)
                                : null,
                            onLocationSelected: (location) {
                              // Location will be set when dialog closes
                            },
                          ),
                        );
                        
                        if (result != null) {
                          setState(() {
                            _latitude = result.latitude;
                            _longitude = result.longitude;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _latitude != null && _longitude != null
                              ? AppColors.primaryOrange.withOpacity(0.1)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _latitude != null && _longitude != null
                                ? AppColors.primaryOrange
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _latitude != null && _longitude != null
                                  ? Icons.location_on
                                  : Icons.location_off,
                              color: _latitude != null && _longitude != null
                                  ? AppColors.primaryOrange
                                  : Colors.grey[400],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _latitude != null && _longitude != null
                                        ? 'Emplacement sélectionné'
                                        : 'Sélectionner sur la carte',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _latitude != null && _longitude != null
                                          ? AppColors.primaryOrange
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  if (_latitude != null && _longitude != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Lat: ${_latitude!.toStringAsFixed(6)}, '
                                      'Long: ${_longitude!.toStringAsFixed(6)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Optionnel: Ajoutez l\'emplacement pour apparaître sur la carte',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Pictures Section
                    const Text(
                      'Photos du restaurant',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPicturesSection(),
                    const SizedBox(height: 24),
                    // Work Hours Section
                    const Text(
                      'Horaires d\'ouverture',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        children: _workHours.entries.map((entry) {
                          return _buildDayRow(entry.key, entry.value);
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Submit Button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_circle_outline, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Créer le restaurant',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Cancel Button
                    SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Annuler',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(String day, Map<String, dynamic> dayData) {
    final isOpen = dayData['isOpen'] as bool;
    final openTime = dayData['openTime'] as String;
    final closeTime = dayData['closeTime'] as String;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Day name and toggle
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: isOpen ? AppColors.primaryOrange : Colors.grey[400],
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dayTranslations[day] ?? day,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isOpen
                            ? AppColors.textPrimary
                            : Colors.grey[600],
                      ),
                    ),
                    Text(
                      isOpen ? 'Ouvert' : 'Fermé',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOpen
                            ? AppColors.primaryOrange
                            : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isOpen,
                onChanged: (value) {
                  setState(() {
                    _workHours[day]!['isOpen'] = value;
                  });
                },
                activeColor: AppColors.primaryOrange,
              ),
            ],
          ),
          // Time inputs (shown only when open)
          if (isOpen) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    label: 'Ouverture',
                    value: openTime,
                    onTap: () => _selectTime(day, 'openTime', openTime),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeField(
                    label: 'Fermeture',
                    value: closeTime,
                    onTap: () => _selectTime(day, 'closeTime', closeTime),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.primaryOrange,
                ),
                const SizedBox(width: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(
    String day,
    String timeType,
    String currentTime,
  ) async {
    final parts = currentTime.split(':');
    final initialHour = int.tryParse(parts[0]) ?? 9;
    final initialMinute = int.tryParse(parts[1]) ?? 0;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOrange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedTime =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _workHours[day]![timeType] = formattedTime;
      });
    }
  }

  Widget _buildPicturesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add pictures button
          InkWell(
            onTap: _pickImages,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryOrange,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    color: AppColors.primaryOrange,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Ajouter des photos',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Display selected images
          if (_selectedImages.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '${_selectedImages.length} photo${_selectedImages.length > 1 ? 's' : ''} sélectionnée${_selectedImages.length > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return _buildImagePreview(index);
                },
              ),
            ),
          ],
          // Info text
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ajoutez jusqu\'à 10 photos de votre restaurant',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_selectedImages[index].path),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          // Remove button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);

      if (images.isNotEmpty) {
        setState(() {
          // Limit to 10 images total
          final remainingSlots = 10 - _selectedImages.length;
          if (remainingSlots > 0) {
            _selectedImages.addAll(images.take(remainingSlots));
          }
        });

        if (images.length > 10 - (_selectedImages.length - images.length)) {
          _showErrorSnackBar('Maximum 10 photos autorisées');
        }
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      _showErrorSnackBar('Erreur lors de la sélection des images');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }
}
