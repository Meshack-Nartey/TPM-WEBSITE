import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../app/session.dart';
import '../../models/models.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/shells.dart';
import 'about_screen.dart';
import 'announcements_screen.dart';
import 'books_screen.dart';
import 'branches_screen.dart';
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
        const AboutScreen()
      ),
      (
        'Announcements',
        Icons.newspaper_rounded,
        TpmColors.tintIndigo,
        TpmColors.navy,
        const AnnouncementsScreen()
      ),
      (
        'Books & Resources',
        Icons.menu_book_rounded,
        TpmColors.tintViolet,
        TpmColors.violet,
        const BooksScreen()
      ),
      (
        'Find us / Branches',
        Icons.map_rounded,
        TpmColors.tintBlue,
        TpmColors.navy,
        const BranchesScreen()
      ),
      (
        'My Profile',
        Icons.person_rounded,
        TpmColors.tintAmber,
        TpmColors.goldDeep,
        const ProfileScreen()
      ),
    ];

    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Text('More', style: TpmText.display(27)),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: TpmColors.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: TpmShadows.card,
            ),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => pushScreen(context, items[i].$5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: i == 0
                              ? null
                              : const Border(top: BorderSide(color: TpmColors.divider)),
                        ),
                        child: Row(
                          children: [
                            IconTile(
                              icon: items[i].$2,
                              background: items[i].$3,
                              foreground: items[i].$4,
                              size: 34,
                              radius: 10,
                              iconSize: 17,
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Text(
                                items[i].$1,
                                style: TpmText.body(
                                  14.5,
                                  color: TpmColors.ink,
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFFCBD5E1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: TextButton(
            onPressed: () {
              session.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text(
              session.isSignedIn ? 'Sign out' : 'Sign in',
              style: TpmText.body(13.5, color: TpmColors.subtle, weight: FontWeight.w600),
            ),
          ),
        ),
      ],
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
              const Icon(Icons.chevron_right_rounded, color: TpmColors.portalGold),
            ],
          ),
        ),
      ),
    );
  }
}
