import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TaskScreen extends StatelessWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.washi,
      appBar: AppBar(
        title: const Text(
          'Tugas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ),
      body: const _ComingSoon(
        emoji: '📝',
        title: 'Segera Hadir',
        subtitle: 'Fitur tugas harian sedang dalam pengembangan.',
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _ComingSoon({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
