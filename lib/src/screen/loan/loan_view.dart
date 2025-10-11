import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tontine_v2/src/providers/models/enum/status_loan.dart';
import 'package:tontine_v2/src/providers/models/member.dart';
import '../../providers/models/loan.dart';
import '../../providers/models/tontine.dart';
import '../../providers/loan_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tontine_provider.dart';
import '../../widgets/menu_widget.dart';
import 'package:intl/intl.dart';

import '../services/dto/loan_dto.dart';

class LoanView extends StatefulWidget {
  static const routeName = '/loan';
  const LoanView({super.key});

  @override
  State<LoanView> createState() => _LoanViewState();
}

class _LoanViewState extends State<LoanView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      final loanProvider = Provider.of<LoanProvider>(context, listen: false);
      final tontineProvider =
          Provider.of<TontineProvider>(context, listen: false);
      await loanProvider.loadLoans(tontineProvider.currentTontine!.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<TontineProvider, LoanProvider, AuthProvider>(
      builder: (context, tontineProvider, loanProvider, authProvider, child) {
        final currentTontine = tontineProvider.currentTontine;
        final currentUser = authProvider.currentUser;
        final loans = loanProvider.loans;

        // Séparer les prêts de l'utilisateur des autres prêts
        final myLoans =
            loans.where((loan) => loan.author.id == currentUser?.id).toList();
        final otherLoans =
            loans.where((loan) => loan.author.id != currentUser?.id).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Prêts'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Taux: ${currentTontine?.config.defaultLoanRate ?? 0}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Taux d\'intérêt actuel',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (myLoans.isNotEmpty) ...[
                const Text(
                  'Mes prêts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...myLoans.map((loan) =>
                    _buildLoanCard(loan, true, currentTontine, currentUser)),
                const SizedBox(height: 24),
              ],
              if (otherLoans.isNotEmpty) ...[
                const Text(
                  'Autres prêts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...otherLoans.map((loan) =>
                    _buildLoanCard(loan, false, currentTontine, currentUser)),
              ],
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'loan_fab',
            onPressed: () =>
                _showCreateLoanDialog(context, tontineProvider, loanProvider),
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: const MenuWidget(),
        );
      },
    );
  }

  Widget _buildLoanCard(
      Loan loan, bool isMyLoan, Tontine? currentTontine, Member? currentUser) {
    Color getStatusColor() {
      switch (loan.status) {
        case StatusLoan.PENDING:
          return Colors.orange;
        case StatusLoan.APPROVED:
          return Colors.green;
        case StatusLoan.REJECTED:
          return Colors.red;
        case StatusLoan.PAID:
          return Colors.blue;
        case StatusLoan.CANCELLED:
          return Colors.grey;
      }
    }

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              '${loan.amount} ${loan.currency.name}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Emprunteur: ${loan.author.firstname} ${loan.author.lastname}'),
                Text(
                    'Échéance: ${DateFormat('dd/MM/yyyy').format(loan.redemptionDate)}'),
                Chip(
                  label: Text('Statut: ${loan.status.displayName}'),
                  backgroundColor: getStatusColor(),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                Text(
                    'Votes: ${loan.voters?.length ?? 0}/${currentTontine?.members.length ?? 0}'),
              ],
            ),
            trailing: IconButton(
              icon: loan.status == StatusLoan.PENDING
                  ? Icon(
                      loan.voters?.any((voter) => voter == currentUser?.id) ??
                              false
                          ? Icons.how_to_vote
                          : Icons.how_to_vote_outlined,
                      color: getStatusColor(),
                    )
                  : Icon(Icons.check_circle, color: getStatusColor()),
              onPressed: loan.status == StatusLoan.PENDING
                  ? () => _handleVote(loan)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVote(Loan loan) async {
    try {
      await Provider.of<LoanProvider>(context, listen: false).voteLoan(loan.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vote enregistré')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors du vote'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCreateLoanDialog(BuildContext context,
      TontineProvider tontineProvider, LoanProvider loanProvider) {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final redemptionDateController = TextEditingController();
    final currentTontine = tontineProvider.currentTontine;
    DateTime selectedDate = DateTime.now()
        .add(const Duration(days: 30)); // Date par défaut à 30 jours

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nouveau prêt'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Montant',
                    suffixText: '€',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le montant est requis';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Montant invalide';
                    }
                    if (amount < currentTontine!.config.minLoanAmount) {
                      return 'Le montant minimum est de ${currentTontine.config.minLoanAmount} €';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: redemptionDateController,
                  decoration: const InputDecoration(
                    labelText: 'Date d\'échéance',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      selectedDate = picked;
                      redemptionDateController.text =
                          DateFormat('dd/MM/yyyy').format(picked);
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La date d\'échéance est requise';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Taux d\'intérêt: ${currentTontine?.config.defaultLoanRate}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (!mounted) return;
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate() &&
                    currentTontine != null) {
                  try {
                    if (!mounted) return;
                    final loanDto = CreateLoanDto(
                      amount: double.parse(amountController.text),
                      currency: currentTontine.cashFlow.currency,
                      tontineId: currentTontine.id,
                      redemptionDate: selectedDate,
                    );

                    await loanProvider.createLoan(loanDto);
                    await loanProvider.loadLoans(currentTontine.id);

                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Prêt créé avec succès. Il devra être validé par la suite'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  } catch (e) {
                    if (!mounted) return;
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erreur lors de la création du prêt'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Créer'),
            ),
          ],
        );
      },
    );
  }
}
