import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Country {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });
}

class PhoneInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(Country)? onCountryChanged;
  final Country? initialCountry;

  const PhoneInputField({
    Key? key,
    required this.controller,
    this.validator,
    this.onCountryChanged,
    this.initialCountry,
  }) : super(key: key);

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  // Static list of popular countries
  static const List<Country> countries = [
    Country(name: 'France', code: 'FR', dialCode: '+33', flag: '🇫🇷'),
    Country(name: 'United States', code: 'US', dialCode: '+1', flag: '🇺🇸'),
    Country(name: 'United Kingdom', code: 'GB', dialCode: '+44', flag: '🇬🇧'),
    Country(name: 'Germany', code: 'DE', dialCode: '+49', flag: '🇩🇪'),
    Country(name: 'Spain', code: 'ES', dialCode: '+34', flag: '🇪🇸'),
    Country(name: 'Italy', code: 'IT', dialCode: '+39', flag: '🇮🇹'),
    Country(name: 'Belgium', code: 'BE', dialCode: '+32', flag: '🇧🇪'),
    Country(name: 'Switzerland', code: 'CH', dialCode: '+41', flag: '🇨🇭'),
    Country(name: 'Canada', code: 'CA', dialCode: '+1', flag: '🇨🇦'),
    Country(name: 'Netherlands', code: 'NL', dialCode: '+31', flag: '🇳🇱'),
    Country(name: 'Portugal', code: 'PT', dialCode: '+351', flag: '🇵🇹'),
    Country(name: 'Morocco', code: 'MA', dialCode: '+212', flag: '🇲🇦'),
    Country(name: 'Algeria', code: 'DZ', dialCode: '+213', flag: '🇩🇿'),
    Country(name: 'Tunisia', code: 'TN', dialCode: '+216', flag: '🇹🇳'),
    Country(name: 'Senegal', code: 'SN', dialCode: '+221', flag: '🇸🇳'),
    Country(name: 'Ivory Coast', code: 'CI', dialCode: '+225', flag: '🇨🇮'),
  ];

  late Country _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry ?? countries[0]; // Default to France
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildCountryPickerModal(),
    );
  }

  Widget _buildCountryPickerModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
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
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Sélectionner un pays',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Country list
          Expanded(
            child: ListView.builder(
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                final isSelected = country.code == _selectedCountry.code;
                return ListTile(
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 28),
                  ),
                  title: Text(
                    country.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1F2937),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        country.dialCode,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF10B981),
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _selectedCountry = country;
                    });
                    widget.onCountryChanged?.call(country);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le numéro de téléphone est requis';
    }
    
    // Remove spaces and other formatting characters
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Check if it contains only digits
    if (!RegExp(r'^\d+$').hasMatch(cleanNumber)) {
      return 'Le numéro doit contenir uniquement des chiffres';
    }
    
    // Minimum length check (most countries have at least 6 digits)
    if (cleanNumber.length < 6) {
      return 'Numéro de téléphone trop court';
    }
    
    // Maximum length check (no country has more than 15 digits)
    if (cleanNumber.length > 15) {
      return 'Numéro de téléphone trop long';
    }
    
    // Custom validator from parent
    if (widget.validator != null) {
      return widget.validator!(value);
    }
    
    return null;
  }

  String getFullPhoneNumber() {
    final number = widget.controller.text.trim();
    if (number.isEmpty) return '';
    return '${_selectedCountry.dialCode} $number';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country selector button
            InkWell(
              onTap: _showCountryPicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedCountry.dialCode,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Phone number input
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                decoration: InputDecoration(
                  hintText: 'Ex: 612345678',
                  prefixIcon: const Icon(Icons.phone, size: 20),
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
                      color: Color(0xFF10B981),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: _validatePhoneNumber,
              ),
            ),
          ],
        ),
        // Info text showing complete number
        if (widget.controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Numéro complet: ${_selectedCountry.dialCode} ${widget.controller.text}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
