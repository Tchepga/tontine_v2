import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../providers/models/deposit.dart';
import '../../../providers/tontine_provider.dart';
import 'deposit_details_dialog.dart';

class DepositListItem extends StatelessWidget {
  final Deposit deposit;
  final TontineProvider tontineProvider;
  final int tontineId;

  const DepositListItem({
    super.key,
    required this.deposit,
    required this.tontineProvider,
    required this.tontineId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => _showDetails(context),
        title: Text(deposit.reasons ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('dd/MM/yyyy').format(deposit.creationDate),
            ),
            Text(
              'Par ${deposit.author.firstname} ${deposit.author.lastname}',
              style: const TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        trailing: Text(
          '${deposit.amount} ${deposit.currency.name}',
          style: TextStyle(
            color: deposit.amount >= 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DepositDetailsDialog(
          deposit: deposit,
          tontineProvider: tontineProvider,
          tontineId: tontineId,
        );
      },
    );
  }
} 