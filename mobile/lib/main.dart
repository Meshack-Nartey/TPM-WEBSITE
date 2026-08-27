import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/session.dart';
import 'screens/auth/splash_screen.dart';
import 'theme/tpm_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final session = AppSession();
  await session.restore();

  runApp(TpmApp(session: session));
}

class TpmApp extends StatefulWidget {
  const TpmApp({super.key, required this.session});

  final AppSession session;

  @override
  State<TpmApp> createState() => _TpmAppState();
}

class _TpmAppState extends State<TpmApp> {
  late final _session = widget.session;

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SessionProvider(
      session: _session,
      child: MaterialApp(
        title: 'Transformation Project Ministries',
        debugShowCheckedModeBanner: false,
        // The member surface is the app's default. Portal screens opt into the
        // dark theme themselves rather than flipping the whole app over.
        theme: TpmTheme.light(),
        darkTheme: TpmTheme.light(),
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}
