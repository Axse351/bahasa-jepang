import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ReviewCard extends StatelessWidget {
  final int cardsDue;
  final VoidCallback? onStartReview;

  const ReviewCard({super.key, required this.cardsDue, this.onStartReview});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.softBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$cardsDue kartu siap direview',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Luangkan waktu sebentar untuk review harian',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onStartReview,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(160, 46),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: const Text('Mulai Review'),
          ),
        ],
      ),
    );
  }
}
