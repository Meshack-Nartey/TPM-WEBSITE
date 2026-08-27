import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tpm_mobile/app/session.dart';
import 'package:tpm_mobile/main.dart';
import 'package:tpm_mobile/models/models.dart';
import 'package:tpm_mobile/screens/auth/welcome_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Tests must not reach the network for fonts; fall back to the bundled face.
    GoogleFonts.config.allowRuntimeFetching = false;
    // AppSession persists to shared_preferences; the plugin has no real
    // platform channel in tests, so give it an in-memory store instead.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('splash shows the brand lockup and leads to welcome', (tester) async {
    // The app is portrait-only, so test it at a phone size rather than the
    // 800x600 default the harness would otherwise use.
    tester.view
      ..physicalSize = const Size(390 * 3, 844 * 3)
      ..devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(TpmApp(session: AppSession()));
    await tester.pump();

    expect(find.text('TRANSFORMATION'), findsOneWidget);
    expect(find.text('TRANSFORMING LIVES'), findsOneWidget);

    await tester.tap(find.text('Tap to continue'));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text('Continue as'), findsOneWidget);
  });

  group('AppSession', () {
    test('starts as a guest with no portal access', () {
      final session = AppSession();
      expect(session.role, AppRole.guest);
      expect(session.isSignedIn, isFalse);
      expect(session.canEnterPortal, isFalse);
    });

    test('only leaders and admins may enter the portal', () {
      final session = AppSession();

      session.signInAs(AppRole.member);
      expect(session.canEnterPortal, isFalse);

      session.signInAs(AppRole.leader);
      expect(session.canEnterPortal, isTrue);

      session.signInAs(AppRole.admin);
      expect(session.canEnterPortal, isTrue);
    });

    test('signing out drops back to guest', () {
      final session = AppSession()..signInAs(AppRole.admin);
      session.signOut();
      expect(session.role, AppRole.guest);
      expect(session.isSignedIn, isFalse);
    });

    test('notifies listeners only when the role actually changes', () {
      final session = AppSession();
      var notifications = 0;
      session.addListener(() => notifications++);

      session.signInAs(AppRole.leader);
      session.signInAs(AppRole.leader);
      expect(notifications, 1);

      session.signInAs(AppRole.member);
      expect(notifications, 2);
    });
  });
}
