import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp de base monte sans erreur', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Text('Tontine')),
      ),
    );
    expect(find.text('Tontine'), findsOneWidget);
  });
}
