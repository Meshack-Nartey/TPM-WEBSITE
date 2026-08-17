import 'package:flutter/widgets.dart';

import '../models/models.dart';

/// Who is signed in, for as long as the app is open.
///
/// The prototype keeps this in memory only. When the Spring Boot API lands,
/// this is where the JWT and the decoded user belong, backed by secure storage.
class AppSession extends ChangeNotifier {
  AppRole _role = AppRole.guest;

  AppRole get role => _role;

  bool get isSignedIn => _role != AppRole.guest;

  /// Leaders and admins can cross into the gold-on-black work portal.
  bool get canEnterPortal => _role.hasPortal;

  void signInAs(AppRole role) {
    if (_role == role) return;
    _role = role;
    notifyListeners();
  }

  void signOut() {
    _role = AppRole.guest;
    notifyListeners();
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
