import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mobile_app_project/services/Restaurant/RestaurantService.dart';
import 'package:mobile_app_project/services/Restaurant/DishService.dart';
import 'package:mobile_app_project/services/Review/ReviewService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  GenerativeModel? _model;
  ChatSession? _chatSession;
  bool _isInitialized = false;

  /// Initialize the Gemini model with API key
  Future<bool> initialize(String apiKey) async {
    try {
      if (apiKey.isEmpty) {
        debugPrint('❌ Gemini API key is empty');
        return false;
      }

      _model = GenerativeModel(
        model: 'gemini-pro',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
        safetySettings: [
          SafetySetting(
            HarmCategory.harassment,
            HarmBlockThreshold.medium,
          ),
          SafetySetting(
            HarmCategory.hateSpeech,
            HarmBlockThreshold.medium,
          ),
        ],
      );

      _isInitialized = true;
      debugPrint('✅ Gemini service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error initializing Gemini service: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Start a new chat session with context from database
  Future<void> startNewChat() async {
    if (!_isInitialized || _model == null) {
      throw Exception('Gemini service not initialized');
    }

    try {
      // Get all context data from database
      final contextData = await _getContextData();

      // Create initial system message with context
      final systemPrompt = _buildSystemPrompt(contextData);

      // Start chat session
      _chatSession = _model!.startChat(
        history: [
          Content.text(systemPrompt),
          Content.model([TextPart('Je comprends. Je suis votre assistant culinaire personnel pour FoodFinder. Je vais vous aider à trouver les meilleurs restaurants en utilisant notre base de données complète. Comment puis-je vous aider aujourd\'hui ?')]),
        ],
      );

      debugPrint('✅ New chat session started with context');
    } catch (e) {
      debugPrint('❌ Error starting chat session: $e');
      rethrow;
    }
  }

  /// Get context data from database
  Future<Map<String, dynamic>> _getContextData() async {
    try {
      // Get restaurants with ratings
      final restaurants = await ReviewService.instance.getRestaurantsWithRatings();

      // Get all dishes
      final allDishes = <Map<String, dynamic>>[];
      for (final restaurant in restaurants) {
        final dishes = await DishService.instance.getDishesByRestaurant(
          restaurant['id'] as int,
        );
        allDishes.addAll(dishes);
      }

      // Get user preferences if available
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      
      Map<String, dynamic>? userPreferences;
      if (userId != null) {
        // Get user's past reviews to understand preferences
        final userReviews = await ReviewService.instance.getUserReviews(userId);
        userPreferences = {
          'user_id': userId,
          'past_reviews': userReviews.length,
          'reviewed_restaurants': userReviews.map((r) => r['restaurant_name']).toList(),
        };
      }

      // Get top rated restaurants
      final topRated = await ReviewService.instance.getTopRatedRestaurants(limit: 5);

      return {
        'total_restaurants': restaurants.length,
        'restaurants': restaurants.map((r) => {
          'id': r['id'],
          'name': r['name'],
          'address': r['adresse'],
          'phone': r['phone'],
          'average_rating': r['average_rating'],
          'total_reviews': r['total_reviews'],
          'pictures': _parsePictures(r['pictures']),
        }).toList(),
        'total_dishes': allDishes.length,
        'dishes': allDishes.map((d) => {
          'id': d['id'],
          'name': d['name'],
          'category': d['category'],
          'restaurant_id': d['restaurant_id'],
          'price': d['price'],
        }).toList(),
        'top_rated_restaurants': topRated.map((r) => {
          'name': r['name'],
          'rating': r['average_rating'],
          'reviews': r['total_reviews'],
        }).toList(),
        'user_preferences': userPreferences,
      };
    } catch (e) {
      debugPrint('❌ Error getting context data: $e');
      return {
        'total_restaurants': 0,
        'restaurants': [],
        'total_dishes': 0,
        'dishes': [],
        'top_rated_restaurants': [],
      };
    }
  }

  /// Parse pictures JSON string
  List<String> _parsePictures(dynamic pictures) {
    try {
      if (pictures == null) return [];
      if (pictures is String) {
        final parsed = jsonDecode(pictures);
        return List<String>.from(parsed);
      }
      if (pictures is List) {
        return List<String>.from(pictures);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Build system prompt with context
  String _buildSystemPrompt(Map<String, dynamic> contextData) {
    final restaurantsCount = contextData['total_restaurants'] ?? 0;
    final dishesCount = contextData['total_dishes'] ?? 0;
    final restaurants = contextData['restaurants'] as List<dynamic>;
    final dishes = contextData['dishes'] as List<dynamic>;
    final topRated = contextData['top_rated_restaurants'] as List<dynamic>;

    // Build detailed restaurant information
    final restaurantInfo = StringBuffer();
    for (final restaurant in restaurants) {
      restaurantInfo.writeln('- ${restaurant['name']}:');
      restaurantInfo.writeln('  Adresse: ${restaurant['address']}');
      restaurantInfo.writeln('  Téléphone: ${restaurant['phone']}');
      restaurantInfo.writeln('  Note moyenne: ${(restaurant['average_rating'] as num).toStringAsFixed(1)}/5.0');
      restaurantInfo.writeln('  Nombre d\'avis: ${restaurant['total_reviews']}');
      
      // Add dishes for this restaurant
      final restaurantDishes = dishes.where((d) => d['restaurant_id'] == restaurant['id']).toList();
      if (restaurantDishes.isNotEmpty) {
        restaurantInfo.writeln('  Plats disponibles:');
        for (final dish in restaurantDishes.take(5)) {
          final price = dish['price'] != null ? '${(dish['price'] as num).toStringAsFixed(2)}€' : 'Prix non spécifié';
          restaurantInfo.writeln('    * ${dish['name']} (${dish['category']}) - $price');
        }
      }
      restaurantInfo.writeln();
    }

    // Build top rated section
    final topRatedInfo = StringBuffer();
    if (topRated.isNotEmpty) {
      topRatedInfo.writeln('\nRestaurants les mieux notés:');
      for (final restaurant in topRated) {
        topRatedInfo.writeln('- ${restaurant['name']}: ${(restaurant['rating'] as num).toStringAsFixed(1)}/5.0 (${restaurant['reviews']} avis)');
      }
    }

    return '''
Vous êtes un assistant culinaire intelligent pour l'application FoodFinder. Votre rôle est d'aider les utilisateurs à découvrir et choisir des restaurants en utilisant UNIQUEMENT les données de notre base de données.

RÈGLES IMPORTANTES:
1. Utilisez UNIQUEMENT les restaurants et plats listés ci-dessous
2. Ne mentionnez JAMAIS de restaurants qui ne sont pas dans la liste
3. Soyez précis avec les informations (notes, adresses, plats disponibles)
4. Si un utilisateur demande quelque chose qui n'existe pas dans notre base de données, suggérez les options les plus proches disponibles
5. Soyez conversationnel, amical et utile
6. Répondez toujours en français
7. Donnez des suggestions basées sur les notes et les avis
8. Quand vous recommandez un restaurant, mentionnez: nom, note, nombre d'avis, et quelques plats disponibles

BASE DE DONNÉES FOODFINDER:
Nombre total de restaurants: $restaurantsCount
Nombre total de plats: $dishesCount

RESTAURANTS DISPONIBLES:
$restaurantInfo
$topRatedInfo

CAPACITÉS:
- Rechercher des restaurants par type de cuisine, nom, ou localisation
- Recommander des restaurants basés sur les notes et avis
- Suggérer des plats spécifiques disponibles dans nos restaurants
- Répondre aux questions sur les horaires, adresses, et contacts
- Aider à comparer différents restaurants
- Fournir des informations détaillées sur n'importe quel restaurant de notre base

RAPPEL: N'inventez JAMAIS d'informations. Si les données ne sont pas disponibles dans la base de données ci-dessus, dites-le clairement à l'utilisateur.
''';
  }

  /// Send a message and get response
  Future<String> sendMessage(String message) async {
    if (!_isInitialized || _model == null) {
      throw Exception('Gemini service not initialized. Please provide API key in .env file');
    }

    if (_chatSession == null) {
      await startNewChat();
    }

    try {
      debugPrint('📤 Sending message to Gemini: $message');

      final response = await _chatSession!.sendMessage(
        Content.text(message),
      );

      final responseText = response.text ?? 'Désolé, je n\'ai pas pu générer une réponse.';
      
      debugPrint('📥 Received response from Gemini: ${responseText.substring(0, responseText.length > 100 ? 100 : responseText.length)}...');

      return responseText;
    } catch (e) {
      debugPrint('❌ Error sending message to Gemini: $e');
      
      // Check if it's an API key error
      if (e.toString().contains('API key') || e.toString().contains('401')) {
        return 'Erreur: La clé API Gemini n\'est pas valide ou est manquante. Veuillez vérifier votre configuration.';
      }
      
      return 'Désolé, une erreur s\'est produite lors de la communication avec l\'assistant IA. Veuillez réessayer.';
    }
  }

  /// Get suggested questions based on context
  List<String> getSuggestedQuestions() {
    return [
      'Quels sont les restaurants les mieux notés ?',
      'Recommande-moi un restaurant italien',
      'Où puis-je trouver des sushis ?',
      'Quel restaurant propose les meilleurs plats ?',
      'Montre-moi les restaurants près de moi',
    ];
  }

  /// Reset chat session
  void resetChat() {
    _chatSession = null;
    debugPrint('🔄 Chat session reset');
  }

  /// Dispose resources
  void dispose() {
    _chatSession = null;
    _model = null;
    _isInitialized = false;
  }
}

