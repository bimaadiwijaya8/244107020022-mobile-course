import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week_6_authentication_security_fcm/ui/login_page.dart';

void main() {
  testWidgets('LoginPage displays email and password fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    // Verify UI components of LoginPage exist
    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Masuk (Login)'), findsOneWidget);
    expect(find.text('Alamat Email'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
  });
}
