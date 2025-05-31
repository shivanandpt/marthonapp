import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marunthon_app/features/home/home_page.dart';

void main() {
  testWidgets('HomePage displays greeting', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: HomePage()));

    expect(find.text('Welcome back, Runner!'), findsOneWidget);
    // Add more expectations as needed
  });
}
