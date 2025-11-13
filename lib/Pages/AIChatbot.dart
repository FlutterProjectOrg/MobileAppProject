import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_app_project/Pages/UI/AppColors.dart';
import 'package:mobile_app_project/services/AI/GeminiService.dart';
import 'package:mobile_app_project/services/AI/ChatHistoryService.dart';
import 'package:intl/intl.dart';

class Message {
  final int id;
  final String text;
  final String sender; // 'user' ou 'ai'
  final List<String>? suggestions;

  Message({
    required this.id,
    required this.text,
    required this.sender,
    this.suggestions,
  });
}

class AIChatbot extends StatefulWidget {
  final VoidCallback onClose;

  const AIChatbot({Key? key, required this.onClose}) : super(key: key);

  @override
  State<AIChatbot> createState() => _AIChatbotState();
}

class _AIChatbotState extends State<AIChatbot>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final GeminiService _geminiService = GeminiService.instance;
  final ChatHistoryService _chatHistory = ChatHistoryService.instance;

  final List<Message> _messages = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  int? _currentConversationId;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
    _initializeGemini();
  }

  Future<void> _initializeGemini() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get API key from .env
      final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
      
      if (apiKey.isEmpty) {
        setState(() {
          _errorMessage = 'La clé API Gemini n\'est pas configurée. Veuillez ajouter GEMINI_API_KEY dans le fichier .env';
          _isLoading = false;
          _isInitialized = false;
        });
        return;
      }

      // Initialize Gemini service
      final success = await _geminiService.initialize(apiKey);

      if (success) {
        // Start new chat with database context
        await _geminiService.startNewChat();

        // Create new conversation in database
        _currentConversationId = await _chatHistory.createConversation();

        const welcomeText = "Bonjour! Je suis votre assistant culinaire IA. Je connais tous les restaurants de notre base de données FoodFinder. Comment puis-je vous aider à trouver le restaurant parfait aujourd'hui?";
        
        // Save welcome message to database
        if (_currentConversationId != null) {
          await _chatHistory.saveMessage(
            conversationId: _currentConversationId!,
            sender: 'ai',
            message: welcomeText,
          );
        }

        // Add welcome message
        setState(() {
          _messages.add(
            Message(
              id: 1,
              text: welcomeText,
              sender: 'ai',
              suggestions: _geminiService.getSuggestedQuestions(),
            ),
          );
          _isInitialized = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Impossible d\'initialiser le service Gemini. Vérifiez votre clé API.';
          _isLoading = false;
          _isInitialized = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing Gemini: $e');
      setState(() {
        _errorMessage = 'Erreur: ${e.toString()}';
        _isLoading = false;
        _isInitialized = false;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSend([String? text]) async {
    final messageText = text ?? _textController.text;
    if (messageText.trim().isEmpty) return;

    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('L\'assistant IA n\'est pas encore initialisé'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Add user message
    setState(() {
      _messages.add(
        Message(id: _messages.length + 1, text: messageText, sender: 'user'),
      );
      _isLoading = true;
    });

    // Save user message to database
    if (_currentConversationId != null) {
      await _chatHistory.saveMessage(
        conversationId: _currentConversationId!,
        sender: 'user',
        message: messageText,
      );
      
      // Update conversation title with first user message
      if (_messages.where((m) => m.sender == 'user').length == 1) {
        final title = _chatHistory.generateTitle(messageText);
        await _chatHistory.updateConversationTitle(_currentConversationId!, title);
      }
    }

    _textController.clear();

    // Scroll to bottom after user message
    _scrollToBottom();

    try {
      // Get AI response
      final response = await _geminiService.sendMessage(messageText);

      // Save AI response to database
      if (_currentConversationId != null) {
        await _chatHistory.saveMessage(
          conversationId: _currentConversationId!,
          sender: 'ai',
          message: response,
        );
      }

      // Add AI response
      setState(() {
        _messages.add(
          Message(
            id: _messages.length + 1,
            text: response,
            sender: 'ai',
            suggestions: _shouldShowSuggestions() ? _geminiService.getSuggestedQuestions() : null,
          ),
        );
        _isLoading = false;
      });

      // Scroll to bottom after AI response
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error getting AI response: $e');
      const errorText = 'Désolé, une erreur s\'est produite. Veuillez réessayer.';
      
      // Save error message to database
      if (_currentConversationId != null) {
        await _chatHistory.saveMessage(
          conversationId: _currentConversationId!,
          sender: 'ai',
          message: errorText,
        );
      }
      
      setState(() {
        _messages.add(
          Message(
            id: _messages.length + 1,
            text: errorText,
            sender: 'ai',
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  bool _shouldShowSuggestions() {
    // Show suggestions every 3 messages or for first message
    return _messages.length <= 2 || _messages.length % 3 == 0;
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSuggestionClick(String suggestion) {
    _handleSend(suggestion);
  }

  /// Load a previous conversation
  Future<void> _loadConversation(int conversationId) async {
    setState(() {
      _isLoading = true;
      _showHistory = false;
    });

    try {
      // Get messages from database
      final messagesData = await _chatHistory.getMessages(conversationId);
      
      // Start new Gemini chat
      await _geminiService.startNewChat();
      
      // Convert to Message objects
      final messages = messagesData.map((data) {
        return Message(
          id: data['id'] as int,
          text: data['message'] as String,
          sender: data['sender'] as String,
        );
      }).toList();

      setState(() {
        _currentConversationId = conversationId;
        _messages.clear();
        _messages.addAll(messages);
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('Error loading conversation: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Start a new conversation
  Future<void> _startNewConversation() async {
    setState(() {
      _showHistory = false;
    });
    
    // Reinitialize to start fresh
    _initializeGemini();
  }

  /// Delete a conversation
  Future<void> _deleteConversation(int conversationId) async {
    try {
      await _chatHistory.deleteConversation(conversationId);
      
      // If we're currently viewing this conversation, start a new one
      if (_currentConversationId == conversationId) {
        _startNewConversation();
      } else {
        setState(() {}); // Refresh history list
      }
    } catch (e) {
      debugPrint('Error deleting conversation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Empêche la fermeture quand on clique sur la carte
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 40,
                ),
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 600,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryOrange.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildHeader(),
                    if (_showHistory)
                      _buildHistoryPanel()
                    else ...[
                      _buildMessagesList(),
                      _buildInputArea(),
                    ],
                  ],
                ),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assistant IA Culinaire',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'En ligne',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // New Chat button
          GestureDetector(
            onTap: _startNewConversation,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          // History button
          GestureDetector(
            onTap: () => setState(() => _showHistory = !_showHistory),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _showHistory 
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.history, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          // Close button
          GestureDetector(
            onTap: widget.onClose,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel() {
    return Expanded(
      child: Container(
        color: AppColors.background,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _chatHistory.getConversations(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryOrange,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur lors du chargement',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            final conversations = snapshot.data ?? [];

            if (conversations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aucune conversation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Commencez une nouvelle conversation',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                final conversationId = conversation['id'] as int;
                final title = conversation['title'] as String;
                final messageCount = conversation['message_count'] as int;
                final updatedAt = conversation['updated_at'] as String;
                final lastMessage = conversation['last_message'] as String?;
                
                final isActive = conversationId == _currentConversationId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _loadConversation(conversationId),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: isActive ? AppColors.gradientPrimary.scale(0.1) : null,
                        color: isActive ? null : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive 
                              ? AppColors.primaryOrange
                              : Colors.grey.withOpacity(0.2),
                          width: isActive ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isActive
                                ? AppColors.primaryOrange.withOpacity(0.2)
                                : Colors.black.withOpacity(0.05),
                            blurRadius: isActive ? 10 : 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: isActive 
                                  ? AppColors.gradientPrimary
                                  : null,
                              color: isActive 
                                  ? null 
                                  : AppColors.primaryOrange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              color: isActive 
                                  ? Colors.white 
                                  : AppColors.primaryOrange,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isActive 
                                        ? FontWeight.bold 
                                        : FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                if (lastMessage != null)
                                  Text(
                                    lastMessage,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.message,
                                      size: 14,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$messageCount message${messageCount > 1 ? 's' : ''}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Icons.access_time,
                                      size: 14,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(updatedAt),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.grey[600],
                            ),
                            onPressed: () => _showDeleteConfirmation(conversationId),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'À l\'instant';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}j';
      } else {
        return DateFormat('dd/MM/yy').format(date);
      }
    } catch (e) {
      return '';
    }
  }

  void _showDeleteConfirmation(int conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Supprimer la conversation ?'),
        content: const Text(
          'Cette action est irréversible. Toutes les messages seront supprimés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteConversation(conversationId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, Colors.white],
          ),
        ),
        child: _errorMessage != null
            ? _buildErrorState()
            : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildLoadingIndicator();
                  }
                  return _buildMessageItem(_messages[index]);
                },
              ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Erreur d\'initialisation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Une erreur est survenue',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                _initializeGemini();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: AppColors.primaryOrange.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryOrange,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'L\'assistant réfléchit...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Message message) {
    final isUser = message.sender == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: isUser ? AppColors.gradientPrimary : null,
                    color: isUser ? null : Colors.white,
                    border: isUser
                        ? null
                        : Border.all(
                            color: AppColors.primaryOrange.withOpacity(0.2),
                          ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? AppColors.primaryOrange.withOpacity(0.2)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (message.suggestions != null && message.suggestions!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.suggestions!.map((suggestion) {
                  return GestureDetector(
                    onTap: () => _handleSuggestionClick(suggestion),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: AppColors.primaryOrange.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryOrange.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        suggestion,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.primaryOrange.withOpacity(0.1)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primaryOrange.withOpacity(0.2),
                ),
              ),
              child: TextField(
                controller: _textController,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Posez-moi une question...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _handleSend(),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryOrange.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
