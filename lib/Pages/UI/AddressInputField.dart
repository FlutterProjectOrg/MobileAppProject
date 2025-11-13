import 'package:flutter/material.dart';

class CountryData {
  final String name;
  final String code;
  final String flag;
  final List<String> states;

  const CountryData({
    required this.name,
    required this.code,
    required this.flag,
    required this.states,
  });
}

class AddressInputField extends StatefulWidget {
  final TextEditingController addressController;
  final String? Function(String?)? validator;
  final void Function(CountryData)? onCountryChanged;
  final void Function(String)? onStateChanged;
  final CountryData? initialCountry;
  final String? initialState;

  const AddressInputField({
    Key? key,
    required this.addressController,
    this.validator,
    this.onCountryChanged,
    this.onStateChanged,
    this.initialCountry,
    this.initialState,
  }) : super(key: key);

  @override
  State<AddressInputField> createState() => _AddressInputFieldState();
}

class _AddressInputFieldState extends State<AddressInputField> {
  // Static list of countries with their states/regions
  static const List<CountryData> countries = [
    CountryData(
      name: 'France',
      code: 'FR',
      flag: '🇫🇷',
      states: [
        'Île-de-France',
        'Provence-Alpes-Côte d\'Azur',
        'Auvergne-Rhône-Alpes',
        'Nouvelle-Aquitaine',
        'Occitanie',
        'Hauts-de-France',
        'Bretagne',
        'Grand Est',
        'Pays de la Loire',
        'Normandie',
        'Bourgogne-Franche-Comté',
        'Centre-Val de Loire',
        'Corse',
      ],
    ),
    CountryData(
      name: 'United States',
      code: 'US',
      flag: '🇺🇸',
      states: [
        'California',
        'Texas',
        'Florida',
        'New York',
        'Pennsylvania',
        'Illinois',
        'Ohio',
        'Georgia',
        'North Carolina',
        'Michigan',
        'New Jersey',
        'Virginia',
        'Washington',
        'Arizona',
        'Massachusetts',
        'Tennessee',
        'Indiana',
        'Missouri',
        'Maryland',
        'Wisconsin',
      ],
    ),
    CountryData(
      name: 'United Kingdom',
      code: 'GB',
      flag: '🇬🇧',
      states: [
        'England',
        'Scotland',
        'Wales',
        'Northern Ireland',
        'Greater London',
        'West Midlands',
        'Greater Manchester',
        'West Yorkshire',
        'South Yorkshire',
        'Merseyside',
      ],
    ),
    CountryData(
      name: 'Germany',
      code: 'DE',
      flag: '🇩🇪',
      states: [
        'Bavaria',
        'Baden-Württemberg',
        'North Rhine-Westphalia',
        'Hesse',
        'Saxony',
        'Lower Saxony',
        'Rhineland-Palatinate',
        'Berlin',
        'Hamburg',
        'Schleswig-Holstein',
        'Brandenburg',
        'Saxony-Anhalt',
        'Thuringia',
        'Mecklenburg-Vorpommern',
        'Bremen',
        'Saarland',
      ],
    ),
    CountryData(
      name: 'Spain',
      code: 'ES',
      flag: '🇪🇸',
      states: [
        'Madrid',
        'Catalonia',
        'Andalusia',
        'Valencia',
        'Galicia',
        'Castile and León',
        'Basque Country',
        'Canary Islands',
        'Castilla-La Mancha',
        'Murcia',
        'Aragon',
        'Balearic Islands',
        'Extremadura',
        'Asturias',
        'Navarre',
        'Cantabria',
        'La Rioja',
      ],
    ),
    CountryData(
      name: 'Italy',
      code: 'IT',
      flag: '🇮🇹',
      states: [
        'Lazio',
        'Lombardy',
        'Campania',
        'Sicily',
        'Veneto',
        'Piedmont',
        'Emilia-Romagna',
        'Apulia',
        'Tuscany',
        'Calabria',
        'Sardinia',
        'Liguria',
        'Marche',
        'Abruzzo',
        'Friuli-Venezia Giulia',
        'Trentino-Alto Adige',
        'Umbria',
        'Basilicata',
        'Molise',
        'Valle d\'Aosta',
      ],
    ),
    CountryData(
      name: 'Canada',
      code: 'CA',
      flag: '🇨🇦',
      states: [
        'Ontario',
        'Quebec',
        'British Columbia',
        'Alberta',
        'Manitoba',
        'Saskatchewan',
        'Nova Scotia',
        'New Brunswick',
        'Newfoundland and Labrador',
        'Prince Edward Island',
        'Northwest Territories',
        'Yukon',
        'Nunavut',
      ],
    ),
    CountryData(
      name: 'Morocco',
      code: 'MA',
      flag: '🇲🇦',
      states: [
        'Casablanca-Settat',
        'Rabat-Salé-Kénitra',
        'Marrakesh-Safi',
        'Fès-Meknès',
        'Tanger-Tétouan-Al Hoceïma',
        'Souss-Massa',
        'Béni Mellal-Khénifra',
        'Oriental',
        'Drâa-Tafilalet',
        'Guelmim-Oued Noun',
        'Laâyoune-Sakia El Hamra',
        'Dakhla-Oued Ed-Dahab',
      ],
    ),
    CountryData(
      name: 'Tunisia',
      code: 'TN',
      flag: '🇹🇳',
      states: [
        'Tunis',
        'Ariana',
        'Ben Arous',
        'Manouba',
        'Nabeul',
        'Zaghouan',
        'Bizerte',
        'Béja',
        'Jendouba',
        'Kef',
        'Siliana',
        'Sousse',
        'Monastir',
        'Mahdia',
        'Sfax',
        'Kairouan',
        'Kasserine',
        'Sidi Bouzid',
        'Gabès',
        'Medenine',
        'Tataouine',
        'Gafsa',
        'Tozeur',
        'Kebili',
      ],
    ),
  ];

