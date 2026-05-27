import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/stream_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class UserProfile {
  final String id;
  final String username;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final String messagePrivacy;

  UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.messagePrivacy = 'FRIENDS',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      bio: json['bio'],
      messagePrivacy: json['messagePrivacy'] ?? 'FRIENDS',
    );
  }

  UserProfile copyWith({
    String? displayName,
    String? avatarUrl,
    String? bio,
    String? messagePrivacy,
  }) {
    return UserProfile(
      id: id,
      username: username,
      displayName: displayName ?? this.displayName,
      email: email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      messagePrivacy: messagePrivacy ?? this.messagePrivacy,
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _api = ApiService();

  AuthStatus _status = AuthStatus.unknown;
  UserProfile? _currentUser;
  String? _error;
  bool _isLoading = false;

  AuthStatus get status => _status;
  UserProfile? get currentUser => _currentUser;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkAuthStatus() async {
    final token = await _storage.read(key: 'clerk_session_token');
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    await _loadCurrentUser();
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post('/api/auth/sign-in', {
        'email': email,
        'password': password,
      });

      final token = response['token'] as String;
      await _storage.write(key: 'clerk_session_token', value: token);
      await _loadCurrentUser();
      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post('/api/auth/sign-up', {
        'email': email,
        'password': password,
        'username': username,
        'displayName': displayName,
      });

      final token = response['token'] as String;
      await _storage.write(key: 'clerk_session_token', value: token);
      await _loadCurrentUser();
      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await StreamService().disconnect();
    await _storage.delete(key: 'clerk_session_token');
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final response = await _api.get('/api/users/me');
      _currentUser = UserProfile.fromJson(response);
      _status = AuthStatus.authenticated;

      // Connect Stream Chat in the background — don't block auth on failure
      StreamService().connectUser(
        userId: _currentUser!.id,
        displayName: _currentUser!.displayName,
        imageUrl: _currentUser!.avatarUrl,
      ).catchError((_) {});
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      await _storage.delete(key: 'clerk_session_token');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final response = await _api.put('/api/users/me', {
        if (displayName != null) 'displayName': displayName,
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      });
      _currentUser = UserProfile.fromJson(response);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
