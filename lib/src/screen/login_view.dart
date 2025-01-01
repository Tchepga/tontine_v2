import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'services/member_service.dart';
import 'tontine/select_tontine_view.dart';
import 'auth/register_view.dart';

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
    _usernameController.value = const TextEditingValue(text: 'username');
    _passwordController.value = const TextEditingValue(text: 'password');
  }

  Future<void> _checkToken() async {
    final hasToken = await _memberService.hasValidToken();
    if (hasToken && mounted) {
      await Provider.of<AuthProvider>(context, listen: false).getProfile();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(SelectTontineView.routeName);
      }
    }
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await Provider.of<AuthProvider>(context, listen: false).login(
        _usernameController.text,
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                  onPressed: () {
                    _handleLogin();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Se connecter'),
                ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushReplacementNamed(RegisterView.routeName);
            },
            child: const Text('Pas encore de compte ? S\'inscrire'),
          ),
        ]),
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
