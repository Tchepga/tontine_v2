import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  final _logger = Logger('WebSocketService');
  WebSocketChannel? _channel;
  
  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal();

  void connect() {
    try {
      final wsUrl = dotenv.env['WS_URL'];
      if (wsUrl != null) {
        _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
        _logger.info('WebSocket connected');
      }
    } catch (e) {
      _logger.severe('Error connecting to WebSocket: $e');
    }
  }

  void emit(String event, dynamic data) {
    try {
      if (_channel != null) {
        _channel!.sink.add({
          'event': event,
          'data': data,
        });
      }
    } catch (e) {
      _logger.severe('Error emitting WebSocket event: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _logger.info('WebSocket disconnected');
  }
} 