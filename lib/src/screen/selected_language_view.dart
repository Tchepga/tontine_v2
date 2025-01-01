import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tontine_v2/src/screen/services/member_service.dart';
import '../models/enum/available_language.dart';
import 'dashboard_view.dart';
import 'login_view.dart';
import 'services/language_service.dart';

class SelectedLanguageView extends StatefulWidget {
  static const routeName = '/';
  const SelectedLanguageView({super.key});

  @override
  State<SelectedLanguageView> createState() => _SelectedLanguageViewState();
}

class _SelectedLanguageViewState extends State<SelectedLanguageView> {
  final _languageService = LanguageService();
  final _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    _checkLanguage();
  }

  Future<void> _checkLanguage() async {
    final hasLanguage = await _storage.read(LanguageService.languageKey) != null;
    final token = await _storage.read(MemberService.KEY_TOKEN);
    if (hasLanguage && mounted) {
      if(token != null) {
        Navigator.of(context).pushReplacementNamed(DashboardView.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(LoginView.routeName);
      }
    }
  }

  void _saveSelectedLanguage(AvailableLanguage language) async {
    await _languageService.saveSelectedLanguage(language);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(LoginView.routeName);
    }
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
