import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tontine_v2/src/models/member.dart';
import 'package:tontine_v2/src/providers/auth_provider.dart';
import 'package:tontine_v2/src/widgets/menu_widget.dart';

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
        print("member_account: ${member}");
        final bool isPresident = member?.user?.roles?.contains('PRESIDENT') ?? false;

        return Scaffold(
          appBar: AppBar(
            title: Text(isPresident ? 'Administration' : 'Mon compte'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfoSection(member),
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

  Widget _buildUserInfoSection(Member? member) {
    return Card(
      child: Padding(
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
              title: Text('${member?.firstName ?? ''} ${member?.lastName ?? ''}'),
              subtitle: const Text('Nom et prénom'),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(member?.email ?? ''),
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
