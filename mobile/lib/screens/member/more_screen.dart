import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../app/session.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/shells.dart';
import '../auth/splash_screen.dart';
import 'about_screen.dart';
import 'announcements_screen.dart';
import 'books_screen.dart';
import 'branches_screen.dart';
import 'missions_screen.dart';
import 'profile_screen.dart';

/// Secondary navigation, and the doorway to the work portal.
///
/// The portal entry only renders for leaders and admins. It is styled in the
/// portal's own gold-on-black so the change of surface is announced before you
/// cross into it, rather than surprising you on the next screen.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AppSession.of(context);

    final items = <(String, IconData, Color, Color, Widget)>[
      (
        'About TPM',
        Icons.info_rounded,
        TpmColors.tintBlue,
        TpmColors.navy,
        const AboutScreen(),
      ),
      (
        'Announcements',
        Icons.newspaper_rounded,
        TpmColors.tintIndigo,
        TpmColors.navy,
        const AnnouncementsScreen(),
      ),
      (
        'Books & Resources',
        Icons.menu_book_rounded,
        TpmColors.tintViolet,
        TpmColors.violet,
        const BooksScreen(),
      ),
      (
        'Branches',
        Icons.map_rounded,
        TpmColors.tintBlue,
        TpmColors.navy,
        const BranchesScreen(),
      ),
      (
        'Missions',
        Icons.public_rounded,
        TpmColors.tintGreen,
        TpmColors.green,
        const MissionsScreen(),
      ),
      (
        'My Profile',
        Icons.person_rounded,
        TpmColors.tintAmber,
        TpmColors.goldDeep,
        const ProfileScreen(),
      ),
    ];

    return ListView(
      // The shell's tab bar floats over the body (extendBody: true), so the
      // last card needs real clearance or it ends up sitting behind it.
      padding: const EdgeInsets.only(top: 20, bottom: 110),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            'More',
            textAlign: TextAlign.center,
            style: TpmText.display(27),
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, i) => _MoreTile(
              label: items[i].$1,
              icon: items[i].$2,
              tintBg: items[i].$3,
              tintFg: items[i].$4,
              onTap: () => pushScreen(context, items[i].$5),
            ),
          ),
        ),
        if (session.canEnterPortal) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: _PortalEntry(role: session.role),
          ),
        ],
        const SizedBox(height: 16),
        Center(
          child: _SignOutButton(
            signedIn: session.isSignedIn,
            onTap: () {
              session.signOut();
              // MemberShell replaced the whole stack on entry (see
              // MemberShell.enter), so it's the only route there is —
              // popping does nothing. Replace the stack again instead.
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SplashScreen()),
                (route) => false,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A destructive action should not read like every other quiet text link —
/// signing out gets a filled, danger-tinted pill instead. Signing in isn't
/// destructive, so it keeps a plain, low-emphasis look.
class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.signedIn, required this.onTap});

  final bool signedIn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!signedIn) {
      return TextButton(
        onPressed: onTap,
        child: Text(
          'Sign in',
          style: TpmText.body(
            13.5,
            color: TpmColors.subtle,
            weight: FontWeight.w600,
          ),
        ),
      );
    }

    return Material(
      color: TpmColors.danger.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(99),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout_rounded,
                size: 16,
                color: TpmColors.danger,
              ),
              const SizedBox(width: 8),
              Text(
                'Sign out',
                style: TpmText.body(
                  13.5,
                  color: TpmColors.danger,
                  weight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One centered tile in the More grid — icon above label, the whole square
/// tappable rather than a chevron-terminated row.
class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.label,
    required this.icon,
    required this.tintBg,
    required this.tintFg,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color tintBg;
  final Color tintFg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TpmCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconTile(
            icon: icon,
            background: tintBg,
            foreground: tintFg,
            size: 44,
            radius: 13,
            iconSize: 21,
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TpmText.body(
              13,
              color: TpmColors.ink,
              weight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalEntry extends StatelessWidget {
  const _PortalEntry({required this.role});

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      color: TpmColors.nightSurface,
      child: InkWell(
        onTap: () => PortalShell.enter(context, role),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF111111), Color(0xFF1A1A1A)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const IconTile(
                icon: Icons.login_rounded,
                background: Colors.transparent,
                gradient: TpmColors.portalGoldGradient,
                foreground: TpmColors.night,
                size: 42,
                radius: 12,
                iconSize: 19,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role == AppRole.admin ? 'Admin Portal' : 'My Ministry',
                      style: TpmText.display(16, color: Colors.white),
                    ),
                    Text(
                      'Enter the work portal',
                      style: TpmText.body(
                        11.5,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: TpmColors.portalGold,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
