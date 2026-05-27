import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

enum FriendRequestStatus { pending, accepted, declined, none, sent }

class AppUser {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final bool isOnline;
  final FriendRequestStatus friendStatus;

  AppUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.isOnline = false,
    this.friendStatus = FriendRequestStatus.none,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final statusStr = json['friendStatus'] as String? ?? 'none';
    FriendRequestStatus status;
    switch (statusStr) {
      case 'pending':
        status = FriendRequestStatus.pending;
        break;
      case 'accepted':
        status = FriendRequestStatus.accepted;
        break;
      case 'declined':
        status = FriendRequestStatus.declined;
        break;
      case 'sent':
        status = FriendRequestStatus.sent;
        break;
      default:
        status = FriendRequestStatus.none;
    }

    return AppUser(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? json['username'] ?? '',
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      isOnline: json['isOnline'] ?? false,
      friendStatus: status,
    );
  }
}

class FriendRequest {
  final String id;
  final AppUser sender;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.sender,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'] ?? '',
      sender: AppUser.fromJson(json['sender'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class FriendsProvider extends ChangeNotifier {
  final _api = ApiService();

  List<AppUser> _friends = [];
  List<FriendRequest> _incomingRequests = [];
  List<AppUser> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String? _error;

  List<AppUser> get friends => _friends;
  List<FriendRequest> get incomingRequests => _incomingRequests;
  List<AppUser> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get error => _error;
  int get pendingRequestCount => _incomingRequests.length;

  Future<void> loadFriends() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/api/friends');
      final list = response['friends'] as List? ?? [];
      _friends =
          list.map((e) => AppUser.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadIncomingRequests() async {
    try {
      final response = await _api.get('/api/friends/requests/incoming');
      final list = response['requests'] as List? ?? [];
      _incomingRequests = list
          .map((e) => FriendRequest.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      final response = await _api.get('/api/users/search?q=${Uri.encodeComponent(query)}');
      final list = response['users'] as List? ?? [];
      _searchResults =
          list.map((e) => AppUser.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      _error = e.toString();
    }

    _isSearching = false;
    notifyListeners();
  }

  Future<bool> sendFriendRequest(String userId) async {
    try {
      await _api.post('/api/friends/request', {'targetUserId': userId});
      // Update search results to reflect sent status
      _searchResults = _searchResults.map((u) {
        if (u.id == userId) {
          return AppUser(
            id: u.id,
            username: u.username,
            displayName: u.displayName,
            avatarUrl: u.avatarUrl,
            bio: u.bio,
            isOnline: u.isOnline,
            friendStatus: FriendRequestStatus.sent,
          );
        }
        return u;
      }).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptRequest(String requestId) async {
    try {
      await _api.post('/api/friends/request/$requestId/accept', {});
      _incomingRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
      await loadFriends();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> declineRequest(String requestId) async {
    try {
      await _api.post('/api/friends/request/$requestId/decline', {});
      _incomingRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFriend(String userId) async {
    try {
      await _api.delete('/api/friends/$userId');
      _friends.removeWhere((f) => f.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}
