import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/screens/login_screen.dart'; // atau screen awal kamu

class NihongoApp extends StatelessWidget {
  const NihongoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Basjep',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode, // <-- ini kuncinya, ikut ValueNotifier
          home: const LoginScreen(), // sesuaikan dengan home kamu yang sekarang
        );
      },
    );
  }
}
