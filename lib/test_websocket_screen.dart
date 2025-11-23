import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

/// Écran de test WebSocket intégré dans l'application
///
/// Ajoutez cette route dans votre application pour tester
class WebSocketTestScreen extends StatefulWidget {
  const WebSocketTestScreen({Key? key}) : super(key: key);

  @override
  State<WebSocketTestScreen> createState() => _WebSocketTestScreenState();
}

class _WebSocketTestScreenState extends State<WebSocketTestScreen> {
  final List<String> _logs = [];
  bool _isRunning = false;

  // Configuration
  static const baseUrl = 'api.tontine.devcoorp.net';
  static const token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InVzZXJuYW1lIiwicm9sZSI6WyJQUkVTSURFTlQiXSwiaWF0IjoxNzYzNDEyMTM2LCJleHAiOjE3NjM0OTg1MzZ9.HJBJrVXcE28IFTgDYOKYdObUqx8RIC8RKWl9G9JN-oQ';

  void _addLog(String message) {
    if (mounted) {
      setState(() {
        _logs.add('[${DateTime.now().toString().substring(11, 19)}] $message');
      });
    }
    print(message);
  }

  Future<void> _runTests() async {
    setState(() {
      _isRunning = true;
      _logs.clear();
    });

    _addLog('=== Début des tests WebSocket ===\n');

    // Liste des URLs à tester
    final testUrls = [
      'wss://$baseUrl?token=$token',
      'wss://$baseUrl/?token=$token',
      'wss://$baseUrl/ws?token=$token',
      'wss://$baseUrl/socket?token=$token',
      'wss://$baseUrl/api?token=$token',
      'ws://$baseUrl?token=$token',
    ];

    _addLog('URLs à tester:');
    for (var i = 0; i < testUrls.length; i++) {
      _addLog('  ${i + 1}. ${testUrls[i].replaceAll(token, 'TOKEN***')}');
    }
    _addLog('');

    // Tester chaque URL
    for (var i = 0; i < testUrls.length; i++) {
      final url = testUrls[i];
      _addLog('\nTest ${i + 1}/${testUrls.length}:');
      _addLog(url.replaceAll(token, 'TOKEN***'));
      await _testWebSocketConnection(url);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _addLog('\n=== Tests terminés ===');

    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _testWebSocketConnection(String url) async {
    WebSocket? socket;

    try {
      _addLog('  → Tentative de connexion...');
      _addLog('  → Connexion simple sans headers personnalisés');

      socket = await WebSocket.connect(url).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          throw TimeoutException('Timeout après 8 secondes');
        },
      );

      _addLog('  ✓ SUCCÈS - Connexion établie!');
      _addLog('  ✓ ReadyState: ${socket.readyState}');

      // Écouter pendant 2 secondes
      bool receivedMessage = false;

      final subscription = socket.listen(
        (message) {
          receivedMessage = true;
          final preview = message.toString().substring(0,
              message.toString().length > 80 ? 80 : message.toString().length);
          _addLog('  ✓ Message: $preview...');
        },
        onError: (error) {
          _addLog('  ✗ Erreur stream: $error');
        },
      );

      await Future.delayed(const Duration(seconds: 2));

      if (!receivedMessage) {
        _addLog('  ℹ Aucun message reçu (normal si pas d\'événement)');
      }

      await subscription.cancel();
      await socket.close();
      _addLog('  ✓ Connexion fermée proprement');
    } on TimeoutException catch (e) {
      _addLog('  ✗ TIMEOUT: $e');
    } on SocketException catch (e) {
      _addLog('  ✗ ERREUR SOCKET: ${e.message}');
      if (e.osError != null) {
        _addLog('  ✗ OS Error: ${e.osError}');
      }
    } on HttpException catch (e) {
      _addLog('  ✗ ERREUR HTTP: ${e.message}');
      if (e.message.contains('502')) {
        _addLog('  ℹ Code 502 = Problème de proxy/gateway');
      } else if (e.message.contains('401') || e.message.contains('403')) {
        _addLog('  ℹ Authentification refusée');
      }
    } catch (e) {
      _addLog('  ✗ ERREUR: $e (${e.runtimeType})');
    } finally {
      try {
        await socket?.close();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test WebSocket'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isRunning ? null : _runTests,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
                child: _isRunning
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Test en cours...',
                              style: TextStyle(color: Colors.white)),
                        ],
                      )
                    : const Text('Lancer les tests',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _logs.isEmpty
                ? const Center(
                    child: Text(
                      'Appuyez sur le bouton pour lancer les tests',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      Color textColor = Colors.black87;

                      if (log.contains('✓')) {
                        textColor = Colors.green[700]!;
                      } else if (log.contains('✗')) {
                        textColor = Colors.red[700]!;
                      } else if (log.contains('ℹ')) {
                        textColor = Colors.orange[700]!;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          log,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: textColor,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
