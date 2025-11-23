import 'dart:io';
import 'dart:async';

/// Script de test pour diagnostiquer les problèmes de connexion WebSocket
///
/// Pour exécuter ce test:
/// dart test/websocket_connection_test.dart
void main() async {
  print('=== Test de connexion WebSocket ===\n');

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

  print('URLs à tester:');
  for (var i = 0; i < testUrls.length; i++) {
    print('  ${i + 1}. ${testUrls[i].replaceAll(token, 'TOKEN')}');
  }
  print('');

  // Tester chaque URL
  for (var i = 0; i < testUrls.length; i++) {
    final url = testUrls[i];
    print(
        'Test ${i + 1}/${testUrls.length}: ${url.replaceAll(token, 'TOKEN')}');
    await testWebSocketConnection(url);
    print('');
  }

  print('=== Tests terminés ===');
}

Future<void> testWebSocketConnection(String url) async {
  WebSocket? socket;

  try {
    print('  Tentative de connexion...');

    // Connexion simple sans headers personnalisés
    print('  Connexion simple sans headers...');

    // Tentative de connexion avec timeout
    socket = await WebSocket.connect(url).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('Timeout après 10 secondes');
      },
    );

    print('  ✓ Connexion établie avec succès!');
    print('  ReadyState: ${socket.readyState}');

    // Écouter les messages pendant 3 secondes
    print('  Écoute des messages pendant 3 secondes...');

    final subscription = socket.listen(
      (message) {
        print(
            '  ✓ Message reçu: ${message.toString().substring(0, message.toString().length > 100 ? 100 : message.toString().length)}...');
      },
      onError: (error) {
        print('  ✗ Erreur de stream: $error');
      },
      onDone: () {
        print('  ✓ Connexion fermée proprement');
      },
    );

    // Attendre un peu pour voir si on reçoit des messages
    await Future.delayed(const Duration(seconds: 3));

    // Fermer
    await subscription.cancel();
    await socket.close();
    print('  ✓ Test réussi - Connexion fermée');
  } on TimeoutException catch (e) {
    print('  ✗ Timeout: $e');
  } on SocketException catch (e) {
    print('  ✗ Erreur Socket: ${e.message}');
    if (e.osError != null) {
      print('  ✗ OS Error: ${e.osError}');
    }
  } on HttpException catch (e) {
    print('  ✗ Erreur HTTP: ${e.message}');
    print('  ✗ Cela indique généralement:');
    print('     - Code HTTP 502: Problème de proxy/gateway');
    print('     - Code HTTP 400: Mauvaise requête');
    print('     - Code HTTP 401/403: Authentification échouée');
    print('     - Le serveur n\'a pas accepté la mise à niveau WebSocket');
  } on WebSocketException catch (e) {
    print('  ✗ Erreur WebSocket: ${e.message}');
  } catch (e, stackTrace) {
    print('  ✗ Erreur inattendue: $e');
    print('  ✗ Type: ${e.runtimeType}');
    print(
        '  ✗ Stack trace: ${stackTrace.toString().split('\n').take(3).join('\n')}');
  } finally {
    try {
      await socket?.close();
    } catch (_) {}
  }
}
