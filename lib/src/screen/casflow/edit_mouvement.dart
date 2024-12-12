import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

  class EditMouvement extends StatefulWidget {
    @override
    _EditMouvementState createState() => _EditMouvementState();
  }

  class _EditMouvementState extends State<EditMouvement> {
    final _formKey = GlobalKey<FormState>();
    final _montantController = TextEditingController();
    final _descriptionController = TextEditingController();
    String _selectedReason='';
    String _selectedAuthor='';

    @override
    Widget build(BuildContext context) {
      return AlertDialog(
        title: const Text('Edit Mouvement'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: _montantController,
                  decoration: const InputDecoration(labelText: 'Montant'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a montant';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedReason,
                  decoration: const InputDecoration(labelText: 'Reason'),
                  items: ['Rembours', 'Contribution', 'Loan']
                      .map((reason) => DropdownMenuItem(
                            value: reason,
                            child: Text(reason),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a reason';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedAuthor,
                  decoration: InputDecoration(labelText: 'Author'),
                  items: ['Author1', 'Author2', 'Author3']
                      .map((author) => DropdownMenuItem(
                            value: author,
                            child: Text(author),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAuthor = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select an author';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Handle form submission
              }
            },
            child: const Text('Submit'),
          ),
        ],
      );
    }

    @override
    void dispose() {
      _montantController.dispose();
      _descriptionController.dispose();
      super.dispose();
    }
}