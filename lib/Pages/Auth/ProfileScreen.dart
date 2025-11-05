import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app_project/services/Auth/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfileScreen({Key? key, required this.onLogout}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _mounted = true;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _dietaryRestrictions = false;
  double _budgetValue = 25;
  final _authService = AuthService();
  UserProfile? _userProfile;
  DeliveryProfile? _deliveryProfile;
  OwnerProfile? _ownerProfile;
  bool _isLoading = false;

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();
  final TextEditingController _restaurantNameController =
      TextEditingController();
  final TextEditingController _restaurantAddressController =
      TextEditingController();
  String? _avatarUrl;

  int? _userId;
  String? _role;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      final role = prefs.getString('role');
      debugPrint('Initializing profile for userId: $userId');
      debugPrint('Mounted status: $role');
      if (!_mounted) return;

      if (userId != null) {
        setState(() {
          _userId = userId;
          _role = role;
        });
        switch (_role) {
          case 'user':
            await _loadUserProfile();
            break;
          case 'delivery':
            await _loadDeliveryProfile();
            break;
          case 'owner':
            await _loadOwnerProfile();
            break;
        }
      } else {
        if (_mounted) {
          widget.onLogout();
        }
      }
    } catch (e) {
      debugPrint('Error initializing profile: $e');
      if (_mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to initialize profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadUserProfile() async {
    if (_userId == null) return;
    setState(() => _isLoading = true);

    try {
      final profile = await _authService.getProfile(_userId!);
      if (!_mounted) return;
      debugPrint('Loaded profile: $profile');
      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _nameController.text = profile.name;
          _emailController.text = profile.email;
          _locationController.text = profile.location;
          _cuisinePreferences.clear();
          _cuisinePreferences.addAll(profile.cuisinePreferences);
          _budgetValue = profile.budget;
          _dietaryRestrictions = profile.dietaryRestrictions;
          _notificationsEnabled = profile.notificationsEnabled;
          _darkModeEnabled = profile.darkModeEnabled;
          _avatarUrl = profile.avatarUrl;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (_mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (_mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadDeliveryProfile() async {
    if (_userId == null) return;
    setState(() => _isLoading = true);

    try {
      final profile = await _authService.getDeliveryProfile(_userId!);
      if (!_mounted) return;
      debugPrint('Loaded delivery profile: $profile');

      if (profile != null) {
        setState(() {
          _deliveryProfile = profile;
          _nameController.text = profile.name;
          _emailController.text = profile.email;
          _phoneController.text = profile.phoneNumber;
          _vehicleController.text = profile.vehicleType;
          _avatarUrl = profile.avatarUrl;
        });
      }
    } catch (e) {
      debugPrint('Error loading delivery profile: $e');
      if (_mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load delivery profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (_mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadOwnerProfile() async {
    if (_userId == null) return;
    setState(() => _isLoading = true);

    try {
      final profile = await _authService.getOwnerProfile(_userId!);
      if (!_mounted) return;
      debugPrint('Loaded owner profile: $profile');

      if (profile != null) {
        setState(() {
          _ownerProfile = profile;
          _nameController.text = profile.name;
          _emailController.text = profile.email;
          _restaurantNameController.text = profile.restaurantName;
          _restaurantAddressController.text = profile.restaurantAddress;
          _cuisineTypes.clear();
          _cuisineTypes.addAll(profile.cuisineTypes);
          _avatarUrl = profile.avatarUrl;
        });
      }
    } catch (e) {
      debugPrint('Error loading owner profile: $e');
      if (_mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load owner profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (_mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    bool success = false;

    if (_userProfile != null) {
      final updatedProfile = UserProfile(
        id: _userProfile!.id,
        email: _emailController.text,
        name: _nameController.text,
        location: _locationController.text,
        cuisinePreferences: _cuisinePreferences,
        budget: _budgetValue,
        dietaryRestrictions: _dietaryRestrictions,
        notificationsEnabled: _notificationsEnabled,
        darkModeEnabled: _darkModeEnabled,
        avatarUrl: _avatarUrl,
      );
      success = await _authService.updateProfile(updatedProfile);
    } else if (_ownerProfile != null) {
      final updatedOwner = OwnerProfile(
        id: _ownerProfile!.id,
        email: _emailController.text,
        name: _nameController.text,
        restaurantName: _restaurantNameController.text,
        restaurantAddress: _restaurantAddressController.text,
        cuisineTypes: _cuisineTypes,
        avatarUrl: _avatarUrl,
      );
      success = await _authService.updateOwnerProfile(updatedOwner);
    } else if (_deliveryProfile != null) {
      final updatedDelivery = DeliveryProfile(
        id: _deliveryProfile!.id,
        email: _emailController.text,
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        vehicleType: _vehicleController.text,
        avatarUrl: _avatarUrl,
      );
      success = await _authService.updateDeliveryProfile(updatedDelivery);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Profile updated successfully' : 'Failed to update profile',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  final List<String> _allCuisines = [
    'Tunisian',
    'Italien',
    'Japonais',
    'Français',
    'Mexicain',
    'Indien',
    'Chinois',
  ];
  List<String> _cuisinePreferences = [];
  List<String> _cuisineTypes = [];

  @override
  void dispose() {
    _mounted = false;
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _vehicleController.dispose();
    _restaurantNameController.dispose();
    _restaurantAddressController.dispose();
    super.dispose();
  }

  void _removeCuisine(String cuisine) {
    setState(() {
      if (_role == 'owner') {
        _cuisineTypes.remove(cuisine);
      } else {
        _cuisinePreferences.remove(cuisine);
      }
    });
  }

  void _showAddCuisineDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final tempSelected = _role == 'owner'
            ? List<String>.from(_cuisineTypes)
            : List<String>.from(_cuisinePreferences);
        String searchQuery = '';

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final filteredCuisines = _allCuisines.where((cuisine) {
              return cuisine.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Sélectionnez vos cuisines',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Rechercher une cuisine...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setStateDialog(() {
                                      searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setStateDialog(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                    if (tempSelected.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${tempSelected.length} cuisine${tempSelected.length > 1 ? 's' : ''} sélectionnée${tempSelected.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (filteredCuisines.isEmpty)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune cuisine trouvée',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredCuisines.length,
                          itemBuilder: (context, index) {
                            final cuisine = filteredCuisines[index];
                            final selected = tempSelected.contains(cuisine);

                            return Card(
                              elevation: 0,
                              margin: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: selected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade300,
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: CheckboxListTile(
                                value: selected,
                                title: Text(
                                  cuisine,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                activeColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onChanged: (v) {
                                  setStateDialog(() {
                                    if (v == true) {
                                      tempSelected.add(cuisine);
                                    } else {
                                      tempSelected.remove(cuisine);
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Annuler',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_role == 'owner') {
                        _cuisineTypes = tempSelected;
                      } else {
                        _cuisinePreferences = tempSelected;
                      }
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Valider', style: TextStyle(fontSize: 16)),
                ),
              ],
              actionsPadding: const EdgeInsets.all(16),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    switch (_role) {
      case 'delivery':
        return Scaffold(body: _buildDeliveryInfoCard());
      case 'owner':
        return Scaffold(body: _buildRestaurantInfoCard());
      default:
        return Container(
          color: const Color(0xFFF5F5F5),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    _buildPersonalInfoCard(),
                    const SizedBox(height: 16),
                    _buildCulinaryPreferencesCard(),
                    const SizedBox(height: 16),
                    _buildSettingsCard(),
                    const SizedBox(height: 16),
                    _buildActionButtons(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  String _displayInitials() {
    String name = '';
    if (_userProfile != null) {
      name = _userProfile!.name;
    } else if (_deliveryProfile != null) {
      name = _deliveryProfile!.name;
    } else if (_ownerProfile != null) {
      name = _ownerProfile!.name;
    }

    name = name.trim();
    if (name.isEmpty) return '??';
    final parts = name.split(RegExp(r'\s+'));
    final first = parts.first;
    if (first.length >= 2) return first.substring(0, 2).toUpperCase();
    return first.substring(0, 1).toUpperCase();
  }

  ImageProvider<Object>? _avatarImageProvider() {
    String? avatar;

    if (_userProfile?.avatarUrl != null) {
      avatar = _userProfile?.avatarUrl;
    } else if (_deliveryProfile?.avatarUrl != null) {
      avatar = _deliveryProfile?.avatarUrl;
    } else if (_ownerProfile?.avatarUrl != null) {
      avatar = _ownerProfile?.avatarUrl;
    }

    if (avatar == null || avatar.trim().isEmpty) return null;
    if (avatar.startsWith('/')) {
      return NetworkImage('${AuthService.baseUrl}$avatar');
    }
    return NetworkImage(avatar);
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_userId == null) return;
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null) return;

    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);
    final dataUri = 'data:image/png;base64,$base64Image';
    String? uploadedUrl;

    if (_role == 'user') {
      uploadedUrl = await _authService.uploadAvatar(_userId!, dataUri);
    } else if (_role == 'owner') {
      uploadedUrl = await _authService.uploadOwnerAvatar(_userId!, dataUri);
    } else if (_role == 'delivery') {
      uploadedUrl = await _authService.uploadDeliveryAvatar(_userId!, dataUri);
    }

    if (uploadedUrl != null) {
      setState(() {
        if (_userProfile != null) {
          _userProfile = UserProfile(
            id: _userProfile!.id,
            email: _userProfile!.email,
            name: _userProfile!.name,
            location: _userProfile!.location,
            cuisinePreferences: _userProfile!.cuisinePreferences,
            budget: _userProfile!.budget,
            dietaryRestrictions: _userProfile!.dietaryRestrictions,
            notificationsEnabled: _userProfile!.notificationsEnabled,
            darkModeEnabled: _userProfile!.darkModeEnabled,
            avatarUrl: uploadedUrl,
          );
        } else if (_deliveryProfile != null) {
          _deliveryProfile = DeliveryProfile(
            id: _deliveryProfile!.id,
            email: _deliveryProfile!.email,
            name: _deliveryProfile!.name,
            phoneNumber: _deliveryProfile!.phoneNumber,
            vehicleType: _deliveryProfile!.vehicleType,
            avatarUrl: uploadedUrl,
          );
        } else if (_ownerProfile != null) {
          _ownerProfile = OwnerProfile(
            id: _ownerProfile!.id,
            email: _ownerProfile!.email,
            name: _ownerProfile!.name,
            restaurantName: _ownerProfile!.restaurantName,
            restaurantAddress: _ownerProfile!.restaurantAddress,
            cuisineTypes: _ownerProfile!.cuisineTypes,
            avatarUrl: uploadedUrl,
          );
        }
        _avatarUrl = uploadedUrl;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar uploaded successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload avatar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () => _pickAndUploadAvatar(),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: _avatarImageProvider(),
                      child: _avatarImageProvider() == null
                          ? Text(
                              _displayInitials(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: () => _pickAndUploadAvatar(),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _userProfile?.name ?? 'Loading...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _userProfile?.email ?? 'Loading...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
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

  Widget _buildPersonalInfoCard() {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations personnelles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Nom complet',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.mail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _locationController,
              label: 'Localisation',
              icon: Icons.location_on,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
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
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCulinaryPreferencesCard() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Préférences culinaires',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Types de cuisine préférés',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._cuisinePreferences.map(
                (cuisine) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3B82F6).withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        cuisine,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _removeCuisine(cuisine),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: _showAddCuisineDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+ Ajouter',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Budget moyen par repas',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              Text(
                '${_budgetValue.toInt()}€',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.grey[600], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF3B82F6),
                    inactiveTrackColor: Colors.grey[300],
                    thumbColor: const Color(0xFF3B82F6),
                    overlayColor: const Color(0xFF3B82F6).withOpacity(0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _budgetValue,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    onChanged: (value) {
                      setState(() => _budgetValue = value);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Restrictions alimentaires',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Végétarien, sans gluten, etc.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _dietaryRestrictions,
                onChanged: (value) {
                  setState(() => _dietaryRestrictions = value);
                },
                activeColor: const Color(0xFF3B82F6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paramètres',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingRow(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Rappels de réservation',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          const SizedBox(height: 16),
          _buildSettingRow(
            icon: Icons.dark_mode,
            title: 'Mode sombre',
            subtitle: 'Thème de l\'application',
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() => _darkModeEnabled = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF3B82F6),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              _saveChanges();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFF3B82F6).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Sauvegarder les modifications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout, size: 20),
            label: const Text(
              'Se déconnecter',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== DELIVERY PROFILE ====================
  Widget _buildDeliveryInfoCard() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          _buildDeliveryHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                _buildDeliveryPersonalInfoCard(),
                const SizedBox(height: 16),
                _buildDeliveryContactCard(),
                const SizedBox(height: 16),
                _buildDeliverySettingsCard(),
                const SizedBox(height: 16),
                _buildDeliveryActionButtons(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryHeader() {
    String displayName = _deliveryProfile?.name ?? 'Chargement...';
    String displayEmail = _deliveryProfile?.email ?? '';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () => _pickAndUploadAvatar(),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: _avatarImageProvider(),
                      child: _avatarImageProvider() == null
                          ? Text(
                              _displayInitials(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: () => _pickAndUploadAvatar(),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      displayEmail,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delivery_dining,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Livreur actif',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

  Widget _buildDeliveryPersonalInfoCard() {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations personnelles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Nom complet',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.mail,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryContactCard() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations de livraison',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Numéro de téléphone',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _vehicleController,
            label: 'Type de véhicule',
            icon: Icons.directions_car,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySettingsCard() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Préférences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingRow(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Nouvelles commandes et mises à jour',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              _saveChanges();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFF3B82F6).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Sauvegarder les modifications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout, size: 20),
            label: const Text(
              'Se déconnecter',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== OWNER/RESTAURANT PROFILE ====================
  Widget _buildRestaurantInfoCard() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          _buildRestaurantHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                _buildRestaurantPersonalInfoCard(),
                const SizedBox(height: 16),
                _buildRestaurantDetailsCard(),
                const SizedBox(height: 16),
                _buildRestaurantCuisinesCard(),
                const SizedBox(height: 16),
                _buildRestaurantSettingsCard(),
                const SizedBox(height: 16),
                _buildRestaurantActionButtons(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantHeader() {
    String displayName = _ownerProfile?.name ?? 'Chargement...';
    String displayEmail = _ownerProfile?.email ?? '';
    String restaurantName = _ownerProfile?.restaurantName ?? 'Mon Restaurant';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  GestureDetector(
                    onTap: () => _pickAndUploadAvatar(),
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: _avatarImageProvider(),
                      child: _avatarImageProvider() == null
                          ? Text(
                              _displayInitials(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: InkWell(
                      onTap: () => _pickAndUploadAvatar(),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.edit,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayEmail,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.restaurant,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            restaurantName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

  Widget _buildRestaurantPersonalInfoCard() {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Container(
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations personnelles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              label: 'Nom du propriétaire',
              icon: Icons.person,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'Email de contact',
              icon: Icons.mail,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantDetailsCard() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations du restaurant',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _restaurantNameController,
            label: 'Nom du restaurant',
            icon: Icons.restaurant_menu,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _restaurantAddressController,
            label: 'Adresse du restaurant',
            icon: Icons.location_on,
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCuisinesCard() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Types de cuisine',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: _showAddCuisineDialog,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_cuisineTypes.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.restaurant,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aucun type de cuisine ajouté',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: _showAddCuisineDialog,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Ajouter maintenant'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _cuisineTypes
                  .map(
                    (cuisine) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cuisine,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _removeCuisine(cuisine),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildRestaurantSettingsCard() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paramètres',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSettingRow(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Nouvelles commandes et messages',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              _saveChanges();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFF10B981).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Sauvegarder les modifications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout, size: 20),
            label: const Text(
              'Se déconnecter',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
