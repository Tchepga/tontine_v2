import 'dart:async';
import 'dart:developer' show log;
import 'dart:io';

/// Script de test pour diagnostiquer les problèmes de connexion WebSocket
///
/// Pour exécuter ce test:
/// dart test/websocket_connection_test.dart
void main() async {
  log('=== Test de connexion WebSocket ===\n');

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

  log('URLs à tester:');
  for (var i = 0; i < testUrls.length; i++) {
    log('  ${i + 1}. ${testUrls[i].replaceAll(token, 'TOKEN')}');
  }
  log('');

  // Tester chaque URL
  for (var i = 0; i < testUrls.length; i++) {
    final url = testUrls[i];
    log(
        'Test ${i + 1}/${testUrls.length}: ${url.replaceAll(token, 'TOKEN')}');
    await testWebSocketConnection(url);
    log('');
  }

  log('=== Tests terminés ===');
}

Future<void> testWebSocketConnection(String url) async {
  WebSocket? socket;

  try {
    log('  Tentative de connexion...');

    // Connexion simple sans headers personnalisés
    log('  Connexion simple sans headers...');

    // Tentative de connexion avec timeout
    socket = await WebSocket.connect(url).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('Timeout après 10 secondes');
      },
    );

    log('  ✓ Connexion établie avec succès!');
    log('  ReadyState: ${socket.readyState}');

    // Écouter les messages pendant 3 secondes
    log('  Écoute des messages pendant 3 secondes...');

    final subscription = socket.listen(
      (message) {
        log(
            '  ✓ Message reçu: ${message.toString().substring(0, message.toString().length > 100 ? 100 : message.toString().length)}...');
      },
      onError: (error) {
        log('  ✗ Erreur de stream: $error');
      },
      onDone: () {
        log('  ✓ Connexion fermée proprement');
      },
    );

    // Attendre un peu pour voir si on reçoit des messages
    await Future.delayed(const Duration(seconds: 3));

    // Fermer
    await subscription.cancel();
    await socket.close();
    log('  ✓ Test réussi - Connexion fermée');
  } on TimeoutException catch (e) {
    log('  ✗ Timeout: $e');
  } on SocketException catch (e) {
    log('  ✗ Erreur Socket: ${e.message}');
    if (e.osError != null) {
      log('  ✗ OS Error: ${e.osError}');
    }
  } on HttpException catch (e) {
    log('  ✗ Erreur HTTP: ${e.message}');
    log('  ✗ Cela indique généralement:');
    log('     - Code HTTP 502: Problème de proxy/gateway');
    log('     - Code HTTP 400: Mauvaise requête');
    log('     - Code HTTP 401/403: Authentification échouée');
    log('     - Le serveur n\'a pas accepté la mise à niveau WebSocket');
  } on WebSocketException catch (e) {
    log('  ✗ Erreur WebSocket: ${e.message}');
  } catch (e, stackTrace) {
    log('  ✗ Erreur inattendue: $e');
    log('  ✗ Type: ${e.runtimeType}');
    log(
        '  ✗ Stack trace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
  } finally {
    try {
      await socket?.close();
    } catch (_) {}
  }
}
