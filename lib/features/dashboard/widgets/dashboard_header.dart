import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  final String username;
  final int streakDays;

  const DashboardHeader({
    super.key,
    required this.username,
    this.streakDays = 0,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = username.isEmpty
        ? username
        : username[0].toUpperCase() + username.substring(1);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.deepBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Expanded supaya kolom nama menyusut duluan kalau ruang sempit,
              // bukan mendorong badge streak keluar (overflow).
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat datang,',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orangeAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streakDays hari',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Terus semangat belajar bahasa Jepang! 頑張って',
            style: TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
          ),
        ],
      ),
    );
  }
}
