import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tontine_v2/src/widgets/circular_order_card.dart';

import 'helpers/fixtures.dart';

void main() {
  group('CircularOrderCard', () {
    testWidgets('affiche le nom du membre et le badge actuel', (tester) async {
      final part = makePartOrder(
        order: 3,
        member: makeMember(firstname: 'Paul', lastname: 'Kouassi'),
        period: DateTime(2026, 7, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularOrderCard(
              partOrder: part,
              isCurrent: true,
            ),
          ),
        ),
      );

      expect(find.textContaining('Paul'), findsWidgets);
      expect(find.textContaining('Kouassi'), findsWidgets);
    });
  });

  group('Dashboard — accès rapide (structure)', () {
    testWidgets('tuiles Trésorerie et Membres visibles sans scroll long',
        (tester) async {
      // Reproduit la grille compacte du dashboard (2 colonnes, 64px).
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Accès rapide'),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 3.2,
                    children: const [
                      _FakeTile(label: 'Trésorerie'),
                      _FakeTile(label: 'Membres'),
                      _FakeTile(label: 'Emprunts'),
                      _FakeTile(label: 'Événements'),
                      _FakeTile(label: 'Rapports'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Accès rapide'), findsOneWidget);
      expect(find.text('Trésorerie'), findsOneWidget);
      expect(find.text('Membres'), findsOneWidget);
      expect(find.text('Emprunts'), findsOneWidget);
      expect(find.text('Événements'), findsOneWidget);
      expect(find.text('Rapports'), findsOneWidget);
    });
  });
}

class _FakeTile extends StatelessWidget {
  final String label;
  const _FakeTile({required this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {},
        child: Center(child: Text(label)),
      ),
    );
  }
}
