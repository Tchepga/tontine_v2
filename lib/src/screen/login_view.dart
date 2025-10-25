import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'services/member_service.dart';
import 'tontine/select_tontine_view.dart';
import 'auth/register_view.dart';
import 'auth/forgot_password_view.dart';

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
        const SnackBar(
          content: Text('Veuillez saisir votre nom d\'utilisateur'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir votre mot de passe'),
          backgroundColor: Colors.orange,
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
          Navigator.of(context)
              .pushReplacementNamed(SelectTontineView.routeName);
        }
      } else {
        if (mounted) {
          // Afficher un message d'erreur si la connexion échoue
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nom d\'utilisateur ou mot de passe incorrect'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Une erreur est survenue. Veuillez réessayer.'),
            backgroundColor: Colors.red,
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
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo ou illustration
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withAlpha(10),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/illustration_login.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Titre
                Text(
                  'Connexion',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous à votre compte',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withAlpha(60),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Champ nom d'utilisateur
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withAlpha(30),
                    ),
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Nom d\'utilisateur',
                      prefixIcon: Icon(Icons.person_outline,
                          color: colorScheme.primary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      labelStyle:
                          TextStyle(color: colorScheme.onSurface.withAlpha(60)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Champ mot de passe
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withAlpha(30),
                    ),
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon:
                          Icon(Icons.lock_outline, color: colorScheme.primary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      labelStyle:
                          TextStyle(color: colorScheme.onSurface.withAlpha(60)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Bouton de connexion
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      )
                    : Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withAlpha(80)
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withAlpha(30),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: FilledButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            'Se connecter',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 24),

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
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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
                        color: colorScheme.onSurface.withAlpha(60),
                      ),
                      children: [
                        TextSpan(
                          text: 'S\'inscrire',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
