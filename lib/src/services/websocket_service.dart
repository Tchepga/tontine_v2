import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:get_storage/get_storage.dart';
import '../screen/services/member_service.dart';

/// Callback pour les événements WebSocket
typedef WebSocketEventCallback = void Function(
    String event, Map<String, dynamic> data);

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  final _logger = Logger('WebSocketService');
  final _storage = GetStorage();
  IO.Socket? _socket;
  bool _isConnecting = false;
  bool _isConnected = false;
  static const _reconnectDelay = Duration(seconds: 5);

  // Map pour stocker les callbacks par événement
  final Map<String, List<WebSocketEventCallback>> _eventListeners = {};

  factory WebSocketService() {
    return _instance;
  }

  WebSocketService._internal();

  bool get isConnected => _isConnected;

  /// S'abonner à un événement
  void on(String event, WebSocketEventCallback callback) {
    _eventListeners.putIfAbsent(event, () => []).add(callback);
    _logger.info('Subscribed to event: $event');

    // Si le socket est déjà connecté, s'abonner directement
    if (_socket != null && _socket!.connected) {
      _socket!.on(event, (data) {
        try {
          final eventData =
              data is Map<String, dynamic> ? data : {'data': data};
          callback(event, eventData);
        } catch (e) {
          _logger.severe('Error in event callback for $event: $e');
        }
      });
    }
  }

  /// Se désabonner d'un événement
  void off(String event, WebSocketEventCallback? callback) {
    if (callback != null) {
      _eventListeners[event]?.remove(callback);
    } else {
      _eventListeners.remove(event);
    }

    // Désabonner du socket Socket.IO
    _socket?.off(event);
  }

  Future<void> connect() async {
    if (_isConnecting || _isConnected) return;
    _isConnecting = true;

    try {
      final wsUrl = dotenv.env['WS_URL'];
      final token = _storage.read(MemberService.KEY_TOKEN);

      if (wsUrl != null && token != null) {
        _logger.info('WS_URL from env: $wsUrl');
        _logger.info('Connecting to Socket.IO server...');

        // Nettoyer l'URL : retirer le protocole ws:// ou wss:// pour Socket.IO
        // Socket.IO gère automatiquement le protocole
        String serverUrl = wsUrl;
        if (serverUrl.startsWith('wss://')) {
          serverUrl = serverUrl.replaceFirst('wss://', 'https://');
        } else if (serverUrl.startsWith('ws://')) {
          serverUrl = serverUrl.replaceFirst('ws://', 'http://');
        }

        // Créer la connexion Socket.IO
        _socket = IO.io(
          serverUrl,
          IO.OptionBuilder()
              .setTransports(['websocket']) // Utiliser uniquement WebSocket
              .setQuery({'token': token}) // Passer le token en query param
              .enableAutoConnect()
              .enableReconnection()
              .setReconnectionDelay(1000)
              .setReconnectionDelayMax(5000)
              .setReconnectionAttempts(5)
              .build(),
        );

        // Écouter les événements de connexion
        _socket!.onConnect((_) {
          _logger.info('✅ Socket.IO connected successfully');
          _isConnected = true;
          _isConnecting = false;

          // Réabonner tous les listeners existants
          _reSubscribeAllListeners();
        });

        _socket!.onDisconnect((_) {
          _logger.info('❌ Socket.IO disconnected');
          _isConnected = false;
          _isConnecting = false;
        });

        _socket!.onConnectError((error) {
          _logger.severe('❌ Socket.IO connection error: $error');
          _isConnected = false;
          _isConnecting = false;
        });

        _socket!.onError((error) {
          _logger.severe('❌ Socket.IO error: $error');
        });

        // Écouter l'événement 'notification' par défaut
        _socket!.on('notification', (data) {
          _logger.info('🔔 Notification received: $data');
          _handleEvent('notification',
              data is Map<String, dynamic> ? data : {'data': data});
        });

        // Connecter
        _socket!.connect();
      } else {
        _logger.warning('WebSocket URL or token not available');
        _isConnecting = false;
      }
    } catch (e) {
      _logger.severe('Error connecting to Socket.IO: $e');
      _isConnected = false;
      _isConnecting = false;
      _reconnect();
    }
  }

  /// Réabonner tous les listeners après reconnexion
  void _reSubscribeAllListeners() {
    for (final entry in _eventListeners.entries) {
      final event = entry.key;
      final callbacks = entry.value;

      _socket!.on(event, (data) {
        for (final callback in callbacks) {
          try {
            final eventData =
                data is Map<String, dynamic> ? data : {'data': data};
            callback(event, eventData);
          } catch (e) {
            _logger.severe('Error in event callback for $event: $e');
          }
        }
      });
    }
  }

  /// Gérer les événements reçus
  void _handleEvent(String event, Map<String, dynamic> data) {
    // Appeler tous les callbacks pour cet événement
    final callbacks = _eventListeners[event] ?? [];
    for (final callback in callbacks) {
      try {
        callback(event, data);
      } catch (e) {
        _logger.severe('Error in event callback for $event: $e');
      }
    }

    // Appeler aussi les callbacks génériques (pour tous les événements)
    final allCallbacks = _eventListeners['*'] ?? [];
    for (final callback in allCallbacks) {
      try {
        callback(event, data);
      } catch (e) {
        _logger.severe('Error in generic event callback: $e');
      }
    }
  }

  void _reconnect() {
    Future.delayed(_reconnectDelay, () {
      if (!_isConnecting && !_isConnected) {
        _logger.info('Attempting to reconnect...');
        connect();
      }
    });
  }

  /// Émettre un événement vers le serveur
  void emit(String event, dynamic data, [Function? callback]) {
    try {
      if (_socket != null && _socket!.connected) {
        if (callback != null) {
          _socket!.emitWithAck(event, data, ack: callback);
        } else {
          _socket!.emit(event, data);
        }
        _logger.info('Socket.IO event emitted: $event');
      } else {
        _logger.warning('Cannot emit: Socket.IO not connected');
        connect(); // Tenter de se reconnecter
      }
    } catch (e) {
      _logger.severe('Error emitting Socket.IO event: $e');
      _reconnect();
    }
  }

  /// Rejoindre une tontine (room Socket.IO)
  void joinTontine(int tontineId, [Function? callback]) {
    emit('joinTontine', tontineId, callback);
    _logger.info('Joining tontine room: $tontineId');
  }

  /// Quitter une tontine (room Socket.IO)
  void leaveTontine(int tontineId, [Function? callback]) {
    emit('leaveTontine', tontineId, callback);
    _logger.info('Leaving tontine room: $tontineId');
  }

  void disconnect() {
    try {
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      _isConnected = false;
      _logger.info('Socket.IO disconnected');
    } catch (e) {
      _logger.severe('Error disconnecting Socket.IO: $e');
    }
  }
}
