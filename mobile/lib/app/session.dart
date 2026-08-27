import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

const _tokenKey = 'auth_token';
const _userKey = 'auth_user';

/// Who is signed in, for as long as the app is open.
///
/// A real sign-in ([signInWithAuth]) carries the API's JWT and the decoded
/// user, persisted to disk so the session survives a restart. [signInAs]
/// remains for the parts of the app auth doesn't cover yet — the "continue as
/// guest" link and the role-preview picker used to reach leader/admin screens
/// without a real leader/admin account.
class AppSession extends ChangeNotifier {
  AppRole _role = AppRole.guest;
  String? _token;
  AppUser? _user;

  AppRole get role => _role;
  String? get token => _token;
  AppUser? get user => _user;

  bool get isSignedIn => _role != AppRole.guest;

  /// Leaders and admins can cross into the gold-on-black work portal.
  bool get canEnterPortal => _role.hasPortal;

  void signInAs(AppRole role) {
    if (_role == role && _token == null) return;
    _role = role;
    _token = null;
    _user = null;
    notifyListeners();
  }

  /// A real sign-in or registration against the API.
  Future<void> signInWithAuth(String token, AppUser user) async {
    _token = token;
    _user = user;
    _role = user.role;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Loads a previously-persisted session, if there is one. Called once at
  /// app start, before the first frame — see `main.dart`.
  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userJson = prefs.getString(_userKey);
    if (token == null || userJson == null) return;

    try {
      final user = AppUser.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      _token = token;
      _user = user;
      _role = user.role;
    } catch (_) {
      // Corrupted stash — fall back to signed out rather than crash.
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    }
  }

  void signOut() {
    _role = AppRole.guest;
    _token = null;
    _user = null;
    notifyListeners();

    SharedPreferences.getInstance().then((prefs) {
      prefs.remove(_tokenKey);
      prefs.remove(_userKey);
    });
  }

  /// Makes the session available to the whole tree without pulling in a state
  /// management package for what is, so far, a single field.
  static AppSession of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_SessionScope>();
    assert(scope != null, 'No AppSession found in the widget tree');
    return scope!.session;
  }
}

class SessionProvider extends StatelessWidget {
  const SessionProvider({super.key, required this.session, required this.child});

  final AppSession session;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: session,
      builder: (context, _) => _SessionScope(
        session: session,
        role: session.role,
        child: child,
      ),
    );
  }
}

class _SessionScope extends InheritedWidget {
  const _SessionScope({
    required this.session,
    required this.role,
    required super.child,
  });

  final AppSession session;

  /// Held separately so dependents rebuild when the role changes.
  final AppRole role;

  @override
  bool updateShouldNotify(_SessionScope oldWidget) => oldWidget.role != role;
}
