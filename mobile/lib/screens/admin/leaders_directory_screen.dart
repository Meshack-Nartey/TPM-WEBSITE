import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../app/session.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../services/auth_api.dart';
import '../../services/leaders_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';
import 'leader_form_screen.dart';

/// Pastors & branch leaders featured on the public site — managed here by
/// the office rather than by editing the website directly.
class LeadersDirectoryScreen extends StatefulWidget {
  const LeadersDirectoryScreen({super.key});

  @override
  State<LeadersDirectoryScreen> createState() => _LeadersDirectoryScreenState();
}

class _LeadersDirectoryScreenState extends State<LeadersDirectoryScreen> {
  bool _loaded = false;
  bool _loading = true;
  String? _error;
  List<ChurchLeader> _leaders = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      _load();
    }
  }

  Future<void> _load() async {
    final token = AppSession.of(context).token;
    if (token == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final leaders = await LeadersApi(token: token).fetch();
      if (!mounted) return;
      setState(() {
        _leaders = leaders;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _openForm({ChurchLeader? leader}) async {
    final changed = await pushScreen<bool>(
      context,
      LeaderFormScreen(leader: leader),
    );
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.night,
      body: SafeArea(
        child: RefreshIndicator(
          color: TpmColors.portalGold,
          backgroundColor: TpmColors.nightRaised,
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 34),
            children: [
              Row(
                children: [
                  CircleBackButton(
                    dark: true,
                    size: 36,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Eyebrow(
                          "Pastor's Office",
                          color: TpmColors.portalGold,
                          size: 10,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Leaders directory',
                          style: TpmText.display(
                            22,
                            color: TpmColors.portalInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => _openForm(),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: TpmColors.portalGoldGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: TpmColors.night.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: TpmColors.night,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Add a leader',
                          style: TpmText.display(15, color: TpmColors.night),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: TpmColors.night,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: TpmColors.portalGold,
                    ),
                  ),
                )
              else if (_error != null)
                PortalCard(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 20,
                  ),
                  child: Column(
                    children: [
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: TpmText.body(13, color: TpmColors.portalInk),
                      ),
                      const SizedBox(height: 14),
                      TpmOutlineButton(
                        label: 'Retry',
                        icon: Icons.refresh_rounded,
                        foreground: TpmColors.portalInk,
                        background: Colors.white.withValues(alpha: 0.06),
                        borderColor: Colors.white.withValues(alpha: 0.15),
                        onPressed: _load,
                      ),
                    ],
                  ),
                )
              else if (_leaders.isEmpty)
                PortalCard(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 20,
                  ),
                  child: Center(
                    child: Text(
                      'No leaders added yet.',
                      style: TpmText.body(
                        13,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                )
              else
                for (var i = 0; i < _leaders.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: PortalCard(
                      radius: 14,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      onTap: () => _openForm(leader: _leaders[i]),
                      child: Row(
                        children: [
                          InitialsAvatar(
                            initials: _leaders[i].initials,
                            color: MockData.avatarFor(i),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _leaders[i].name,
                                  style: TpmText.body(
                                    14.5,
                                    color: TpmColors.portalInk,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  [
                                    if (_leaders[i].title.isNotEmpty)
                                      _leaders[i].title,
                                    if (_leaders[i].branch.isNotEmpty)
                                      _leaders[i].branch,
                                  ].join(' · '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TpmText.body(
                                    11.5,
                                    color: Colors.white.withValues(alpha: 0.45),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
