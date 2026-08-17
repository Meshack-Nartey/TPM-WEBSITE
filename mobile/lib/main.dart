import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/session.dart';
import 'screens/auth/splash_screen.dart';
import 'theme/tpm_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const TpmApp());
}

class TpmApp extends StatefulWidget {
  const TpmApp({super.key});

  @override
  State<TpmApp> createState() => _TpmAppState();
}

class _TpmAppState extends State<TpmApp> {
  final _session = AppSession();

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
