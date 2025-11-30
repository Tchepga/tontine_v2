import 'package:flutter/material.dart';

/// Modèle représentant un pays avec son code ISO et son nom
class Country {
  final String code;
  final String name;
  final String flag;

  const Country({
    required this.code,
    required this.name,
    required this.flag,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// Liste des pays disponibles (Europe, États-Unis, Afrique Centrale et Afrique de l'Est)
class CountryData {
  static const List<Country> countries = [
    // États-Unis
    Country(code: 'US', name: 'États-Unis', flag: '🇺🇸'),

    // Europe
    Country(code: 'DE', name: 'Allemagne', flag: '🇩🇪'),
    Country(code: 'AD', name: 'Andorre', flag: '🇦🇩'),
    Country(code: 'AT', name: 'Autriche', flag: '🇦🇹'),
    Country(code: 'BE', name: 'Belgique', flag: '🇧🇪'),
    Country(code: 'BG', name: 'Bulgarie', flag: '🇧🇬'),
    Country(code: 'CY', name: 'Chypre', flag: '🇨🇾'),
    Country(code: 'HR', name: 'Croatie', flag: '🇭🇷'),
    Country(code: 'DK', name: 'Danemark', flag: '🇩🇰'),
    Country(code: 'ES', name: 'Espagne', flag: '🇪🇸'),
    Country(code: 'EE', name: 'Estonie', flag: '🇪🇪'),
    Country(code: 'FI', name: 'Finlande', flag: '🇫🇮'),
    Country(code: 'FR', name: 'France', flag: '🇫🇷'),
    Country(code: 'GR', name: 'Grèce', flag: '🇬🇷'),
    Country(code: 'HU', name: 'Hongrie', flag: '🇭🇺'),
    Country(code: 'IE', name: 'Irlande', flag: '🇮🇪'),
    Country(code: 'IS', name: 'Islande', flag: '🇮🇸'),
    Country(code: 'IT', name: 'Italie', flag: '🇮🇹'),
    Country(code: 'LV', name: 'Lettonie', flag: '🇱🇻'),
    Country(code: 'LI', name: 'Liechtenstein', flag: '🇱🇮'),
    Country(code: 'LT', name: 'Lituanie', flag: '🇱🇹'),
    Country(code: 'LU', name: 'Luxembourg', flag: '🇱🇺'),
    Country(code: 'MK', name: 'Macédoine du Nord', flag: '🇲🇰'),
    Country(code: 'MT', name: 'Malte', flag: '🇲🇹'),
    Country(code: 'MD', name: 'Moldavie', flag: '🇲🇩'),
    Country(code: 'MC', name: 'Monaco', flag: '🇲🇨'),
    Country(code: 'ME', name: 'Monténégro', flag: '🇲🇪'),
    Country(code: 'NO', name: 'Norvège', flag: '🇳🇴'),
    Country(code: 'NL', name: 'Pays-Bas', flag: '🇳🇱'),
    Country(code: 'PL', name: 'Pologne', flag: '🇵🇱'),
    Country(code: 'PT', name: 'Portugal', flag: '🇵🇹'),
    Country(code: 'RO', name: 'Roumanie', flag: '🇷🇴'),
    Country(code: 'GB', name: 'Royaume-Uni', flag: '🇬🇧'),
    Country(code: 'RS', name: 'Serbie', flag: '🇷🇸'),
    Country(code: 'SK', name: 'Slovaquie', flag: '🇸🇰'),
    Country(code: 'SI', name: 'Slovénie', flag: '🇸🇮'),
    Country(code: 'SE', name: 'Suède', flag: '🇸🇪'),
    Country(code: 'CH', name: 'Suisse', flag: '🇨🇭'),
    Country(code: 'CZ', name: 'Tchéquie', flag: '🇨🇿'),
    Country(code: 'UA', name: 'Ukraine', flag: '🇺🇦'),

    // Afrique Centrale
    Country(code: 'AO', name: 'Angola', flag: '🇦🇴'),
    Country(code: 'CM', name: 'Cameroun', flag: '🇨🇲'),
    Country(code: 'CF', name: 'Centrafrique', flag: '🇨🇫'),
    Country(code: 'CG', name: 'Congo', flag: '🇨🇬'),
    Country(code: 'CD', name: 'Congo (RDC)', flag: '🇨🇩'),
    Country(code: 'GA', name: 'Gabon', flag: '🇬🇦'),
    Country(code: 'GQ', name: 'Guinée Équatoriale', flag: '🇬🇶'),
    Country(code: 'ST', name: 'São Tomé-et-Príncipe', flag: '🇸🇹'),
    Country(code: 'TD', name: 'Tchad', flag: '🇹🇩'),
    Country(code: 'NG', name: 'Nigeria', flag: '🇳🇬'),

    // Afrique de l'Est
    Country(code: 'BI', name: 'Burundi', flag: '🇧🇮'),
    Country(code: 'KM', name: 'Comores', flag: '🇰🇲'),
    Country(code: 'DJ', name: 'Djibouti', flag: '🇩🇯'),
    Country(code: 'ER', name: 'Érythrée', flag: '🇪🇷'),
    Country(code: 'ET', name: 'Éthiopie', flag: '🇪🇹'),
    Country(code: 'KE', name: 'Kenya', flag: '🇰🇪'),
    Country(code: 'MG', name: 'Madagascar', flag: '🇲🇬'),
    Country(code: 'MW', name: 'Malawi', flag: '🇲🇼'),
    Country(code: 'MU', name: 'Maurice', flag: '🇲🇺'),
    Country(code: 'MZ', name: 'Mozambique', flag: '🇲🇿'),
    Country(code: 'UG', name: 'Ouganda', flag: '🇺🇬'),
    Country(code: 'RW', name: 'Rwanda', flag: '🇷🇼'),
    Country(code: 'SC', name: 'Seychelles', flag: '🇸🇨'),
    Country(code: 'SO', name: 'Somalie', flag: '🇸🇴'),
    Country(code: 'SD', name: 'Soudan', flag: '🇸🇩'),
    Country(code: 'SS', name: 'Soudan du Sud', flag: '🇸🇸'),
    Country(code: 'TZ', name: 'Tanzanie', flag: '🇹🇿'),
    Country(code: 'ZM', name: 'Zambie', flag: '🇿🇲'),
    Country(code: 'ZW', name: 'Zimbabwe', flag: '🇿🇼'),
    Country(code: 'ML', name: 'Mali', flag: '🇲🇱'),
    Country(code: 'BF', name: 'Burkina Faso', flag: '🇧🇫'),
    Country(code: 'CI', name: 'Côte d\'Ivoire', flag: '🇨🇮'),
    Country(code: 'GN', name: 'Guinée', flag: '🇬🇳'),
    Country(code: 'NE', name: 'Niger', flag: '🇳🇪'),
    Country(code: 'SN', name: 'Sénégal', flag: '🇸🇳'),
    Country(code: 'GH', name: 'Ghana', flag: '🇬🇭'),

    // Afrique du Sud
    Country(code: 'ZA', name: 'Afrique du Sud', flag: '🇿🇦'),

    // Afrique du Nord
    Country(code: 'TN', name: 'Tunisie', flag: '🇹🇳'),
    Country(code: 'MA', name: 'Maroc', flag: '🇲🇦'),
    Country(code: 'DZ', name: 'Algérie', flag: '🇩🇿'),
    Country(code: 'EG', name: 'Égypte', flag: '🇪🇬'),
    Country(code: 'LY', name: 'Libye', flag: '🇱🇾'),
    Country(code: 'MR', name: 'Mauritanie', flag: '🇲🇷'),
  ];

  /// Trouve un pays par son code ISO
  static Country? findByCode(String code) {
    try {
      return countries.firstWhere(
        (country) => country.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Widget réutilisable pour la sélection de pays
class CountryDropdown extends StatefulWidget {
  /// Code du pays initialement sélectionné (ex: 'FR')
  final String? initialCountryCode;

  /// Callback appelé quand un pays est sélectionné
  final ValueChanged<Country>? onChanged;

  /// Label affiché au-dessus du dropdown
  final String labelText;

  /// Texte d'indication quand aucun pays n'est sélectionné
  final String? hintText;

  /// Validateur personnalisé
  final String? Function(Country?)? validator;

  /// Indique si le champ est obligatoire
  final bool isRequired;

  /// Indique si le dropdown est activé
  final bool enabled;

  /// Décoration personnalisée (optionnel)
  final InputDecoration? decoration;

  const CountryDropdown({
    super.key,
    this.initialCountryCode,
    this.onChanged,
    this.labelText = 'Pays',
    this.hintText,
    this.validator,
    this.isRequired = false,
    this.enabled = true,
    this.decoration,
  });

  @override
  State<CountryDropdown> createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  Country? _selectedCountry;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _displayController = TextEditingController();
  List<Country> _filteredCountries = CountryData.countries;

  @override
  void initState() {
    super.initState();
    if (widget.initialCountryCode != null) {
      _selectedCountry = CountryData.findByCode(widget.initialCountryCode!);
      _updateDisplayText();
    }
  }

  @override
  void didUpdateWidget(CountryDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCountryCode != oldWidget.initialCountryCode) {
      setState(() {
        _selectedCountry = widget.initialCountryCode != null
            ? CountryData.findByCode(widget.initialCountryCode!)
            : null;
        _updateDisplayText();
      });
    }
  }

  void _updateDisplayText() {
    if (_selectedCountry != null) {
      _displayController.text =
          '${_selectedCountry!.flag}  ${_selectedCountry!.name}';
    } else {
      _displayController.clear();
    }
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = CountryData.countries;
      } else {
        _filteredCountries = CountryData.countries
            .where((country) =>
                country.name.toLowerCase().contains(query.toLowerCase()) ||
                country.code.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showCountryPicker() {
    _searchController.clear();
    _filteredCountries = CountryData.countries;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    // Barre de poignée
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Titre
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Sélectionner un pays',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    // Champ de recherche
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher un pays...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          _filterCountries(value);
                          setModalState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Liste des pays
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: _filteredCountries.length,
                        itemBuilder: (context, index) {
                          final country = _filteredCountries[index];
                          final isSelected =
                              _selectedCountry?.code == country.code;
                          return ListTile(
                            leading: Text(
                              country.flag,
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(country.name),
                            subtitle: Text(country.code),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).primaryColor,
                                  )
                                : null,
                            selected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedCountry = country;
                                _updateDisplayText();
                              });
                              widget.onChanged?.call(country);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _displayController,
      readOnly: true,
      enabled: widget.enabled,
      onTap: widget.enabled ? _showCountryPicker : null,
      decoration: widget.decoration ??
          InputDecoration(
            labelText:
                widget.isRequired ? '${widget.labelText}*' : widget.labelText,
            hintText: widget.hintText ?? 'Sélectionner un pays',
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
      validator: (_) {
        if (widget.validator != null) {
          return widget.validator!(_selectedCountry);
        }
        if (widget.isRequired && _selectedCountry == null) {
          return 'Veuillez sélectionner un pays';
        }
        return null;
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _displayController.dispose();
    super.dispose();
  }
}
