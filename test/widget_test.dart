import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quantum_computing_simulator/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Mock shared preferences for the quiz tracking
    SharedPreferences.setMockInitialValues({});
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const QuantumSimulatorApp());

    // Verify that the app builds without throwing
    expect(find.byType(MaterialApp), findsOneWidget);

    // Settle animations and timers (e.g. from flutter_animate)
    await tester.pump(const Duration(seconds: 2));
  });
}
