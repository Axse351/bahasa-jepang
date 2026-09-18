import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class JlptScreen extends StatelessWidget {
  const JlptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.washi,
      appBar: AppBar(
        title: const Text(
          'JLPT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎌', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              const Text(
                'Segera Hadir',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Simulasi & progres ujian JLPT N5-N1 sedang dipersiapkan.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
