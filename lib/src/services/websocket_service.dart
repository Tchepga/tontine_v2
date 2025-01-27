import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  final _logger = Logger('WebSocketService');
  WebSocketChannel? _channel;
  bool _isConnecting = false;
  static const _reconnectDelay = Duration(seconds: 5);
  
  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal();

  Future<void> connect() async {
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      final wsUrl = dotenv.env['WS_URL'];
      if (wsUrl != null) {
        _channel?.sink.close(status.goingAway);
        _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
        
        // Écouter les erreurs de connexion
        _channel!.stream.listen(
          (message) {
            _logger.info('WebSocket message received: $message');
          },
          onError: (error) {
            _logger.severe('WebSocket error: $error');
            _reconnect();
          },
          onDone: () {
            _logger.info('WebSocket connection closed');
            _reconnect();
          },
        );

        _logger.info('WebSocket connected successfully');
      }
    } catch (e) {
      _logger.severe('Error connecting to WebSocket: $e');
      _reconnect();
    } finally {
      _isConnecting = false;
    }
  }

  void _reconnect() {
    Future.delayed(_reconnectDelay, () {
      if (!_isConnecting) {
        _logger.info('Attempting to reconnect...');
        connect();
      }
    });
  }

  void emit(String event, dynamic data) {
    try {
      if (_channel != null) {
        final message = jsonEncode({
          'event': event,
          'data': data,
        });
        _channel!.sink.add(message);
        _logger.info('WebSocket message sent: $message');
      } else {
        _logger.warning('Cannot emit: WebSocket not connected');
        connect(); // Tenter de se reconnecter
      }
    } catch (e) {
      _logger.severe('Error emitting WebSocket event: $e');
      _reconnect();
    }
  }

  void disconnect() {
    try {
      _channel?.sink.close(status.normalClosure);
      _channel = null;
      _logger.info('WebSocket disconnected');
    } catch (e) {
      _logger.severe('Error disconnecting WebSocket: $e');
    }
  }
} 