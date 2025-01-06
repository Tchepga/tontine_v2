import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tontine_v2/src/providers/models/enum/role.dart';
import 'package:tontine_v2/src/providers/models/member.dart';
import 'package:tontine_v2/src/providers/auth_provider.dart';
import 'package:tontine_v2/src/widgets/menu_widget.dart';

import '../services/dto/member_dto.dart';
import '../services/member_service.dart';

class AccountView extends StatelessWidget {
  const AccountView({super.key});
  static const routeName = '/account';

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        final member = authProvider.currentUser;
        final bool isPresident = member?.user?.roles?.contains(Role.PRESIDENT) ?? false;

        return Scaffold(
          appBar: AppBar(
            title: Text(isPresident ? 'Administration' : 'Mon compte'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfoSection(member, context),
                const SizedBox(height: 20),
                if (isPresident) _buildPresidentSection(context),
                _buildCommonOptions(context),
              ],
            ),
          ),
        bottomNavigationBar: const MenuWidget(),
        );
      },
    );
  }

  Widget _buildUserInfoSection(Member? member, BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informations personnelles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('${member?.firstname ?? ''} ${member?.lastname ?? ''}'),
                  subtitle: const Text('Nom et prénom'),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(member?.email ?? 'Non renseigné'),
                  subtitle: const Text('Email'),
                ),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(member?.phone ?? 'Non renseigné'),
                  subtitle: const Text('Téléphone'),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Éditer les informations personnelles'),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Prénom',
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(text: member?.firstname),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Nom',
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(text: member?.lastname),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(text: member?.email),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Téléphone',
                                border: OutlineInputBorder(),
                              ),
                              controller: TextEditingController(text: member?.phone),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Annuler'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Sauvegarder'),
                          onPressed: () {
                            final firstnameController = TextEditingController(text: member?.firstname);
                            final lastnameController = TextEditingController(text: member?.lastname);
                            final emailController = TextEditingController(text: member?.email);
                            final phoneController = TextEditingController(text: member?.phone);

                            final updatedMember = CreateMemberDto(
                              firstname: firstnameController.text,
                              lastname: lastnameController.text,
                              email: emailController.text,
                              phone: phoneController.text,
                              country: member?.country ?? '',
                              roles: member?.user?.roles ?? [],
                            );

                            MemberService().updateMemberInfo(updatedMember);

                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresidentSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Administration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Gestion des utilisateurs'),
              onTap: () {
                // Navigation vers la gestion des utilisateurs
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configuration de la tontine'),
              onTap: () {
                // Navigation vers la configuration de la tontine
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Statistiques'),
              onTap: () {
                // Navigation vers les statistiques
              },
            ),

           
          ],
        ),
      ),
    );
  }

  Widget _buildCommonOptions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Modifier le mot de passe'),
              onTap: () {
                // Navigation vers la modification du mot de passe
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier mes informations'),
              onTap: () {
                // Navigation vers la modification des informations
              },
            ),
          ],
        ),
      ),
    );
  }
}
