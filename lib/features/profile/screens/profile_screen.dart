import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';
import '../../auth/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppTheme.torii),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await Supabase.instance.client.auth.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? '-';
    final avatarLetter = email.isNotEmpty ? email[0].toUpperCase() : '?';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.appBarTheme.foregroundColor,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.torii,
                    child: Text(
                      avatarLetter,
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    email,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Container(
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.sakura,
                ),
              ),
              child: Column(
                children: [
                  // ==== Toggle Dark Mode ====
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: ThemeController.instance.themeMode,
                    builder: (context, mode, _) {
                      final darkActive = mode == ThemeMode.dark;
                      return SwitchListTile(
                        secondary: Icon(
                          darkActive
                              ? Icons.dark_mode_outlined
                              : Icons.light_mode_outlined,
                          color: AppTheme.textMuted,
                        ),
                        title: const Text('Mode Gelap'),
                        value: darkActive,
                        activeColor: AppTheme.torii,
                        onChanged: (value) {
                          ThemeController.instance.toggleTheme(value);
                        },
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.settings_outlined,
                      color: AppTheme.textMuted,
                    ),
                    title: const Text('Pengaturan'),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppTheme.textMuted,
                    ),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.help_outline,
                      color: AppTheme.textMuted,
                    ),
                    title: const Text('Bantuan'),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppTheme.textMuted,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout, color: AppTheme.torii),
              label: const Text(
                'Keluar',
                style: TextStyle(color: AppTheme.torii),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppTheme.torii),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
