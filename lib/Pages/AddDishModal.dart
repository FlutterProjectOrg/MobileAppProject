import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mobile_app_project/services/Restaurant/DishService.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

class AddDishModal extends StatefulWidget {
  final int restaurantId;
  final VoidCallback onDishAdded;
  final Map<String, dynamic>? dishToEdit;

  const AddDishModal({
    Key? key,
    required this.restaurantId,
    required this.onDishAdded,
    this.dishToEdit,
  }) : super(key: key);

  @override
  State<AddDishModal> createState() => _AddDishModalState();
}

class _AddDishModalState extends State<AddDishModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _preparationTimeController = TextEditingController();
  bool _isSubmitting = false;

  // Pictures state
  List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // Common dish categories
  final List<String> _categories = [
    'Entrée',
    'Plat principal',
    'Dessert',
    'Boisson',
    'Apéritif',
    'Salade',
    'Pizza',
    'Burger',
    'Pâtes',
    'Fruits de mer',
    'Viande',
    'Végétarien',
    'Autre',
  ];

  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    debugPrint('🍽️ AddDishModal initState - Edit mode: ${widget.dishToEdit != null}');
    if (widget.dishToEdit != null) {
      debugPrint('📝 Pre-populating form with dish data');
      _prePopulateForm();
    }
  }

  void _prePopulateForm() {
    final dish = widget.dishToEdit!;
    
    _nameController.text = dish['name'] as String? ?? '';
    final category = dish['category'] as String? ?? '';
    _categoryController.text = category;
    _selectedCategory = _categories.contains(category) ? category : null;
    
    final price = dish['price'] as num? ?? 0.0;
    _priceController.text = price.toString();
    
    _preparationTimeController.text = dish['preparation_time'] as String? ?? '';
    
    final pictures = dish['pictures'] as List<dynamic>? ?? [];
    _selectedImages = pictures
        .map((path) => XFile(path.toString()))
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _preparationTimeController.dispose();
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
      // Store image paths (local paths)
      List<String> picturePaths = [];
      for (var imageFile in _selectedImages) {
        picturePaths.add(imageFile.path);
      }

      final category = _selectedCategory ?? _categoryController.text.trim();

      // Parse price
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

      // Prepare dish data
      final dishData = {
        'name': _nameController.text.trim(),
        'category': category,
        'price': price,
        'preparation_time': _preparationTimeController.text.trim(),
        'pictures': picturePaths,
        'restaurant_id': widget.restaurantId,
      };

      // Check if we're editing or creating
      final isEditing = widget.dishToEdit != null;
      
      if (isEditing) {
        final dishId = widget.dishToEdit!['id'] as int;
        await DishService.instance.updateDish(dishId, dishData);
      } else {
        await DishService.instance.createDish(dishData);
      }

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Success
        widget.onDishAdded();
        Navigator.of(context).pop();
        _showSuccessSnackBar(
          isEditing 
            ? 'Plat modifié avec succès!' 
            : 'Plat créé avec succès!'
        );
      }
    } catch (e) {
      debugPrint('Error creating dish: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        _showErrorSnackBar(
          'Erreur lors de la création du plat: ${e.toString()}',
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
        backgroundColor: Colors.green,
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
            Text(message),
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
                    Icons.restaurant_menu,
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
                        widget.dishToEdit != null 
                            ? 'Modifier le plat' 
                            : 'Ajouter un plat',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        widget.dishToEdit != null 
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
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    const Text(
                      'Nom du plat *',
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
                        hintText: 'Ex: Pizza Margherita',
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
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer le nom du plat';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Category field
                    const Text(
                      'Catégorie *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        hintText: 'Sélectionnez une catégorie',
                        prefixIcon: const Icon(Icons.category, size: 20),
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
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner une catégorie';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Price field
                    const Text(
                      'Prix (€) *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ex: 12.50',
                        prefixIcon: const Icon(Icons.euro, size: 20),
                        suffixText: '€',
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
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer le prix';
                        }
                        final price = double.tryParse(value.trim());
                        if (price == null || price < 0) {
                          return 'Veuillez entrer un prix valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Preparation time field
                    const Text(
                      'Temps de préparation *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _preparationTimeController,
                      decoration: InputDecoration(
                        hintText: 'Ex: 15 min',
                        prefixIcon: const Icon(Icons.access_time, size: 20),
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
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez entrer le temps de préparation';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Pictures section
                    const Text(
                      'Photos du plat',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPicturesSection(),
                    const SizedBox(height: 32),

                    // Submit button
                    SizedBox(
                      height: 54,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
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
                                    'Créer le plat',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
                border: Border.all(color: AppColors.primaryOrange, width: 2),
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
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) => _buildImagePreview(index),
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
                  'Ajoutez jusqu\'à 5 photos du plat',
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
                      offset: const Offset(0, 2),
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
          // Limit to 5 images total
          final remainingSlots = 5 - _selectedImages.length;
          if (remainingSlots > 0) {
            _selectedImages.addAll(images.take(remainingSlots));
          }
        });

        if (images.length > 5 - (_selectedImages.length - images.length)) {
          _showErrorSnackBar('Maximum 5 photos autorisées');
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
