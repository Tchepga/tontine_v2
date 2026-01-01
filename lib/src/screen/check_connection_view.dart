import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'services/app_service.dart';
import 'selected_language_view.dart';
import '../utils/responsive_helper.dart';

class CheckConnectionView extends StatefulWidget {
  static const routeName = '/check-connection';
  const CheckConnectionView({super.key});

  @override
  State<CheckConnectionView> createState() => _CheckConnectionViewState();
}

class _CheckConnectionViewState extends State<CheckConnectionView> {
  final _appService = AppService();
  final _logger = Logger('CheckConnectionView');
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    try {
      final isAvailable = await _appService.checkServerAvailability();
      if (mounted) {
        if (isAvailable) {
          Navigator.of(context).pushReplacementNamed(SelectedLanguageView.routeName);
        } else {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      _logger.severe('Error checking connection: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Largeur maximale adaptative selon la taille de l'écran
    final maxWidth = ResponsiveHelper.getAdaptiveValue(
      context,
      small: double.infinity, // Pas de limite sur mobile
      medium: 600.0, // Limite à 600px sur tablette
      large: 500.0, // Limite à 500px sur desktop
    );
    
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Text('Vérification de la connexion...'),
              ] else if (_hasError) ...[
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Problème de connexion ou service indisponible',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Veuillez vérifier votre connexion et réessayer plus tard',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _hasError = false;
                    });
                    _checkConnection();
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ],
            ),
          ),
        ),
      ),
    );
  }
} 