import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../providers/models/member.dart';
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
  final _passwordController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController(text: 'FR');
  String _completePhoneNumber = '';
  final _memberService = MemberService();
  final _searchUsernameController = TextEditingController();
  bool _isSearchMode = false;
  Member? _selectedMember;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            title: const Text('Rechercher un utilisateur existant'),
            value: _isSearchMode,
            onChanged: (bool value) {
              setState(() {
                _isSearchMode = value;
                _selectedMember = null;
                _searchUsernameController.clear();
                if (value) {
                  _clearFields();
                }
              });
            },
          ),
          const SizedBox(height: 16),

          if (_isSearchMode) ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _searchUsernameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom d\'utilisateur',
                      border: OutlineInputBorder(),
                      hintText: 'Entrez le nom d\'utilisateur',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    final member = await _memberService.getMemberByUsername(
                      _searchUsernameController.text,
                    );
                    setState(() {
                      _selectedMember = member;
                      if (_selectedMember != null) {
                        _firstnameController.text = _selectedMember?.firstname ?? '';
                        _lastnameController.text = _selectedMember?.lastname ?? '';
                        _emailController.text = _selectedMember?.email ?? '';
                        _phoneController.text = _selectedMember?.phone ?? '';
                        _countryController.text = _selectedMember?.country ?? '';
                      }
                    });
                  },
                ),
              ],
            ),
            if (_selectedMember != null)
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text('${_selectedMember?.firstname} ${_selectedMember?.lastname}'),
                  subtitle: Text(_selectedMember?.user?.username ?? ''),
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                ),
              ),
          ] else ...[
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
          ],

          const SizedBox(height: 24),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            onPressed: _handleSubmit,
            child: Text(_isSearchMode ? 'Ajouter le membre' : 'Créer et ajouter'),
          ),
        ],
      ),
    );
  }

  void _clearFields() {
    _firstnameController.clear();
    _lastnameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _countryController.text = 'FR';
  }

  Future<bool> checkIfUserExists(String username) async {
    final user = await _memberService.getUserByUsername(username);
    return user != null;
  }

  String _generateUsername() {
    return '${_firstnameController.text.toLowerCase()}.${_lastnameController.text.toLowerCase()}';
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_isSearchMode && _selectedMember != null) {
        final memberDto = CreateMemberDto(
          username: _selectedMember!.user?.username ?? '',
          firstname: _selectedMember?.firstname ?? '',
          lastname: _selectedMember?.lastname ?? '',
          email: _selectedMember?.email,
          phone: _selectedMember?.phone ?? '',
          country: _selectedMember?.country ?? 'FR',
        );
        widget.onSubmit(memberDto);
      } else {
        final username = _generateUsername();
        try {
          final userExists = await _memberService.getUserByUsername(username);
          
          if (userExists != null) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Un utilisateur avec ce nom existe déjà'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          final memberDto = CreateMemberDto(
            username: username,
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
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la vérification de l\'utilisateur'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
    _searchUsernameController.dispose();
    super.dispose();
  }
}
