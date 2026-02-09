// Basic Flutter widget test for Owlna.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skrolz_app/theme/theme.dart';

void main() {
  testWidgets('App theme applies', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(child: Text('Owlna')),
        ),
      ),
    );
    expect(find.text('Owlna'), findsOneWidget);
  });
}
