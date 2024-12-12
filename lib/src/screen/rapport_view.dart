import 'package:flutter/material.dart';

class RapportView extends StatelessWidget {

  const RapportView({super.key});
  
  static const routeName ='/rapport';

  static const dataRapport= [
    {
      'date': '2023-01-01',
      'participants': 10,
      'amountCollected': 500.0,
      'notes': 'First meeting of the year.'
    },
    {
      'date': '2023-02-01',
      'participants': 12,
      'amountCollected': 600.0,
      'notes': 'Monthly meeting.'
    },
    {
      'date': '2023-03-01',
      'participants': 11,
      'amountCollected': 550.0,
      'notes': 'Discussed new member applications.'
    },
    {
      'date': '2023-04-01',
      'participants': 9,
      'amountCollected': 450.0,
      'notes': 'Reviewed financial statements.'
    },
    {
      'date': '2023-05-01',
      'participants': 13,
      'amountCollected': 650.0,
      'notes': 'Special guest speaker.'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapport Tontine'),
      ),
      body: ListView(
        children: dataRapport.map((rapport) {
          return ListTile(
            title: Text('Date: ${rapport['date']}'),
            subtitle: Text('Participants: ${rapport['participants']} - Amount Collected: \$${rapport['amountCollected']}'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Details for ${rapport['date']}'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${rapport['date']}'),
                        Text('Participants: ${rapport['participants']}'),
                        Text('Amount Collected: \$${rapport['amountCollected']}'),
                        Text('Notes: ${rapport['notes']}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          );
        }).toList(),

      )
    );
  }
}
