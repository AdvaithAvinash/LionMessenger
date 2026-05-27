import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

class Conversation {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  Conversation({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'],
      lastMessage: json['lastMessage'],
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
      isOnline: json['isOnline'] ?? false,
    );
  }
}

class MessagesProvider extends ChangeNotifier {
  final _api = ApiService();

  List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/api/conversations');
      final list = response['conversations'] as List? ?? [];
      _conversations = list
          .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> getOrCreateChannel(String targetUserId) async {
    try {
      final response = await _api.post('/api/conversations/dm', {
        'targetUserId': targetUserId,
      });
      return response['channelId'] as String?;
    } catch (e) {
      return null;
    }
  }

  void markAsRead(String conversationId) {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;
    _conversations[idx] = Conversation(
      id: _conversations[idx].id,
      userId: _conversations[idx].userId,
      userName: _conversations[idx].userName,
      userAvatar: _conversations[idx].userAvatar,
      lastMessage: _conversations[idx].lastMessage,
      lastMessageTime: _conversations[idx].lastMessageTime,
      unreadCount: 0,
      isOnline: _conversations[idx].isOnline,
    );
    notifyListeners();
  }
}
