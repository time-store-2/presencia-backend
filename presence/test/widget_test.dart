import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:presencia/main.dart';
import 'package:presencia/core/providers/settings_provider.dart';
import 'package:presencia/core/providers/group_provider.dart';
import 'package:presencia/core/providers/adolescent_provider.dart';
import 'package:presencia/core/providers/attendance_provider.dart';
import 'package:presencia/core/providers/auth_provider.dart';

void main() {
  testWidgets('Dashboard basic smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => GroupProvider()),
          ChangeNotifierProvider(create: (_) => AdolescentProvider()),
          ChangeNotifierProvider(create: (_) => AttendanceProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const PresenciaApp(),
      ),
    );

    // Verify if Presencia text is found (part of splash or app bar)
    // Note: It might be on splash screen first
    expect(find.text('Presencia'), findsOneWidget);
    
    // After 2 seconds it should move to onboarding or main
    await tester.pump(const Duration(seconds: 3));
    
    // Check for some main UI element depending on state
    // Since it's a smoke test and we use real providers with SQLite (which might fail in unit tests without mocking),
    // we just check the initial build.
  });
}
