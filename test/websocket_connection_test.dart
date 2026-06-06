import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

/// Script de test pour diagnostiquer les problèmes de connexion WebSocket
///
/// Pour exécuter ce test:
/// dart test/websocket_connection_test.dart
final _log = Logger('WebSocketConnectionTest');

void _initLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    stdout.writeln(record.message);
  });
}

void main() async {
  _initLogging();
  _log.info('=== Test de connexion WebSocket ===\n');

  // Configuration
  const baseUrl = 'api.tontine.devcoorp.net';
  const token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InVzZXJuYW1lIiwicm9sZSI6WyJQUkVTSURFTlQiXSwiaWF0IjoxNzYzNDEyMTM2LCJleHAiOjE3NjM0OTg1MzZ9.HJBJrVXcE28IFTgDYOKYdObUqx8RIC8RKWl9G9JN-oQ';

  // Liste des URLs à tester
  final testUrls = [
    'wss://$baseUrl?token=$token',
    'wss://$baseUrl/?token=$token',
    'wss://$baseUrl/ws?token=$token',
    'wss://$baseUrl/socket?token=$token',
    'wss://$baseUrl/api?token=$token',
    'ws://$baseUrl?token=$token', // Version non sécurisée
  ];

  _log.info('URLs à tester:');
  for (var i = 0; i < testUrls.length; i++) {
    _log.info('  ${i + 1}. ${testUrls[i].replaceAll(token, 'TOKEN')}');
  }
  _log.info('');

  // Tester chaque URL
  for (var i = 0; i < testUrls.length; i++) {
    final url = testUrls[i];
    _log.info(
        'Test ${i + 1}/${testUrls.length}: ${url.replaceAll(token, 'TOKEN')}');
    await testWebSocketConnection(url);
    _log.info('');
  }

  _log.info('=== Tests terminés ===');
}

Future<void> testWebSocketConnection(String url) async {
  WebSocket? socket;

  try {
    _log.info('  Tentative de connexion...');

    // Connexion simple sans headers personnalisés
    _log.info('  Connexion simple sans headers...');

    // Tentative de connexion avec timeout
    socket = await WebSocket.connect(url).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('Timeout après 10 secondes');
      },
    );

    _log.info('  ✓ Connexion établie avec succès!');
    _log.info('  ReadyState: ${socket.readyState}');

    // Écouter les messages pendant 3 secondes
    _log.info('  Écoute des messages pendant 3 secondes...');

    final subscription = socket.listen(
      (message) {
        _log.info(
            '  ✓ Message reçu: ${message.toString().substring(0, message.toString().length > 100 ? 100 : message.toString().length)}...');
      },
      onError: (error) {
        _log.severe('  ✗ Erreur de stream: $error');
      },
      onDone: () {
        _log.info('  ✓ Connexion fermée proprement');
      },
    );

    // Attendre un peu pour voir si on reçoit des messages
    await Future.delayed(const Duration(seconds: 3));

    // Fermer
    await subscription.cancel();
    await socket.close();
    _log.info('  ✓ Test réussi - Connexion fermée');
  } on TimeoutException catch (e) {
    _log.severe('  ✗ Timeout: $e');
  } on SocketException catch (e) {
    _log.severe('  ✗ Erreur Socket: ${e.message}');
    if (e.osError != null) {
      _log.severe('  ✗ OS Error: ${e.osError}');
    }
  } on HttpException catch (e) {
    _log.severe('  ✗ Erreur HTTP: ${e.message}');
    _log.severe('  ✗ Cela indique généralement:');
    _log.severe('     - Code HTTP 502: Problème de proxy/gateway');
    _log.severe('     - Code HTTP 400: Mauvaise requête');
    _log.severe('     - Code HTTP 401/403: Authentification échouée');
    _log.severe(
        '     - Le serveur n\'a pas accepté la mise à niveau WebSocket');
  } on WebSocketException catch (e) {
    _log.severe('  ✗ Erreur WebSocket: ${e.message}');
  } catch (e, stackTrace) {
    _log.severe('  ✗ Erreur inattendue: $e');
    _log.severe('  ✗ Type: ${e.runtimeType}');
    _log.severe(
        '  ✗ Stack trace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
  } finally {
    try {
      await socket?.close();
    } catch (_) {}
  }
}
