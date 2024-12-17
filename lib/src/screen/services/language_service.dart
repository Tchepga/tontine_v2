import 'package:get_storage/get_storage.dart';

import '../../models/enum/available_language.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';

  Future<void> saveSelectedLanguage(AvailableLanguage languageCode) async {
    final box = GetStorage();
    await box.write(_languageKey, languageCode.name);
  }

  Future<AvailableLanguage?> getSelectedLanguage() async {
    final box = GetStorage();
    final languageCode = box.read(_languageKey);
    return AvailableLanguage.values.firstWhere((e) => e.name == languageCode);
  }
}