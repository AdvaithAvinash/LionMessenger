import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'api_service.dart';
import '../../config/constants.dart';

class StreamService {
  static final StreamService _instance = StreamService._internal();
  factory StreamService() => _instance;
  StreamService._internal();

  late final StreamChatClient _client = StreamChatClient(
    AppConstants.streamApiKey,
    logLevel: Level.OFF,
  );

  StreamChatClient get client => _client;

  bool get isConnected => _client.state.currentUser != null;

  /// Call after the user has authenticated. Fetches a Stream token from the
  /// backend and connects the user to Stream Chat.
  Future<void> connectUser({
    required String userId,
    required String displayName,
    String? imageUrl,
  }) async {
    // Already connected as this user — nothing to do
    if (isConnected && _client.state.currentUser!.id == userId) return;

    // Disconnect stale session if any
    if (isConnected) await _client.disconnectUser();

    final api = ApiService();
    final response = await api.post('/api/stream/token', {});
    final token = response['token'] as String;

    await _client.connectUser(
      User(
        id: userId,
        extraData: {
          'name': displayName,
          if (imageUrl != null) 'image': imageUrl,
        },
      ),
      token,
    );
  }

  Future<void> disconnect() async {
    if (!isConnected) return;
    await _client.disconnectUser();
  }

  /// Returns a watched DM channel between the current user and [targetUserId].
  /// Calls the backend to create/get the channel ID first (enforces privacy).
  Future<Channel> getOrCreateDMChannel(String targetUserId) async {
    final api = ApiService();
    final response = await api.post('/api/conversations/dm', {
      'targetUserId': targetUserId,
    });
    final channelId = response['channelId'] as String;

    final channel = _client.channel('messaging', id: channelId);
    await channel.watch();
    return channel;
  }
}
