import 'package:get_storage/get_storage.dart';

import '../../providers/models/enum/available_language.dart';

class LanguageService {
  static const String languageKey = 'selected_language'; 

  Future<void> saveSelectedLanguage(AvailableLanguage languageCode) async {
    final box = GetStorage();
    await box.write(languageKey, languageCode.name);
  }

  Future<AvailableLanguage?> getSelectedLanguage() async {
    final box = GetStorage();
    final languageCode = box.read(languageKey);
    return AvailableLanguage.values.firstWhere((e) => e.name == languageCode);
  }
}