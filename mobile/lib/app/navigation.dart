import 'package:flutter/material.dart';

/// The five primary destinations on the member surface.
enum MemberTab { home, media, events, give, more }

/// The four primary destinations in the work portal. Leaders and admins get
/// different sets, so the labels live with the shell rather than here.
enum PortalTab { first, second, third, fourth }

/// Pushes a screen with the standard transition. Kept in one place so detail
/// screens are opened the same way everywhere.
Future<T?> pushScreen<T>(BuildContext context, Widget screen) {
  return Navigator.of(context).push<T>(
    MaterialPageRoute(builder: (_) => screen),
  );
}
