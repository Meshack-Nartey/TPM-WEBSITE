import 'package:flutter/material.dart';

import '../app/navigation.dart';
import '../data/mock_data.dart';
import '../screens/member/announcement_detail_screen.dart';
import '../theme/tpm_theme.dart';
import 'common.dart';

/// A horizontal strip of announcement cards docked just above the bottom
/// tab bar, visible on every member tab rather than scrolling away with the
/// Home screen's content — the ministry wants announcements to stay in view
/// wherever a member is in the app.
class AnnouncementBanner extends StatelessWidget {
  const AnnouncementBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 178,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
        physics: const PageScrollPhysics(),
        itemCount: MockData.carousel.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final item = MockData.carousel[i];
          return GestureDetector(
            onTap: () =>
                pushScreen(context, AnnouncementDetailScreen(item: item)),
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [TpmColors.navy, TpmColors.blueDeep],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: TpmColors.navy.withValues(alpha: 0.28),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  if (item.flyer != null)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(item.flyer!, fit: BoxFit.cover),
                      ),
                    )
                  else
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: TpmColors.goldGlow(opacity: 0.4),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Pill(
                          item.tag,
                          foreground: TpmColors.night,
                          background: TpmColors.gold,
                        ),
                        const Spacer(),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TpmText.display(
                                18,
                                color: Colors.white,
                                height: 1.2,
                              ).copyWith(
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.8),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.date,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TpmText.body(
                                12,
                                color: Colors.white.withValues(alpha: 0.9),
                              ).copyWith(
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.8),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
