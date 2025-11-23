import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../providers/models/enum/available_language.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../widgets/responsive_padding.dart';
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
    final hasLanguage =
        await _storage.read(LanguageService.languageKey) != null;
    if (hasLanguage && mounted) {
      Navigator.of(context).pushReplacementNamed(DashboardView.routeName);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsivePadding(
            all: 24.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ResponsiveSpacing(height: 40),
                // Logo de l'application
                Container(
                  height: ResponsiveHelper.getAdaptiveValue(
                    context,
                    small: 100.0,
                    medium: 120.0,
                    large: 140.0,
                  ),
                  width: ResponsiveHelper.getAdaptiveValue(
                    context,
                    small: 100.0,
                    medium: 120.0,
                    large: 140.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                ResponsiveSpacing(height: 40),

                // Titre
                Text(
                  'Choisir la langue',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                ResponsiveSpacing(height: 8),
                Text(
                  'Sélectionnez votre langue préférée',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                ResponsiveSpacing(height: 48),

                // Cartes de langues
                _buildLanguageCard(
                  context,
                  language: AvailableLanguage.fr,
                  title: 'Français',
                  subtitle: 'French',
                  icon: Icons.language,
                  color: const Color(0xFF002654), // Bleu français
                  onTap: () => _saveSelectedLanguage(AvailableLanguage.fr),
                ),
                ResponsiveSpacing(height: 20),
                _buildLanguageCard(
                  context,
                  language: AvailableLanguage.en,
                  title: 'English',
                  subtitle: 'Anglais',
                  icon: Icons.language,
                  color: const Color(0xFF012169), // Bleu anglais
                  onTap: () => _saveSelectedLanguage(AvailableLanguage.en),
                ),
                ResponsiveSpacing(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context, {
    required AvailableLanguage language,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final cardPadding = ResponsiveHelper.getAdaptivePadding(context, all: 20.0);
    final iconSize = ResponsiveHelper.getAdaptiveIconSize(context, base: 32.0);
    final titleFontSize = ResponsiveHelper.getAdaptiveValue(
      context,
      small: 18.0,
      medium: 20.0,
      large: 22.0,
    );
    final subtitleFontSize = ResponsiveHelper.getAdaptiveValue(
      context,
      small: 14.0,
      medium: 15.0,
      large: 16.0,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface,
                AppColors.surface.withValues(alpha: 0.8),
              ],
            ),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          padding: cardPadding,
          child: Row(
            children: [
              // Icône de langue
              Container(
                width: ResponsiveHelper.getAdaptiveValue(
                  context,
                  small: 56.0,
                  medium: 64.0,
                  large: 72.0,
                ),
                height: ResponsiveHelper.getAdaptiveValue(
                  context,
                  small: 56.0,
                  medium: 64.0,
                  large: 72.0,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: iconSize,
                ),
              ),
              SizedBox(
                width: ResponsiveHelper.getAdaptiveSpacing(context, base: 20.0),
              ),
              // Texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    ResponsiveSpacing(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Icône flèche
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primary,
                size: ResponsiveHelper.getAdaptiveIconSize(context, base: 20.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
