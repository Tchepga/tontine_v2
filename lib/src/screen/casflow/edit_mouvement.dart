import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/deposit.dart';
import '../../models/enum/deposit_reason.dart';
import '../../models/enum/status_deposit.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tontine_provider.dart';
import '../../models/member.dart';
import '../services/dto/deposit_dto.dart';

class EditMouvement extends StatefulWidget {
  final Deposit? deposit;

  const EditMouvement({super.key, this.deposit});

  @override
  State<EditMouvement> createState() => _EditMouvementState();
}

class _EditMouvementState extends State<EditMouvement> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  Member? _selectedAuthor;
  DepositReason _selectedReason = DepositReason.VERSEMENT;
  List<DepositReason> depositReasons = DepositReason.values.toList();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      setState(() {
        _selectedAuthor = widget.deposit?.author;
      });
    });
    if (widget.deposit != null) {
      _amountController.text = widget.deposit!.amount.toString();
      _selectedReason = depositReasonFromString(widget.deposit!.reasons ?? '');
      _selectedAuthor = widget.deposit!.author;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, TontineProvider>(
      builder: (context, authProvider, tontineProvider, child) {
        final currentTontine = tontineProvider.currentTontine;
        final isPresident = authProvider.isPresident();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Nouveau mouvement'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Montant',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un montant';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (isPresident) ...[
                    DropdownButtonFormField<Member>(
                      value: _selectedAuthor,
                      decoration: const InputDecoration(
                        labelText: 'Auteur',
                      ),
                      items: currentTontine?.members.map((member) {
                        return DropdownMenuItem<Member>(
                          value: member,
                          child: Text('${member.firstname} ${member.lastname}'),
                        );
                      }).toList() ?? [],
                      onChanged: (Member? value) {
                        setState(() {
                          _selectedAuthor = currentTontine?.members.firstWhere(
                            (m) => m.id == value?.id,
                            orElse: () => value!,
                          );
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner un auteur';
                        }
                        return null;
                      },
                      selectedItemBuilder: (BuildContext context) {
                        return currentTontine?.members.map<Widget>((Member member) {
                          return Text('${member.firstname} ${member.lastname}');
                        }).toList() ?? [];
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  DropdownButtonFormField<DepositReason>(
                    value: _selectedReason,
                    decoration: const InputDecoration(
                      labelText: 'Raison',
                    ),
                    items: DepositReason.values.map((reason) {
                      return DropdownMenuItem(
                        value: reason,
                        child: Text(reason.displayName),
                      );
                    }).toList(),
                    onChanged: (DepositReason? value) {
                      setState(() {
                        _selectedReason = value ?? DepositReason.VERSEMENT;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await _handleSubmit(context, tontineProvider);
                    },
                    child: const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit(
      BuildContext context, TontineProvider tontineProvider) async {
    final currentTontine = tontineProvider.currentTontine;
    if (_formKey.currentState!.validate() &&
        _selectedAuthor != null &&
        currentTontine != null &&
        _selectedAuthor?.id != null) {
      final depositDto = CreateDepositDto(
        amount: double.parse(_amountController.text),
        currency: currentTontine.cashFlow.currency,
        memberId: _selectedAuthor!.id!,
        status: StatusDeposit.PENDING,
        cashFlowId: currentTontine.cashFlow.id,
        reasons: _selectedReason.displayName,
      );

      try {
        if (widget.deposit != null) {
          await tontineProvider.updateDeposit(
            currentTontine.id,
            widget.deposit!.id,
            depositDto,
          );
        } else {
          await tontineProvider.createDeposit(
            currentTontine.id,
            depositDto,
          );
        }
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green[300],
            content: Text(widget.deposit != null 
                ? 'Mouvement modifié avec succès'
                : 'Mouvement créé avec succès'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erreur lors de l\'opération'),
          duration: Duration(seconds: 5),
        ));
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
