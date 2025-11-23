import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_view.dart';

class FeaturesExplanationView extends StatefulWidget {
  static const routeName = '/features_explanation';

  const FeaturesExplanationView({super.key});

  @override
  State<FeaturesExplanationView> createState() =>
      _FeaturesExplanationViewState();
}

class _FeaturesExplanationViewState extends State<FeaturesExplanationView>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  final List<FeatureItem> features = [
    FeatureItem(
      title: '🎉 Bienvenue dans Tontine',
      description:
          'Une application complète pour gérer vos tontines (épargne solidaire) de manière simple et transparente.',
      icon: Icons.emoji_events,
      color: Colors.blue,
      details: [
        'Gestion facile des contributions',
        'Suivi transparent des transactions',
        'Distribution équitable des parts',
      ],
    ),
    FeatureItem(
      title: '💰 Gérer les Tontines',
      description:
          'Créez une tontine, invitez vos amis et gérez collectivement les cotisations.',
      icon: Icons.group_add,
      color: Colors.green,
      details: [
        'Créer une nouvelle tontine',
        'Inviter des membres',
        'Définir les contributions',
      ],
    ),
    FeatureItem(
      title: '💳 Gestion Financière',
      description:
          'Enregistrez vos contributions et suivez toutes les transactions en temps réel.',
      icon: Icons.payment,
      color: Colors.orange,
      details: [
        'Enregistrer les contributions',
        'Consulter l\'historique',
        'Voir votre solde actuel',
      ],
    ),
    FeatureItem(
      title: '🏦 Demander un Prêt',
      description:
          'Besoin d\'un prêt ? Demandez à votre tontine avec des conditions convenues.',
      icon: Icons.account_balance,
      color: Colors.purple,
      details: [
        'Demander un prêt',
        'Fixer les conditions',
        'Gérer le remboursement',
      ],
    ),
    FeatureItem(
      title: '📊 Rapports et Statistiques',
      description:
          'Consultez des rapports détaillés et des statistiques pour mieux comprendre votre tontine.',
      icon: Icons.bar_chart,
      color: Colors.red,
      details: [
        'Graphiques et statistiques',
        'Historique complet',
        'Rapports téléchargeables',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: features.length,
            itemBuilder: (context, index) {
              return _buildFeaturePage(features[index]);
            },
          ),
          // Skip button (haut droit)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                _goToDashboard();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Passer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          // Navigation buttons (bas)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigation(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePage(FeatureItem feature) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            feature.color.withValues(alpha: 0.1),
            feature.color.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      feature.color,
                      feature.color.withValues(alpha: 0.6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: feature.color.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  feature.icon,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              // Title
              Text(
                feature.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                feature.description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.black54,
                      height: 1.6,
                    ),
              ),
              const SizedBox(height: 32),
              // Details
              ...feature.details.map((detail) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: feature.color,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            detail,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.black87,
                                ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              features.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 10,
                    width: _currentIndex == index ? 28 : 10,
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? AppTheme.lightTheme.primaryColor
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Buttons
          Row(
            children: [
              // Previous button
              if (_currentIndex > 0)
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppTheme.lightTheme.primaryColor,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(
                      'Précédent',
                      style: TextStyle(
                        color: AppTheme.lightTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              if (_currentIndex > 0) const SizedBox(width: 12),
              // Next button
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_currentIndex < features.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _goToDashboard();
                    }
                  },
                  child: Text(
                    _currentIndex == features.length - 1
                        ? 'Commencer'
                        : 'Suivant',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress indicator
          Text(
            'Étape ${_currentIndex + 1} / ${features.length}',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.black45,
                ),
          ),
        ],
      ),
    );
  }

  void _goToDashboard() {
    Navigator.of(context).pushReplacementNamed(DashboardView.routeName);
  }
}

class FeatureItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> details;

  FeatureItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.details,
  });
}
