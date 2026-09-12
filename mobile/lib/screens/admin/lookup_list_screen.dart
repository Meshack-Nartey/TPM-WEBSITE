import 'package:flutter/material.dart';

import '../../app/session.dart';
import '../../models/models.dart';
import '../../services/auth_api.dart';
import '../../services/lookups_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// One reference-list category shown on a [LookupListScreen] — a branch,
/// department, fellowship or basenia name that feeds dropdowns elsewhere
/// (registration, weekly reports, the leader directory).
class LookupSection {
  const LookupSection({required this.category, required this.label});

  final String category;
  final String label;
}

/// Generic manager for `backend`'s `Lookup` table — one screen handles
/// Branches, Worker groups, or the combined Fellowships & Basenias view,
/// since they're all the same shape server-side.
class LookupListScreen extends StatefulWidget {
  const LookupListScreen({
    super.key,
    required this.title,
    required this.eyebrow,
    required this.sections,
  });

  final String title;
  final String eyebrow;
  final List<LookupSection> sections;

  @override
  State<LookupListScreen> createState() => _LookupListScreenState();
}

class _LookupListScreenState extends State<LookupListScreen> {
  bool _loaded = false;
  bool _loading = true;
  String? _error;
  List<LookupEntry> _entries = const [];
  late String _activeCategory = widget.sections.first.category;
  final Set<String> _deleting = {};

  final _addController = TextEditingController();
  bool _adding = false;

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

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
      final entries = await LookupsApi(token: token).fetch();
      if (!mounted) return;
      setState(() {
        _entries = entries;
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

  List<LookupEntry> _forCategory(String category) {
    final rows = _entries.where((e) => e.category == category).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return rows;
  }

  Future<void> _add() async {
    final value = _addController.text.trim();
    if (value.isEmpty || _adding) return;
    final token = AppSession.of(context).token;
    if (token == null) return;

    setState(() => _adding = true);
    try {
      final sortOrder = _forCategory(_activeCategory).length;
      final entry = await LookupsApi(
        token: token,
      ).add(_activeCategory, value, sortOrder: sortOrder);
      if (!mounted) return;
      setState(() {
        _entries = [..._entries, entry];
        _adding = false;
        _addController.clear();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _adding = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _delete(LookupEntry entry) async {
    final token = AppSession.of(context).token;
    if (token == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TpmColors.nightRaised,
        title: Text(
          'Remove "${entry.value}"?',
          style: TpmText.body(
            15,
            color: TpmColors.portalInk,
            weight: FontWeight.w700,
          ),
        ),
        content: Text(
          "It won't appear in dropdowns anymore. This can't be undone.",
          style: TpmText.body(13, color: Colors.white.withValues(alpha: 0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TpmText.body(
                13.5,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Remove',
              style: TpmText.body(
                13.5,
                color: TpmColors.danger,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deleting.add(entry.id));
    try {
      await LookupsApi(token: token).delete(entry.id);
      if (!mounted) return;
      setState(() {
        _entries = _entries.where((e) => e.id != entry.id).toList();
        _deleting.remove(entry.id);
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _deleting.remove(entry.id));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.night,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
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
                        Eyebrow(
                          widget.eyebrow,
                          color: TpmColors.portalGold,
                          size: 10,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.title,
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
            ),
            const SizedBox(height: 18),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: TpmColors.portalGold,
                      ),
                    )
                  : _error != null
                  ? _LoadError(message: _error!, onRetry: _load)
                  : RefreshIndicator(
                      color: TpmColors.portalGold,
                      backgroundColor: TpmColors.nightRaised,
                      onRefresh: _load,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
                        children: [
                          for (final section in widget.sections) ...[
                            Eyebrow(
                              section.label,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 10,
                            ),
                            const SizedBox(height: 8),
                            if (_forCategory(section.category).isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Text(
                                  'None yet.',
                                  style: TpmText.body(
                                    12.5,
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                              )
                            else
                              for (final entry in _forCategory(
                                section.category,
                              ))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 9),
                                  child: PortalCard(
                                    radius: 12,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            entry.value,
                                            style: TpmText.body(
                                              13.5,
                                              color: TpmColors.portalInk,
                                              weight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        _deleting.contains(entry.id)
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color:
                                                          TpmColors.portalGold,
                                                    ),
                                              )
                                            : InkWell(
                                                onTap: () => _delete(entry),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  child: Icon(
                                                    Icons.close_rounded,
                                                    size: 17,
                                                    color: Colors.white
                                                        .withValues(alpha: 0.4),
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _loading || _error != null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.sections.length > 1) ...[
                    Row(
                      children: [
                        for (final section in widget.sections) ...[
                          if (section != widget.sections.first)
                            const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChipPill(
                              label: section.label,
                              selected: section.category == _activeCategory,
                              dark: true,
                              expand: true,
                              onTap: () => setState(
                                () => _activeCategory = section.category,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: TpmField(
                          label: 'New value',
                          hint: 'e.g. a new branch name',
                          dark: true,
                          controller: _addController,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: TpmColors.portalGold,
                        borderRadius: BorderRadius.circular(13),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(13),
                          onTap: _adding ? null : _add,
                          child: Container(
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            child: _adding
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: TpmColors.night,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add_rounded,
                                    color: TpmColors.night,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PortalCard(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
        child: Column(
          children: [
            IconTile(
              icon: Icons.wifi_off_rounded,
              background: TpmColors.portalGold.withValues(alpha: 0.1),
              foreground: TpmColors.portalGold,
              size: 54,
              radius: 16,
              iconSize: 24,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TpmText.body(
                13,
                color: TpmColors.portalInk,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            TpmOutlineButton(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              foreground: TpmColors.portalInk,
              background: Colors.white.withValues(alpha: 0.06),
              borderColor: Colors.white.withValues(alpha: 0.15),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
