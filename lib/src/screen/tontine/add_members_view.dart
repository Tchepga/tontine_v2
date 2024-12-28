import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tontine_provider.dart';
import '../dashboard_view.dart';
import './add_member_form.dart';

class AddMembersView extends StatefulWidget {
  static const routeName = '/add-members';
  const AddMembersView({super.key});

  @override
  State<AddMembersView> createState() => _AddMembersViewState();
}

class _AddMembersViewState extends State<AddMembersView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<TontineProvider>(
      builder: (context, tontineProvider, child) {
        final currentTontine = tontineProvider.currentTontine;
        if (currentTontine == null) return const SizedBox();

        final remainingMembers = currentTontine.config.countMaxMember - currentTontine.members.length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Ajouter des membres'),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          currentTontine.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Il manque $remainingMembers membres pour compléter la tontine',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: currentTontine.members.length / currentTontine.config.countMaxMember,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: AddMemberForm(
                    onSubmit: (memberDto) async {
                      try {
                        // set default password
                        memberDto = memberDto.copyWith(password: 'changeme');
                        await tontineProvider.addMemberToTontine(
                          currentTontine.id,
                          memberDto,
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Membre ajouté avec succès'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erreur lors de l\'ajout du membre'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Membres actuels',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentTontine.members.length,
                  itemBuilder: (context, index) {
                    final member = currentTontine.members[index];
                    return ListTile(
                      title: Text('${member.firstname} ${member.lastname}'),
                      subtitle: Text(member.user?.username ?? ''),
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: remainingMembers == 0
                  ? () {
                      Navigator.of(context).pushReplacementNamed(DashboardView.routeName);
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
                disabledBackgroundColor: Colors.grey,
              ),
              child: const Text('Continuer vers le tableau de bord'),
            ),
          ),
        );
      },
    );
  }
} 