import 'dart:async';
import 'dart:convert';
import 'dart:io'; // ✅ ADD THIS

import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../utils/app_logger.dart';

enum ConnectionStatus { connected, disconnected, reconnecting, failed }

class WebSocketService {
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<ConnectionStatus> _connectionStatusController =
      StreamController<ConnectionStatus>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<ConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 7;
  final List<int> _backoffDelays = [0, 1, 2, 4, 8, 16, 30];

  String? _lastSessionCode;
  String? _lastUserId;

  Future<void> connect(String sessionCode, String userId) async {
    _lastSessionCode = sessionCode;
    _lastUserId = userId;
    _reconnectAttempts = 0;
    await _connect(sessionCode, userId);
  }

  Future _connect(String sessionCode, String userId) async {
    // Clean session code and user ID - remove any special characters
    final cleanSessionCode = sessionCode.trim();
    final cleanUserId = userId.trim();

    // Use Render backend URL with secure WebSocket (wss://)
    const baseUrl = 'queez-backend.onrender.com';

    // Construct URI properly - NO trailing characters
    final wsUrl =
        'wss://$baseUrl/api/ws/$cleanSessionCode?user_id=$cleanUserId';

    AppLogger.websocket('Connecting to WebSocket: $wsUrl');

    try {
      if (_reconnectAttempts > 0) {
        _connectionStatusController.add(ConnectionStatus.reconnecting);
      }

      // ✅ FIX: Create HttpClient that accepts bad certificates (for emulator)
      final httpClient = HttpClient()
        ..badCertificateCallback =
            ((X509Certificate cert, String host, int port) {
              // Accept all certificates in development
              AppLogger.warning(
                'Accepting certificate for $host (development mode)',
              );
              return true;
            });

      // ✅ Create WebSocket with custom HttpClient
      final socket = await WebSocket.connect(wsUrl, customClient: httpClient)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('WebSocket connection timeout');
            },
          );

      _channel = IOWebSocketChannel(socket);

      _isConnected = true;
      _reconnectAttempts = 0;
      _connectionStatusController.add(ConnectionStatus.connected);

      // Start heartbeat to keep connection alive (mobile networks kill idle connections)
      _startHeartbeat();

      AppLogger.success('WebSocket connected successfully');

      _channel!.stream.listen(
        (message) {
          try {
            final decodedMessage = jsonDecode(message);
            _messageController.add(decodedMessage);
          } catch (e) {
            AppLogger.error('WS - Failed to decode message: $e');
          }
        },
        onDone: () {
          AppLogger.warning('WebSocket connection closed');
          _isConnected = false;
          _handleDisconnect();
        },
        onError: (error) {
          AppLogger.error('WebSocket error: $error');
          _isConnected = false;
          _handleDisconnect();
        },
      );
    } catch (e) {
      AppLogger.error('WebSocket connection failed: $e');
      _isConnected = false;
      _handleDisconnect();
      rethrow;
    }
  }

  void sendMessage(String type, [Map<String, dynamic>? payload]) {
    if (_channel != null && _isConnected) {
      final message = {'type': type, if (payload != null) 'payload': payload};
      _channel!.sink.add(jsonEncode(message));
    } else {
      AppLogger.warning('WS - Cannot send message, not connected. Type: $type');
    }
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _isConnected = false;
      _channel = null;
      _connectionStatusController.add(ConnectionStatus.disconnected);
    }
  }

  /// Send ping every 25 seconds to keep connection alive
  /// Mobile networks kill idle WebSocket connections after 30-60s
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (_isConnected) {
        sendMessage('ping');
        AppLogger.debug('Heartbeat ping sent');
      }
    });
  }

  void _handleDisconnect() {
    _isConnected = false;
    _connectionStatusController.add(ConnectionStatus.disconnected);

    if (_lastSessionCode != null && _lastUserId != null) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive ?? false) return;

    if (_reconnectAttempts < _maxReconnectAttempts) {
      final delay =
          _backoffDelays[_reconnectAttempts.clamp(
            0,
            _backoffDelays.length - 1,
          )];
      _reconnectAttempts++;

      AppLogger.info(
        'Reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts in ${delay}s',
      );

      _reconnectTimer = Timer(Duration(seconds: delay), () {
        if (_lastSessionCode != null && _lastUserId != null) {
          _connect(_lastSessionCode!, _lastUserId!);
        }
      });
    } else {
      // Max retries exceeded - signal permanent failure
      AppLogger.error('Max reconnect attempts reached, giving up');
      _connectionStatusController.add(ConnectionStatus.failed);
    }
  }
}
