import 'package:flutter/material.dart';
import 'dashboard_view.dart';
import 'services/member_service.dart';
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
    _memberService.init(); // Initialiser GetStorage
    _checkToken(); // Ajouter la vérification du token
  }



  Future<void> _checkToken() async {
    final hasToken = await _memberService.hasValidToken();
    if (hasToken && mounted) {
      Navigator.of(context).pushReplacementNamed(DashboardView.routeName);
    }
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _memberService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (success) {
        // Navigation vers la page principale si la connexion réussit
        Navigator.of(context).pushReplacementNamed(DashboardView.routeName);
      } else {
        // Afficher un message d'erreur si la connexion échoue
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec de la connexion. Veuillez réessayer.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Une erreur est survenue. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/illustration_login.png'),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nom d\'utilisateur',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Se connecter'),
                  ),
          ]
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
