import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class StatItem {
  final String label;
  final String value;
  final IconData icon;

  const StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class StatsGrid extends StatelessWidget {
  final List<StatItem> items;

  const StatsGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.3, // <-- diperbesar tingginya (sebelumnya 1.5)
      ),
      itemBuilder: (context, index) {
        final stat = items[index];
        return Container(
          padding: const EdgeInsets.all(14), // <-- dikurangi dari 16
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(7), // <-- dikurangi dari 8
                decoration: BoxDecoration(
                  color: AppTheme.softBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(stat.icon, color: AppTheme.primaryBlue, size: 18),
              ),
              Text(
                stat.value,
                style: const TextStyle(
                  fontSize: 17, // <-- dikurangi sedikit dari 18
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                stat.label,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppTheme.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
