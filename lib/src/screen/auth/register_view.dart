import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login_view.dart';
import '../services/dto/member_dto.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RegisterView extends StatefulWidget {
  static const routeName = '/register';
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController(text: 'username');
  final _passwordController = TextEditingController(text: 'password');
  final _confirmPasswordController = TextEditingController(text: 'password');
  final _firstnameController = TextEditingController(text: 'firstname');
  final _lastnameController = TextEditingController(text: 'lastname');
  final _emailController = TextEditingController(text: 'email@email.com');
  final _phoneController = TextEditingController(text: '6666666666');
  final _countryController = TextEditingController(text: 'FR');
  String _completePhoneNumber = '';
  bool _isLoading = false;
  Logger logger = Logger('RegisterView');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
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
                      child: SvgPicture.asset(
                          'assets/images/undraw_savings_uwjn.svg',
                          fit: BoxFit.contain,
                          width: 200,
                          height: 200),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Créer un compte',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rejoignez notre communauté de tontines',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withAlpha(60),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Nom d\'utilisateur',
                    icon: Icons.person_outline,
                    colorScheme: colorScheme,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ce champ est requis';
                      }
                      if (value.length < 3) {
                        return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _firstnameController,
                    label: 'Prénom',
                    icon: Icons.badge_outlined,
                    colorScheme: colorScheme,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ce champ est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _lastnameController,
                    label: 'Nom',
                    icon: Icons.badge_outlined,
                    colorScheme: colorScheme,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ce champ est requis';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    colorScheme: colorScheme,
                    validator: (value) {
                      final RegExp emailRegExp = RegExp(
                        r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$',
                      );
                      if (value != null &&
                          value.isNotEmpty &&
                          !emailRegExp.hasMatch(value)) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withAlpha(30),
                      ),
                      color: colorScheme.surface,
                    ),
                    child: IntlPhoneField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Téléphone',
                        prefixIcon: Icon(Icons.phone_outlined,
                            color: colorScheme.primary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        labelStyle: TextStyle(
                            color: colorScheme.onSurface.withAlpha(60)),
                      ),
                      initialCountryCode: 'FR',
                      onChanged: (phone) {
                        _completePhoneNumber = phone.completeNumber;
                      },
                      validator: (value) {
                        if (value == null || value.number.isEmpty) {
                          return 'Ce champ est requis';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _countryController,
                    label: 'Pays',
                    icon: Icons.flag_outlined,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primaryContainer.withAlpha(30),
                          colorScheme.secondaryContainer.withAlpha(20),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.outline.withAlpha(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.security, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Sécurité',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Mot de passe',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          colorScheme: colorScheme,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ce champ est requis';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirmer le mot de passe',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          colorScheme: colorScheme,
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
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
                            onPressed: _isLoading ? null : _handleRegister,
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
                              'S\'inscrire',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushReplacementNamed(LoginView.routeName);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: 'Déjà un compte ? ',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withAlpha(60),
                        ),
                        children: [
                          TextSpan(
                            text: 'Se connecter',
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: colorScheme.primary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: colorScheme.onSurface.withAlpha(60)),
        ),
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est requis';
              }
              if (controller == _usernameController && value.length < 3) {
                return 'Le nom d\'utilisateur doit contenir au moins 3 caractères';
              }
              if (controller == _emailController) {
                final RegExp emailRegExp = RegExp(
                  r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$',
                );
                if (value.isNotEmpty && !emailRegExp.hasMatch(value)) {
                  return 'Email invalide';
                }
              }
              return null;
            },
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final memberDto = CreateMemberDto(
          username: _usernameController.text,
          password: _passwordController.text,
          firstname: _firstnameController.text,
          lastname: _lastnameController.text,
          email: _emailController.text,
          phone: _completePhoneNumber,
          country: _countryController.text,
        );

        final statusCode =
            await Provider.of<AuthProvider>(context, listen: false)
                .registerPresident(memberDto);
        if (mounted) {
          switch (statusCode) {
            case 400:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Le nom d\'utilisateur existe déjà'),
                  backgroundColor: Colors.red,
                ),
              );
              break;
            case 201:
              Navigator.of(context).pushReplacementNamed(LoginView.routeName);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Inscription réussie. Vous pouvez vous connecter.'),
                  backgroundColor: Colors.green,
                ),
              );
              break;
            default:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Erreur lors de l\'inscription'),
                  backgroundColor: Colors.red,
                ),
              );
              break;
          }
        }
      } catch (e) {
        logger.severe('Error registering: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de l\'inscription'),
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
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }
}
