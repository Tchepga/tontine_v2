import 'package:flutter/material.dart';
import 'package:tontine_v2/src/widgets/menu_widget.dart';

class CashflowView extends StatelessWidget {
  const CashflowView({super.key});
  static const routeName = '/cashflow';

  static const data = [
    {
      'title': 'Salaire',
      'amount': 2000,
      'date': '2021-10-01',
    },
    {
      'title': 'Loyer',
      'amount': -500,
      'date': '2021-10-05',
    },
    {
      'title': 'Courses',
      'amount': -200,
      'date': '2021-10-10',
    },
    {
      'title': 'Salaire',
      'amount': 2000,
      'date': '2021-10-15',
    },
    {
      'title': 'Loyer',
      'amount': -500,
      'date': '2021-10-20',
    },
    {
      'title': 'Courses',
      'amount': -200,
      'date': '2021-10-25',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trésorerie'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String result) {
              // Handle report generation logic here
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'generate_report',
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf),
                  title: Text('Générer un rapport'),
                ),
              ),
              PopupMenuItem<String>(
                value: 'add_transaction',
                child: ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Ajouter une transaction'),
                  onTap: () {
                  Navigator.pop(context); // Close the popup menu
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                    final TextEditingController titleController = TextEditingController();
                    final TextEditingController amountController = TextEditingController();
                    final TextEditingController dateController = TextEditingController();
                    return AlertDialog(
                      title: const Text('Ajouter une transaction'),
                      content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Titre'),
                        ),
                        TextField(
                        controller: amountController,
                        decoration: const InputDecoration(labelText: 'Montant'),
                        keyboardType: TextInputType.number,
                        ),
                        TextField(
                        controller: dateController,
                        decoration: const InputDecoration(labelText: 'Date'),
                        onTap: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          );
                          if (pickedDate != null) {
                          dateController.text = pickedDate.toIso8601String().split('T').first;
                          }
                        },
                        ),
                      ],
                      ),
                      actions: [
                      TextButton(
                        onPressed: () {
                        Navigator.of(context).pop();
                        },
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                        // Handle adding transaction logic here
                        Navigator.of(context).pop();
                        },
                        child: const Text('Ajouter'),
                      ),
                      ],
                    );
                    },
                  );
                  },
                ),
              ),
            ],
            child: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue[300],
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 1.0),
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: const Center(
              child: Column(
                children: [
                  Text(
                    '20000 EUR',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Solde actuel',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Chip(
                        label:
                            Text('+10%', style: TextStyle(color: Colors.white)),
                        backgroundColor: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Historique',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              PopupMenuButton<String>(
                onSelected: (String result) {
                  // Handle filter logic here
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'select_date',
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Sélectionner une date'),
                      onTap: () async {
                        Navigator.pop(context); // Close the popup menu
                        final DateTimeRange? pickedDateRange =
                            await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          initialDateRange: DateTimeRange(
                            start: DateTime.now()
                                .subtract(const Duration(days: 7)),
                            end: DateTime.now(),
                          ),
                        );
                        if (pickedDateRange != null) {
                          // Handle the selected date
                        }
                      },
                    ),
                  ),
                ],
                child: const Icon(Icons.filter_list),
              ),
            ],
          ),
          const SizedBox(height: 24),
          for (final item in data)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: (item['amount'] as int) > 0
                    ? Theme.of(context).primaryColorDark
                    : Colors.red[300],
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0),
                    blurRadius: 6.0,
                  ),
                ],
              ),
            child: GestureDetector(
              onTap: () {
                print("Item clicked");
                SnackBar(
                  content: Text('Montant: ${item['amount']} EUR'),
                  duration: const Duration(seconds: 1),
                );
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(item['title'] as String),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Montant: ${item['amount']} EUR'),
                          Text('Date: ${item['date']}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Fermer'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        item['date'] as String,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ],
                  ),
                  Text(
                    '${item['amount']} EUR',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const MenuWidget(),
    );
  }
}
