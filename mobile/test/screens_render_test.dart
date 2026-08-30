import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:tpm_mobile/app/session.dart';
import 'package:tpm_mobile/data/mock_data.dart';
import 'package:tpm_mobile/models/models.dart';
import 'package:tpm_mobile/screens/admin/access_screen.dart';
import 'package:tpm_mobile/screens/admin/admin_overview_screen.dart';
import 'package:tpm_mobile/screens/admin/approvals_screen.dart';
import 'package:tpm_mobile/screens/admin/compose_screen.dart';
import 'package:tpm_mobile/screens/admin/manage_lists_screen.dart';
import 'package:tpm_mobile/screens/auth/biometric_screen.dart';
import 'package:tpm_mobile/screens/auth/forgot_password_screen.dart';
import 'package:tpm_mobile/screens/auth/register_screen.dart';
import 'package:tpm_mobile/screens/auth/sign_in_screen.dart';
import 'package:tpm_mobile/screens/auth/splash_screen.dart';
import 'package:tpm_mobile/screens/auth/welcome_screen.dart';
import 'package:tpm_mobile/screens/leader/leader_dashboard_screen.dart';
import 'package:tpm_mobile/screens/leader/member_detail_screen.dart';
import 'package:tpm_mobile/screens/leader/register_member_screen.dart';
import 'package:tpm_mobile/screens/leader/registry_screen.dart';
import 'package:tpm_mobile/screens/leader/weekly_report_screen.dart';
import 'package:tpm_mobile/screens/member/about_screen.dart';
import 'package:tpm_mobile/screens/member/announcement_detail_screen.dart';
import 'package:tpm_mobile/screens/member/announcements_screen.dart';
import 'package:tpm_mobile/screens/member/book_detail_screen.dart';
import 'package:tpm_mobile/screens/member/books_screen.dart';
import 'package:tpm_mobile/screens/member/branches_screen.dart';
import 'package:tpm_mobile/screens/member/event_detail_screen.dart';
import 'package:tpm_mobile/screens/member/events_screen.dart';
import 'package:tpm_mobile/screens/member/give_screen.dart';
import 'package:tpm_mobile/screens/member/home_screen.dart';
import 'package:tpm_mobile/screens/member/media_screen.dart';
import 'package:tpm_mobile/screens/member/missions_screen.dart';
import 'package:tpm_mobile/screens/member/more_screen.dart';
import 'package:tpm_mobile/screens/member/player_screen.dart';
import 'package:tpm_mobile/screens/member/profile_screen.dart';
import 'package:tpm_mobile/screens/system/data_states_screen.dart';
import 'package:tpm_mobile/theme/tpm_theme.dart';

