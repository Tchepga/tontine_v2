import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/models/part.dart';

class PartsSchedule extends StatelessWidget {
  final List<Part> parts;

  const PartsSchedule({super.key, required this.parts});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Calendrier des parts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: parts.length,
              itemBuilder: (context, index) {
                final part = parts[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('${part.order}'),
                  ),
                  title: Text(part.memberName),
                  subtitle: Text(
                    part.passageDate != null
                        ? 'Passage le ${DateFormat('dd/MM/yyyy').format(part.passageDate!)}'
                        : 'Date non définie',
                  ),
                  trailing: part.isPassed
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 