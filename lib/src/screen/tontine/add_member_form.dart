
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../services/dto/member_dto.dart';
import '../services/member_service.dart';

class AddMemberForm extends StatefulWidget {
  final Function(CreateMemberDto) onSubmit;
  final bool showPassword;

  const AddMemberForm({
    super.key,
    required this.onSubmit,
    this.showPassword = false,
  });

  @override
  State<AddMemberForm> createState() => _AddMemberFormState();
}

class _AddMemberFormState extends State<AddMemberForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController(text: 'FR');
  String _completePhoneNumber = '';
  final _memberService = MemberService();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showPassword) ...[
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe*',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
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
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Nom d\'utilisateur*',
              border: OutlineInputBorder(),
            ),
            readOnly: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est requis';
              }
              // Assuming there's a function to check if a user with this username already exists
              checkIfUserExists(value).then((bool userExists) {
                if (userExists) {
                  return 'Un utilisateur avec ce nom d\'utilisateur existe déjà';
                }
              });
              return null;
            },
          ),
          TextFormField(
            controller: _firstnameController,
            decoration: const InputDecoration(
              labelText: 'Prénom*',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastnameController,
            decoration: const InputDecoration(
              labelText: 'Nom*',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final RegExp emailRegExp = RegExp(
                  r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$',
                );
                if (!emailRegExp.hasMatch(value)) {
                  return 'Email invalide';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          IntlPhoneField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Téléphone*',
              border: OutlineInputBorder(),
            ),
            initialCountryCode: 'FR',
            onChanged: (phone) {
              _completePhoneNumber = phone.completeNumber;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _countryController,
            decoration: const InputDecoration(
              labelText: 'Pays',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            onPressed: _handleSubmit,
            child: const Text('Ajouter le membre'),
          ),
        ],
      ),
    );
  }

  Future<bool> checkIfUserExists(String username) async {
    final user = await _memberService.getUserByUsername(username);
    return user != null;
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final memberDto = CreateMemberDto(
        username: '${_firstnameController.text.toLowerCase()}.${_lastnameController.text.toLowerCase()}',
        password: widget.showPassword ? _passwordController.text : null,
        firstname: _firstnameController.text,
        lastname: _lastnameController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        phone: _completePhoneNumber.isNotEmpty
            ? _completePhoneNumber
            : _phoneController.text,
        country: _countryController.text,
      );

      widget.onSubmit(memberDto);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }
}
