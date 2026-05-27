import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';

enum MessagePrivacy { everyone, friends }

class BlockedUser {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;

  BlockedUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      avatarUrl: json['avatarUrl'],
    );
  }
}

class SettingsProvider extends ChangeNotifier {
  final _api = ApiService();

  MessagePrivacy _messagePrivacy = MessagePrivacy.friends;
  List<BlockedUser> _blockedUsers = [];
  bool _isLoading = false;

  MessagePrivacy get messagePrivacy => _messagePrivacy;
  List<BlockedUser> get blockedUsers => _blockedUsers;
  bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    try {
      final response = await _api.get('/api/users/me/settings');
      final privacyStr = response['messagePrivacy'] as String? ?? 'FRIENDS';
      _messagePrivacy = privacyStr == 'EVERYONE'
          ? MessagePrivacy.everyone
          : MessagePrivacy.friends;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadBlockedUsers() async {
    try {
      final response = await _api.get('/api/users/me/blocked');
      final list = response['blocked'] as List? ?? [];
      _blockedUsers = list
          .map((e) => BlockedUser.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> updateMessagePrivacy(MessagePrivacy privacy) async {
    try {
      await _api.put('/api/users/me/settings', {
        'messagePrivacy':
            privacy == MessagePrivacy.everyone ? 'EVERYONE' : 'FRIENDS',
      });
      _messagePrivacy = privacy;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> blockUser(String userId) async {
    try {
      await _api.post('/api/users/block', {'targetUserId': userId});
      await loadBlockedUsers();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unblockUser(String userId) async {
    try {
      await _api.delete('/api/users/block/$userId');
      _blockedUsers.removeWhere((u) => u.id == userId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
