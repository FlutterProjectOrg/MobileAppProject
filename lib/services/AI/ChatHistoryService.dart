import 'package:flutter/foundation.dart';
import 'package:mobile_app_project/database/LocalDb.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatHistoryService {
  ChatHistoryService._();
  static final ChatHistoryService instance = ChatHistoryService._();

  /// Create a new chat conversation
  Future<int> createConversation({int? userId, String? title}) async {
    debugPrint('💬 createConversation: Starting...');
    try {
      final db = LocalDb.instance.db;
      
      // If no userId provided, try to get from SharedPreferences
      userId ??= await _getCurrentUserId();
      debugPrint('💬 Creating conversation for user: $userId');
      
      final id = await db.insert('chat_conversations', {
        'user_id': userId,
        'title': title ?? 'Nouvelle conversation',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      debugPrint('✅ Conversation created with ID: $id');
      return id;
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating conversation: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get current user ID from SharedPreferences
  Future<int?> _getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('userId');
    } catch (e) {
      return null;
    }
  }

  /// Save a message to a conversation
  Future<int> saveMessage({
    required int conversationId,
    required String sender,
    required String message,
  }) async {
    debugPrint('💾 saveMessage: conversation=$conversationId, sender=$sender');
    try {
      final db = LocalDb.instance.db;
      
      final messageId = await db.insert('chat_messages', {
        'conversation_id': conversationId,
        'sender': sender,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      debugPrint('💾 Message saved with ID: $messageId');
      
      // Update conversation updated_at
      await db.update(
        'chat_conversations',
        {'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [conversationId],
      );
      
      debugPrint('✅ Conversation $conversationId updated');
      return messageId;
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving message: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get all conversations for current user (or all if no user)
  Future<List<Map<String, dynamic>>> getConversations({int? userId}) async {
    debugPrint('📋 getConversations: Starting...');
    try {
      final db = LocalDb.instance.db;
      debugPrint('📋 Database instance obtained');
      
      // If no userId provided, try to get from SharedPreferences
      userId ??= await _getCurrentUserId();
      debugPrint('📋 User ID: $userId');
      
      List<Map<String, dynamic>> conversations;
      
      if (userId != null) {
        debugPrint('📋 Querying conversations for user $userId');
        conversations = await db.query(
          'chat_conversations',
          where: 'user_id = ?',
          whereArgs: [userId],
          orderBy: 'updated_at DESC',
        );
        debugPrint('📋 Found ${conversations.length} conversations for user');
      } else {
        // Get all conversations if no user
        debugPrint('📋 Querying all conversations (no user specified)');
        conversations = await db.query(
          'chat_conversations',
          orderBy: 'updated_at DESC',
        );
        debugPrint('📋 Found ${conversations.length} total conversations');
      }
      
      // For each conversation, get the message count and last message
      final enrichedConversations = <Map<String, dynamic>>[];
      debugPrint('📋 Enriching ${conversations.length} conversations with message data...');
      
      for (var i = 0; i < conversations.length; i++) {
        final conversation = conversations[i];
        final conversationId = conversation['id'];
        debugPrint('📋 Processing conversation $i (ID: $conversationId)');
        
        try {
          final messages = await db.query(
            'chat_messages',
            where: 'conversation_id = ?',
            whereArgs: [conversationId],
            orderBy: 'created_at DESC',
            limit: 1,
          );
          debugPrint('📋   - Last message query returned ${messages.length} result(s)');
          
          final count = await db.query(
            'chat_messages',
            where: 'conversation_id = ?',
            whereArgs: [conversationId],
          );
          debugPrint('📋   - Total message count: ${count.length}');
          
          // Create a mutable copy of the conversation map
          debugPrint('📋   - Creating mutable copy of conversation map');
          final enrichedConversation = Map<String, dynamic>.from(conversation);
          
          debugPrint('📋   - Adding enrichment data');
          enrichedConversation['message_count'] = count.length;
          enrichedConversation['last_message'] = messages.isNotEmpty ? messages.first['message'] : null;
          enrichedConversation['last_message_time'] = messages.isNotEmpty ? messages.first['created_at'] : null;
          
          enrichedConversations.add(enrichedConversation);
          debugPrint('📋   - Conversation $i enriched successfully');
        } catch (e) {
          debugPrint('❌ Error enriching conversation $conversationId: $e');
          debugPrint('❌ Stack trace: ${StackTrace.current}');
          // Continue with other conversations
        }
      }
      
      debugPrint('✅ getConversations: Returning ${enrichedConversations.length} enriched conversations');
      return enrichedConversations;
    } catch (e, stackTrace) {
      debugPrint('❌ Error in getConversations: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Get messages for a specific conversation
  Future<List<Map<String, dynamic>>> getMessages(int conversationId) async {
    final db = LocalDb.instance.db;
    
    final messages = await db.query(
      'chat_messages',
      where: 'conversation_id = ?',
      whereArgs: [conversationId],
      orderBy: 'created_at ASC',
    );
    
    return messages;
  }

  /// Update conversation title
  Future<void> updateConversationTitle(int conversationId, String title) async {
    final db = LocalDb.instance.db;
    
    await db.update(
      'chat_conversations',
      {
        'title': title,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  /// Delete a conversation and all its messages
  Future<void> deleteConversation(int conversationId) async {
    final db = LocalDb.instance.db;
    
    // Messages will be deleted automatically due to CASCADE
    await db.delete(
      'chat_conversations',
      where: 'id = ?',
      whereArgs: [conversationId],
    );
  }

  /// Generate a smart title from the first user message
  String generateTitle(String firstMessage) {
    // Remove extra spaces and trim
    String cleaned = firstMessage.trim().replaceAll(RegExp(r'\s+'), ' ');
    
    // Take first 30 characters or up to first question mark/period
    int maxLength = 40;
    if (cleaned.length <= maxLength) {
      return cleaned;
    }
    
    // Try to find a natural break point
    int breakPoint = cleaned.indexOf('?');
    if (breakPoint == -1) breakPoint = cleaned.indexOf('.');
    if (breakPoint == -1) breakPoint = cleaned.indexOf('!');
    
    if (breakPoint != -1 && breakPoint < maxLength) {
      return cleaned.substring(0, breakPoint + 1);
    }
    
    // Otherwise just truncate with ellipsis
    return '${cleaned.substring(0, maxLength)}...';
  }

  /// Clear all conversations for current user
  Future<void> clearAllConversations({int? userId}) async {
    final db = LocalDb.instance.db;
    
    // If no userId provided, try to get from SharedPreferences
    userId ??= await _getCurrentUserId();
    
    if (userId != null) {
      await db.delete(
        'chat_conversations',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    } else {
      // Clear all conversations if no user
      await db.delete('chat_conversations');
    }
  }
}

