import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/responsive_helper.dart';
import '../widgets/responsive_padding.dart';
import 'services/member_service.dart';
import 'tontine/select_tontine_view.dart';
import 'auth/register_view.dart';
import 'auth/forgot_password_view.dart';
import '../services/first_launch_service.dart';
import 'features_explanation_view.dart';
import '../theme/app_theme.dart';

class LoginView extends StatefulWidget {
  static const routeName = '/login';
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _memberService = MemberService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _memberService.init();
    _checkToken();
    _usernameController.value = const TextEditingValue(text: '');
    _passwordController.value = const TextEditingValue(text: '');
  }

  Future<void> _checkToken() async {
    final hasToken = await _memberService.hasValidToken();
    if (hasToken && mounted) {
      await Provider.of<AuthProvider>(context, listen: true).getProfile();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(SelectTontineView.routeName);
      }
    }
  }

  Future<void> _handleLogin() async {
    // Validation des champs
    if (_usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez saisir votre nom d\'utilisateur'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez saisir votre mot de passe'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success =
          await Provider.of<AuthProvider>(context, listen: false).login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (success) {
        if (mounted) {
          // Vérifier si c'est le premier lancement
          final firstLaunchService = FirstLaunchService();
          if (firstLaunchService.isFirstLaunch()) {
            // Premier lancement: afficher les explications
            await firstLaunchService.markAppAsLaunched();
            Navigator.of(context).pushReplacementNamed(
              FeaturesExplanationView.routeName,
            );
          } else {
            // Lancement suivant: aller à SelectTontineView
            Navigator.of(context)
                .pushReplacementNamed(SelectTontineView.routeName);
          }
        }
      } else {
        if (mounted) {
          // Afficher un message d'erreur si la connexion échoue
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  const Text('Nom d\'utilisateur ou mot de passe incorrect'),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsivePadding(
            all: 24.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: ResponsiveHelper.getAdaptiveValue(
                    context,
                    small: 8.0,
                    medium: 16.0,
                    large: 20.0,
                  ),
                ),
                // Illustration de connexion
                Container(
                  height: ResponsiveHelper.getAdaptiveValue(
                    context,
                    small: 150.0,
                    medium: 220.0,
                    large: 280.0,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/illustration_login.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getAdaptiveValue(
                    context,
                    small: 16.0,
                    medium: 24.0,
                    large: 32.0,
                  ),
                ),

                // Titre
                Text(
                  'Connexion',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: ResponsiveHelper.getAdaptiveValue(
                      context,
                      small: 26.0,
                      medium: 28.0,
                      large: 30.0,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: ResponsiveHelper.getAdaptiveValue(
                    context,
                    small: 4.0,
                    medium: 6.0,
                    large: 8.0,
                  ),
                ),
                Text(
                  'Connectez-vous à votre compte',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: ResponsiveHelper.getAdaptiveValue(
                      context,
                      small: 14.0,
                      medium: 15.0,
                      large: 16.0,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: ResponsiveHelper.getAdaptiveValue(
                    context,
                    small: 20.0,
                    medium: 32.0,
                    large: 40.0,
                  ),
                ),

                // Formulaire avec largeur contrainte
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveHelper.getAdaptiveValue(
                      context,
                      small: double.infinity,
                      medium: 450.0,
                      large: 500.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Champ nom d'utilisateur
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                          color: AppColors.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Nom d\'utilisateur',
                            prefixIcon: const Icon(Icons.person_outline,
                                color: AppColors.primary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            labelStyle:
                                const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getAdaptiveValue(
                          context,
                          small: 12.0,
                          medium: 16.0,
                          large: 20.0,
                        ),
                      ),

                      // Champ mot de passe
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.border,
                          ),
                          color: AppColors.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: AppColors.primary),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            labelStyle:
                                const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getAdaptiveValue(
                          context,
                          small: 16.0,
                          medium: 24.0,
                          large: 32.0,
                        ),
                      ),

                      // Bouton de connexion
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.primary.withValues(alpha: 0.8)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: FilledButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor:
                                        AppColors.textLight,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    'Se connecter',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getAdaptiveValue(
                    context,
                    small: 12.0,
                    medium: 18.0,
                    large: 24.0,
                  ),
                ),

                // Lien mot de passe oublié
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(ForgotPasswordView.routeName);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Mot de passe oublié ?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getAdaptiveValue(
                    context,
                    small: 4.0,
                    medium: 10.0,
                    large: 16.0,
                  ),
                ),

                // Lien inscription
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(RegisterView.routeName);
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Pas encore de compte ? ',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: 'S\'inscrire',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getAdaptiveValue(
                    context,
                    small: 8.0,
                    medium: 14.0,
                    large: 20.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
