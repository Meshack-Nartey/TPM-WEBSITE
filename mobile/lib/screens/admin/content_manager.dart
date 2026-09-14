import 'package:flutter/material.dart';

import '../../app/navigation.dart';
import '../../app/session.dart';
import '../../services/auth_api.dart';
import '../../theme/tpm_theme.dart';
import '../../widgets/common.dart';

/// A generic admin list+form pair for the simple "office content" tables —
/// Branches, Worker Groups, Giving Channels, Books, Events — that are all
/// the same shape (a flat set of text fields, an id, optional booleans) and
/// only differ in which fields they have. One engine here instead of five
/// near-identical screen pairs.

class ContentField {
  const ContentField({
    required this.key,
    required this.label,
    this.hint = '',
    this.maxLines = 1,
    this.required = false,
  });

  final String key;
  final String label;
  final String hint;
  final int maxLines;
  final bool required;
}

class ContentBoolField {
  const ContentBoolField({required this.key, required this.label});

  final String key;
  final String label;
}

class ContentListScreen<T> extends StatefulWidget {
  const ContentListScreen({
    super.key,
    required this.title,
    required this.eyebrow,
    required this.addLabel,
    required this.icon,
    required this.fields,
    this.boolFields = const [],
    required this.fetch,
    required this.idOf,
    required this.titleOf,
    required this.subtitleOf,
    required this.valuesOf,
    required this.create,
    required this.update,
    required this.delete,
  });

  final String title;
  final String eyebrow;
  final String addLabel;
  final IconData icon;
  final List<ContentField> fields;
  final List<ContentBoolField> boolFields;
  final Future<List<T>> Function(String token) fetch;
  final String Function(T item) idOf;
  final String Function(T item) titleOf;
  final String Function(T item) subtitleOf;
  final Map<String, dynamic> Function(T item) valuesOf;
  final Future<void> Function(String token, Map<String, dynamic> values) create;
  final Future<void> Function(
    String token,
    String id,
    Map<String, dynamic> values,
  )
  update;
  final Future<void> Function(String token, String id) delete;

  @override
  State<ContentListScreen<T>> createState() => _ContentListScreenState<T>();
}

class _ContentListScreenState<T> extends State<ContentListScreen<T>> {
  bool _loaded = false;
  bool _loading = true;
  String? _error;
  List<T> _items = const [];

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
      final items = await widget.fetch(token);
      if (!mounted) return;
      setState(() {
        _items = items;
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

  Future<void> _openForm({T? item}) async {
    final changed = await pushScreen<bool>(
      context,
      _ContentFormScreen<T>(config: widget, item: item),
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
                        child: Icon(
                          widget.icon,
                          color: TpmColors.night,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.addLabel,
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
              else if (_items.isEmpty)
                PortalCard(
                  padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    horizontal: 20,
                  ),
                  child: Center(
                    child: Text(
                      'Nothing added yet.',
                      style: TpmText.body(
                        13,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                )
              else
                for (final item in _items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: PortalCard(
                      radius: 14,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      onTap: () => _openForm(item: item),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.titleOf(item),
                                  style: TpmText.body(
                                    14.5,
                                    color: TpmColors.portalInk,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                if (widget.subtitleOf(item).isNotEmpty)
                                  Text(
                                    widget.subtitleOf(item),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TpmText.body(
                                      11.5,
                                      color: Colors.white.withValues(
                                        alpha: 0.45,
                                      ),
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

class _ContentFormScreen<T> extends StatefulWidget {
  const _ContentFormScreen({required this.config, this.item});

  final ContentListScreen<T> config;
  final T? item;

  @override
  State<_ContentFormScreen<T>> createState() => _ContentFormScreenState<T>();
}

class _ContentFormScreenState<T> extends State<_ContentFormScreen<T>> {
  late final Map<String, TextEditingController> _controllers = {
    for (final f in widget.config.fields)
      f.key: TextEditingController(
        text: widget.item == null
            ? ''
            : (widget.config.valuesOf(widget.item as T)[f.key] as String? ??
                  ''),
      ),
  };

  late final Map<String, bool> _bools = {
    for (final f in widget.config.boolFields)
      f.key: widget.item == null
          ? false
          : (widget.config.valuesOf(widget.item as T)[f.key] as bool? ?? false),
  };

  bool _saving = false;
  bool _deleting = false;
  String? _error;

  bool get _editing => widget.item != null;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final values = <String, dynamic>{
      for (final entry in _controllers.entries)
        entry.key: entry.value.text.trim(),
      ..._bools,
    };

    for (final field in widget.config.fields) {
      if (field.required && (values[field.key] as String).isEmpty) {
        setState(() => _error = 'Fill in ${field.label.toLowerCase()}.');
        return;
      }
    }

    final token = AppSession.of(context).token;
    if (token == null) {
      setState(() => _error = 'Sign in to save.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      if (_editing) {
        await widget.config.update(
          token,
          widget.config.idOf(widget.item as T),
          values,
        );
      } else {
        await widget.config.create(token, values);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_editing ? 'Saved' : 'Added'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.message;
      });
    }
  }

  Future<void> _delete() async {
    final token = AppSession.of(context).token;
    if (token == null || widget.item == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: TpmColors.nightRaised,
        title: Text(
          'Remove this entry?',
          style: TpmText.body(
            15,
            color: TpmColors.portalInk,
            weight: FontWeight.w700,
          ),
        ),
        content: Text(
          "It won't appear in the app anymore. This can't be undone.",
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

    setState(() => _deleting = true);
    try {
      await widget.config.delete(token, widget.config.idOf(widget.item as T));
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _deleting = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpmColors.night,
      body: SafeArea(
        child: ListView(
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
                      Eyebrow(
                        _editing ? 'Edit' : 'New',
                        color: TpmColors.portalGold,
                        size: 10,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _editing ? 'Edit entry' : widget.config.addLabel,
                        style: TpmText.display(22, color: TpmColors.portalInk),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            for (final field in widget.config.fields) ...[
              TpmField(
                label: field.label,
                hint: field.hint,
                dark: true,
                maxLines: field.maxLines,
                controller: _controllers[field.key],
              ),
              const SizedBox(height: 14),
            ],
            for (final field in widget.config.boolFields)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: TpmColors.nightSurface,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          field.label,
                          style: TpmText.body(13.5, color: TpmColors.portalInk),
                        ),
                      ),
                      Switch.adaptive(
                        value: _bools[field.key] ?? false,
                        activeThumbColor: Colors.white,
                        activeTrackColor: TpmColors.portalGold,
                        onChanged: (v) => setState(() => _bools[field.key] = v),
                      ),
                    ],
                  ),
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: 4),
              Text(
                _error!,
                style: TpmText.body(
                  12.5,
                  color: TpmColors.danger,
                  weight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 8),
            TpmButton.gold(
              label: _saving ? 'Saving…' : (_editing ? 'Save changes' : 'Add'),
              icon: Icons.check_rounded,
              height: 50,
              onPressed: (_saving || _deleting) ? null : _save,
            ),
            if (_editing) ...[
              const SizedBox(height: 10),
              TpmOutlineButton(
                label: _deleting ? 'Removing…' : 'Remove',
                icon: Icons.delete_outline_rounded,
                foreground: TpmColors.danger,
                background: TpmColors.danger.withValues(alpha: 0.08),
                borderColor: TpmColors.danger.withValues(alpha: 0.25),
                onPressed: (_saving || _deleting) ? null : _delete,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
