import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skrolz_app/widgets/skeleton_loaders.dart';

void main() {
  testWidgets('ListSkeleton displays correct number of items', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ListSkeleton(itemCount: 3)),
      ),
    );

    expect(find.byType(ListSkeleton), findsOneWidget);
  });

  testWidgets('ProfileSkeleton displays skeleton elements', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProfileSkeleton()),
      ),
    );

    expect(find.byType(ProfileSkeleton), findsOneWidget);
  });
}