/// Every screen on the design board, rendered at phone size.
///
/// A RenderFlex overflow throws during layout in debug, so `takeException()`
/// coming back null is a real assertion that the screen lays out — this is the
/// cheapest guard against the board's 29 screens silently rotting.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  /// Screens are authored as bodies inside a shell, so most need a Scaffold.
  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    AppRole role = AppRole.member,
    bool wrapInScaffold = true,
    Color background = TpmColors.canvas,
  }) async {
    tester.view
      ..physicalSize = const Size(390 * 3, 844 * 3)
      ..devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      SessionProvider(
        session: AppSession()..signInAs(role),
        child: MaterialApp(
          theme: TpmTheme.light(),
          home: wrapInScaffold
              ? Scaffold(
                  backgroundColor: background,
                  body: SafeArea(child: screen),
                )
              : screen,
        ),
      ),
    );

    // Several screens animate forever (the countdown ticker, the skeleton
    // shimmer), so settle would never return. One frame is enough for layout.
    await tester.pump();
  }

  group('onboarding & auth', () {
    testWidgets('splash', (t) async {
      await pumpScreen(t, const SplashScreen(), wrapInScaffold: false);
      expect(t.takeException(), isNull);
    });

    testWidgets('welcome', (t) async {
      await pumpScreen(t, const WelcomeScreen(), wrapInScaffold: false);
      expect(t.takeException(), isNull);
    });

    testWidgets('sign in', (t) async {
      await pumpScreen(t, const SignInScreen(), wrapInScaffold: false);
      expect(t.takeException(), isNull);
    });

    testWidgets('forgot password', (t) async {
      await pumpScreen(t, const ForgotPasswordScreen(), wrapInScaffold: false);
      expect(t.takeException(), isNull);
    });

    testWidgets('register', (t) async {
      await pumpScreen(t, const RegisterScreen(), wrapInScaffold: false);
      expect(t.takeException(), isNull);
    });

    testWidgets('biometric', (t) async {
      await pumpScreen(t, const BiometricScreen(), wrapInScaffold: false);
      expect(t.takeException(), isNull);
    });
  });

  group('member & public', () {
    testWidgets('home', (t) async {
      await pumpScreen(t, const HomeScreen());
      expect(t.takeException(), isNull);
    });

    testWidgets('watch & listen', (t) async {
      await pumpScreen(t, const MediaScreen());
      expect(t.takeException(), isNull);
    });

    testWidgets('player', (t) async {
      await pumpScreen(
        t,
        PlayerScreen(item: MockData.media.first),
        wrapInScaffold: false,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('events', (t) async {
      await pumpScreen(t, const EventsScreen());
      expect(t.takeException(), isNull);
    });

    testWidgets('event detail', (t) async {
      await pumpScreen(
        t,
        EventDetailScreen(event: MockData.events.first),
        wrapInScaffold: false,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('give', (t) async {
      await pumpScreen(t, const GiveScreen());
      expect(t.takeException(), isNull);
    });

    testWidgets('announcements', (t) async {
      await pumpScreen(t, const AnnouncementsScreen(), wrapInScaffold: false);
      expect(t.takeException(), isNull);
    });

    testWidgets('announcement detail', (t) async {
      await pumpScreen(
        t,
        AnnouncementDetailScreen(item: MockData.newsFeed.first),
        wrapInScaffold: false,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('branches', (t) async {
      await pumpScreen(t, const BranchesScreen(), wrapInScaffold: false);
      expect(t.takeException(), isNull);
    });

    testWidgets('books', (t) async {
      await pumpScreen(t, const BooksScreen(), wrapInScaffold: false);
      expect(t.takeException(), isNull);
    });

    testWidgets('book detail', (t) async {
      await pumpScreen(
        t,
        BookDetailScreen(book: MockData.books.first),
        wrapInScaffold: false,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('profile', (t) async {
      await pumpScreen(t, const ProfileScreen(), wrapInScaffold: false);
      expect(t.takeException(), isNull);
    });

    testWidgets('about', (t) async {
      await pumpScreen(t, const AboutScreen(), wrapInScaffold: false);
      expect(t.takeException(), isNull);
    });

    testWidgets('missions', (t) async {
      await pumpScreen(t, const MissionsScreen(), wrapInScaffold: false);
      expect(t.takeException(), isNull);
    });

    testWidgets('more', (t) async {
      await pumpScreen(t, const MoreScreen());
      expect(t.takeException(), isNull);
    });

    testWidgets('more shows the portal entry to leaders only', (t) async {
      await pumpScreen(t, const MoreScreen(), role: AppRole.member);
      expect(find.text('My Ministry'), findsNothing);

      await pumpScreen(t, const MoreScreen(), role: AppRole.leader);
      expect(find.text('My Ministry'), findsOneWidget);

      await pumpScreen(t, const MoreScreen(), role: AppRole.admin);
      expect(find.text('Admin Portal'), findsOneWidget);
    });
  });

  group('leader tools', () {
    testWidgets('dashboard', (t) async {
      await pumpScreen(
        t,
        const LeaderDashboardScreen(),
        role: AppRole.leader,
        background: TpmColors.night,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('weekly report', (t) async {
      await pumpScreen(
        t,
        const WeeklyReportScreen(embedded: true),
        role: AppRole.leader,
        background: TpmColors.night,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('registry', (t) async {
      await pumpScreen(
        t,
        const RegistryScreen(embedded: true),
        role: AppRole.leader,
        background: TpmColors.night,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('register member', (t) async {
      await pumpScreen(
        t,
        const RegisterMemberScreen(),
        role: AppRole.leader,
        wrapInScaffold: false,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('member detail', (t) async {
      await pumpScreen(
        t,
        MemberDetailScreen(member: MockData.members.first),
        role: AppRole.leader,
        wrapInScaffold: false,
      );
      expect(t.takeException(), isNull);
    });
  });

  group('administrator tools', () {
    testWidgets('overview', (t) async {
      await pumpScreen(
        t,
        const AdminOverviewScreen(),
        role: AppRole.admin,
        background: TpmColors.night,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('approvals', (t) async {
      await pumpScreen(
        t,
        const ApprovalsScreen(embedded: true),
        role: AppRole.admin,
        background: TpmColors.night,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('access', (t) async {
      await pumpScreen(
        t,
        const AccessScreen(embedded: true),
        role: AppRole.admin,
        background: TpmColors.night,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('manage lists', (t) async {
      await pumpScreen(
        t,
        const ManageListsScreen(embedded: true),
        role: AppRole.admin,
        background: TpmColors.night,
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('compose', (t) async {
      await pumpScreen(
        t,
        const ComposeScreen(),
        role: AppRole.admin,
        wrapInScaffold: false,
      );
      expect(t.takeException(), isNull);
    });
  });

  group('states & rigor', () {
    testWidgets('data states', (t) async {
      await pumpScreen(t, const DataStatesScreen(), wrapInScaffold: false);
      expect(t.takeException(), isNull);
    });
  });

  group('behaviour', () {
    testWidgets('weekly report queues offline and syncs on reconnect', (
      t,
    ) async {
      await pumpScreen(
        t,
        const WeeklyReportScreen(embedded: true),
        role: AppRole.leader,
        background: TpmColors.night,
      );

      expect(find.text('Online — ready to submit'), findsOneWidget);

      // Go offline: the submit button changes to a queue action.
      await t.tap(find.text('Online'));
      await t.pump();
      expect(find.text('Offline — you can still fill this in'), findsOneWidget);
      expect(find.text('Save & queue report'), findsOneWidget);

      // Submitting offline saves to the device rather than failing.
      await t.tap(find.text('Save & queue report'));
      await t.pump();
      expect(find.text('Queued — will sync when back online'), findsOneWidget);

      // Coming back online drains the queue.
      await t.tap(find.text('Offline'));
      await t.pump();
      expect(find.text('Syncing to the office…'), findsOneWidget);

      await t.pump(const Duration(milliseconds: 1500));
      expect(find.text('Synced — report received'), findsOneWidget);
      expect(find.text('Submitted'), findsOneWidget);
    });

    testWidgets('approving a request clears it from the queue', (t) async {
      await pumpScreen(
        t,
        const ApprovalsScreen(embedded: true),
        role: AppRole.admin,
        background: TpmColors.night,
      );

      expect(find.text('PENDING · 3'), findsOneWidget);

      await t.tap(find.text('Approve').first);
      await t.pump();

      expect(find.text('PENDING · 2'), findsOneWidget);
    });

    testWidgets('registry search narrows the list', (t) async {
      await pumpScreen(
        t,
        const RegistryScreen(embedded: true),
        role: AppRole.leader,
        background: TpmColors.night,
      );

      expect(find.text('Kwame Asante'), findsOneWidget);
      expect(find.text('Abena Osei'), findsOneWidget);

      // "Music" is one of the ministry's fifteen real worker groups.
      await t.enterText(find.byType(TextField), 'music');
      await t.pump();

      expect(find.text('Kwame Asante'), findsNothing);
      expect(find.text('Abena Osei'), findsOneWidget);
    });
  });
}
