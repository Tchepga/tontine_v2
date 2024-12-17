import 'package:flutter/material.dart';

import '../models/enum/available_language.dart';
import 'login_view.dart';
import 'services/language_service.dart';

class SelectedLanguageView extends StatelessWidget {
  SelectedLanguageView({super.key});
  static const routeName = '/selected-language';
  final _languageService = LanguageService();

  void _saveSelectedLanguage(AvailableLanguage languageCode) async {
    await _languageService.saveSelectedLanguage(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          
          children: [
            const Text('Choisir la langue',
              style: TextStyle(
                fontSize: 16
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                _saveSelectedLanguage(AvailableLanguage.fr);
                Navigator.of(context)
                    .pushReplacementNamed(LoginView.routeName);
              },
              child: const Text('Français'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveSelectedLanguage(AvailableLanguage.en);
                Navigator.of(context)
                    .pushReplacementNamed(LoginView.routeName);
              },
              child: const Text('Anglais'),
            ),
          ],
        ),
      ),
    );
  }
}
