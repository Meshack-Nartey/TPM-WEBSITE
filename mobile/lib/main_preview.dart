// Preview entrypoint — a development tool, not part of the shipped app.
//
// Renders any single screen at phone size so it can be opened in a browser or
// screenshotted for review, which is the only way to eyeball the design without
// an iOS simulator or Android emulator installed. This is the design board's
// canvas idea as a real page.
//
//   flutter run -d chrome -t lib/main_preview.dart
//   then: ?screen=home  ·  ?screen=leaderDash&role=leader
//
// `flutter build web` uses lib/main.dart and never includes this file.

import 'package:flutter/material.dart';

import 'app/session.dart';
import 'data/mock_data.dart';
import 'models/models.dart';
import 'screens/admin/access_screen.dart';
import 'screens/admin/admin_overview_screen.dart';
import 'screens/admin/approvals_screen.dart';
import 'screens/admin/compose_screen.dart';
import 'screens/admin/manage_lists_screen.dart';
import 'screens/auth/biometric_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/leader/leader_dashboard_screen.dart';
import 'screens/leader/member_detail_screen.dart';
import 'screens/leader/register_member_screen.dart';
import 'screens/leader/registry_screen.dart';
import 'screens/leader/weekly_report_screen.dart';
import 'screens/member/about_screen.dart';
import 'screens/member/announcement_detail_screen.dart';
import 'screens/member/announcements_screen.dart';
import 'screens/member/book_detail_screen.dart';
import 'screens/member/books_screen.dart';
import 'screens/member/branches_screen.dart';
import 'screens/member/event_detail_screen.dart';
import 'screens/member/events_screen.dart';
import 'screens/member/give_screen.dart';
import 'screens/member/home_screen.dart';
import 'screens/member/media_screen.dart';
import 'screens/member/more_screen.dart';
import 'screens/member/player_screen.dart';
import 'screens/member/profile_screen.dart';
import 'screens/system/data_states_screen.dart';
import 'theme/tpm_theme.dart';
import 'widgets/shells.dart';

/// Each entry is a screen, whether it brings its own Scaffold, and the surface
/// it sits on.
class _Preview {
  const _Preview(this.build, {this.scaffold = true, this.dark = false});

  final Widget Function() build;
  final bool scaffold;
  final bool dark;
}

final Map<String, _Preview> _screens = {
  // Onboarding & auth
  'splash': _Preview(() => const SplashScreen(), scaffold: false),
  'welcome': _Preview(() => const WelcomeScreen(), scaffold: false),
  'signin': _Preview(() => const SignInScreen(), scaffold: false),
  'register': _Preview(() => const RegisterScreen(), scaffold: false),
  'biometric': _Preview(() => const BiometricScreen(), scaffold: false),

  // Member & public
  'home': _Preview(() => const HomeScreen()),
  'media': _Preview(() => const MediaScreen()),
  'player': _Preview(
    () => PlayerScreen(item: MockData.media.first),
    scaffold: false,
  ),
  'events': _Preview(() => const EventsScreen()),
  'eventDetail': _Preview(
    () => EventDetailScreen(event: MockData.events.first),
    scaffold: false,
  ),
  'give': _Preview(() => const GiveScreen()),
  'announcements': _Preview(() => const AnnouncementsScreen(), scaffold: false),
  'annDetail': _Preview(
    () => AnnouncementDetailScreen(item: MockData.newsFeed.first),
    scaffold: false,
  ),
  'branches': _Preview(() => const BranchesScreen(), scaffold: false),
  'books': _Preview(() => const BooksScreen(), scaffold: false),
  'bookDetail': _Preview(
    () => BookDetailScreen(book: MockData.books.first),
    scaffold: false,
  ),
  'profile': _Preview(() => const ProfileScreen(), scaffold: false),
  'more': _Preview(() => const MoreScreen()),
  'about': _Preview(() => const AboutScreen(), scaffold: false),

  // Leader portal
  'leaderDash': _Preview(() => const LeaderDashboardScreen(), dark: true),
  'report': _Preview(
    () => const WeeklyReportScreen(embedded: true),
    dark: true,
  ),
  'registry': _Preview(() => const RegistryScreen(embedded: true), dark: true),
  'registerMember': _Preview(
    () => const RegisterMemberScreen(),
    scaffold: false,
  ),
  'memberDetail': _Preview(
    () => MemberDetailScreen(member: MockData.members.first),
    scaffold: false,
  ),

  // Administrator
  'adminDash': _Preview(() => const AdminOverviewScreen(), dark: true),
  'approvals': _Preview(
    () => const ApprovalsScreen(embedded: true),
    dark: true,
  ),
  'access': _Preview(() => const AccessScreen(embedded: true), dark: true),
  'lists': _Preview(() => const ManageListsScreen(embedded: true), dark: true),
  'compose': _Preview(() => const ComposeScreen(), scaffold: false),

  // States
  'states': _Preview(() => const DataStatesScreen(), scaffold: false),

  // Whole shells, with their navigation bars
  'app': _Preview(() => const MemberShell(), scaffold: false),
  'portal': _Preview(
    () => const PortalShell(role: AppRole.leader),
    scaffold: false,
  ),
};

void main() {
  final params = Uri.base.queryParameters;
  final name = params['screen'] ?? 'index';
  final role = switch (params['role']) {
    'guest' => AppRole.guest,
    'leader' => AppRole.leader,
    'admin' => AppRole.admin,
    _ => AppRole.member,
  };

  runApp(_PreviewApp(name: name, role: role));
}

class _PreviewApp extends StatelessWidget {
  const _PreviewApp({required this.name, required this.role});

  final String name;
  final AppRole role;

  @override
  Widget build(BuildContext context) {
    final preview = _screens[name];

    return SessionProvider(
      session: AppSession()..signInAs(role),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: TpmTheme.light(),
        // The browser window is whatever size it happens to be, which is no use
        // for judging a phone layout. This pins the screen to exactly 390x844
        // with an iPhone's safe-area insets, so what is on screen is what would
        // be on the device.
        builder: (context, child) => ColoredBox(
          color: const Color(0xFFE7ECF3),
          child: Center(
            child: SizedBox(
              width: 390,
              height: 844,
              child: MediaQuery(
                data: const MediaQueryData(
                  size: Size(390, 844),
                  devicePixelRatio: 3,
                  padding: EdgeInsets.only(top: 47, bottom: 34),
                  viewPadding: EdgeInsets.only(top: 47, bottom: 34),
                ),
                child: ClipRect(child: child ?? const SizedBox.shrink()),
              ),
            ),
          ),
        ),
        home: preview == null
            ? _Index(unknown: name != 'index' ? name : null)
            : (preview.scaffold
                  ? Scaffold(
                      backgroundColor: preview.dark
                          ? TpmColors.night
                          : TpmColors.canvas,
                      body: SafeArea(child: preview.build()),
                    )
                  : preview.build()),
      ),
    );
  }
}

/// Landing page listing every screen, so the preview is navigable by hand.
class _Index extends StatelessWidget {
  const _Index({this.unknown});

  final String? unknown;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('TPM screen preview', style: TpmText.display(24)),
            const SizedBox(height: 6),
            Text(
              unknown == null
                  ? 'Append ?screen=<name> to the URL. Add &role=leader or '
                        '&role=admin where it matters.'
                  : 'No screen called "$unknown".',
              style: TpmText.body(13, height: 1.5),
            ),
            const SizedBox(height: 18),
            for (final name in _screens.keys)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '?screen=$name',
                  style: TpmText.body(13.5, color: TpmColors.navy),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