  late CountryData _selectedCountry;
  String? _selectedState;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry ?? countries[0]; // Default to France
    _selectedState = widget.initialState;
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildCountryPickerModal(),
    );
  }

  void _showStatePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildStatePickerModal(),
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
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: Color(0xFF10B981),
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedCountry = country;
                      _selectedState = null; // Reset state when country changes
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

  Widget _buildStatePickerModal() {
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
                Text(
                  'Sélectionner une région',
                  style: const TextStyle(
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
          // State list
          Expanded(
            child: ListView.builder(
              itemCount: _selectedCountry.states.length,
              itemBuilder: (context, index) {
                final state = _selectedCountry.states[index];
                final isSelected = state == _selectedState;
                return ListTile(
                  leading: Icon(
                    Icons.location_city,
                    color: isSelected ? const Color(0xFF10B981) : Colors.grey[400],
                  ),
                  title: Text(
                    state,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1F2937),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: Color(0xFF10B981),
                          size: 20,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedState = state;
                    });
                    widget.onStateChanged?.call(state);
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

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'L\'adresse est requise';
    }
    if (value.trim().length < 5) {
      return 'L\'adresse doit être plus détaillée';
    }
    return widget.validator?.call(value);
  }

  String getFullAddress() {
    final address = widget.addressController.text.trim();
    if (address.isEmpty) return '';
    
    final parts = <String>[address];
    if (_selectedState != null) parts.add(_selectedState!);
    parts.add(_selectedCountry.name);
    
    return parts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country and State Row
        Row(
          children: [
            // Country selector
            Expanded(
              child: InkWell(
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
                    children: [
                      Text(
                        _selectedCountry.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedCountry.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // State selector
            Expanded(
              child: InkWell(
                onTap: _showStatePicker,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(
                      color: _selectedState == null
                          ? Colors.orange[300]!
                          : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_city,
                        color: _selectedState == null
                            ? Colors.orange[700]
                            : const Color(0xFF10B981),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedState ?? 'Région',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: _selectedState == null
                                ? FontWeight.normal
                                : FontWeight.w600,
                            color: _selectedState == null
                                ? Colors.grey[600]
                                : const Color(0xFF1F2937),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Address input
        TextFormField(
          controller: widget.addressController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ex: 123 Rue de Paris, 75001',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.home, size: 20),
            ),
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
          validator: _validateAddress,
        ),
        // Info text showing complete address
        if (widget.addressController.text.isNotEmpty && _selectedState != null)
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
                Expanded(
                  child: Text(
                    'Adresse complète: ${getFullAddress()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        // Warning if state not selected
        if (_selectedState == null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: Colors.orange[700],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Veuillez sélectionner une région/état',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
