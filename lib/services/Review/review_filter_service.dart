class ReviewFilterService {
  static final Map<String, List<String>> _bannedPatterns = {
    'insultes': [
      'connard', 'salope', 'enculé', 'fils de pute', 'batard', 'merde',
      'putain', 'nique', 'ta mère', 'fuck', 'shit', 'bitch', 'asshole',
      'douchebag', 'idiot', 'stupide', 'imbécile', 'crétin', 'con', 'connasse'
    ],
    'racisme': [
      'nègre', 'bicot', 'bougnoule', 'youpin', 'sale noir', 'sale arabe',
      'sale juif', 'race inférieure', 'sale blanc', 'sale musulman'
    ],
    'sexisme': [
      'femme de ménage', 'va faire la cuisine', 't\'es une fille',
      'sois belle et tais-toi', 'faible comme une femme', 'bonne à rien'
    ],
    'spam': [
      'acheter', 'pas cher', 'promotion', 'cliquez ici', 'http://', 'www.',
      'gratuit', 'offre limitée', 'contactez-moi', 'whatsapp', 'télégramme',
      'appelez-moi', 'visitez mon site'
    ],
    'violence': [
      'je vais te tuer', 'je te casse la gueule', 'mort à', 'suicide-toi',
      'crève', 'ta race', 'sale race', 'je te déteste', 'va te faire voir'
    ],
    'langage vulgaire': [
      'bite', 'cul', 'chatte', 'seins', 'sexe', 'pénis', 'vagin',
      'baise', 'baisé', 'nudité', 'porno', 'pornographique'
    ],
  };

  static FilterResult checkReview(String text) {
    final lowerText = text.toLowerCase();
    final List<String> foundCategories = [];
    final List<String> foundWords = [];

    for (final entry in _bannedPatterns.entries) {
      for (final word in entry.value) {
        if (lowerText.contains(word.toLowerCase())) {
          if (!foundCategories.contains(entry.key)) {
            foundCategories.add(entry.key);
          }
          foundWords.add(word);
        }
      }
    }

    return FilterResult(
      isValid: foundCategories.isEmpty,
      bannedCategories: foundCategories,
      foundWords: foundWords,
      filteredText: _applyFilter(text),
    );
  }

  // CORRECTION : Cette méthode s'appelle _applyFilter, pas filterText
  static String _applyFilter(String text) {
    String filteredText = text;

    for (final category in _bannedPatterns.values) {
      for (final word in category) {
        final regex = RegExp(_escapeRegex(word), caseSensitive: false);
        filteredText = filteredText.replaceAll(regex, '***');
      }
    }

    return filteredText;
  }

  // AJOUT : Méthode publique pour filtrer le texte
  static String filterText(String text) {
    return _applyFilter(text);
  }

  static String _escapeRegex(String text) {
    return text.replaceAllMapped(RegExp(r'[.*+?^${}()|[\]\\]'), (match) {
      return '\\${match.group(0)}';
    });
  }

  static bool containsBannedWords(String text) {
    return !checkReview(text).isValid;
  }
}

class FilterResult {
  final bool isValid;
  final List<String> bannedCategories;
  final List<String> foundWords;
  final String filteredText;

  FilterResult({
    required this.isValid,
    required this.bannedCategories,
    required this.foundWords,
    required this.filteredText,
  });
}
