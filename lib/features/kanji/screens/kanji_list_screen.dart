import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/kanji_repository.dart';
import '../../writing/screens/writing_practice_screen.dart';
import 'kanji_quiz_screen.dart';

class KanjiListScreen extends StatefulWidget {
  final int level;
  const KanjiListScreen({super.key, this.level = 5});

  @override
  State<KanjiListScreen> createState() => _KanjiListScreenState();
}

class _KanjiListScreenState extends State<KanjiListScreen> {
  final _repo = KanjiRepository();
  late Future<List<KanjiItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.loadKanji(level: widget.level);
  }

  void _showDetail(KanjiItem kanji) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  kanji.karakter,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  kanji.arti,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (kanji.onyomi.isNotEmpty) ...[
                const Text(
                  'On\'yomi (bacaan Cina)',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  kanji.onyomi.join('、 '),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (kanji.kunyomi.isNotEmpty) ...[
                const Text(
                  'Kun\'yomi (bacaan Jepang)',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  kanji.kunyomi.join('、 '),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (kanji.strokeCount != null) ...[
                const Text(
                  'Jumlah Goresan',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  '${kanji.strokeCount}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(); // tutup bottom sheet dulu
                    _openWritingPractice(kanji);
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Latihan Menulis'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openWritingPractice(KanjiItem kanji) {
    final all = (_lastLoadedItems ?? [kanji]);
    final index = all.indexWhere((k) => k.id == kanji.id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WritingPracticeScreen(
          title: 'Latihan Menulis Kanji',
          characters: all.map((k) => k.karakter).toList(),
          labels: all.map((k) => k.arti).toList(),
          initialIndex: index == -1 ? 0 : index,
          showStrokeGuide: true,
          strokeCounts: all.map((k) => k.strokeCount).toList(),
        ),
      ),
    );
  }

  List<KanjiItem>? _lastLoadedItems;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kanji N5')),
      body: FutureBuilder<List<KanjiItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          _lastLoadedItems = items;
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada data kanji.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final kanji = items[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Material(
                      color: AppTheme.softBlue,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _openWritingPractice(kanji),
                        child: Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          child: Text(
                            kanji.karakter,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: InkWell(
                        onTap: () => _showDetail(kanji),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kanji.arti,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              [
                                if (kanji.onyomi.isNotEmpty)
                                  kanji.onyomi.join(', '),
                                if (kanji.kunyomi.isNotEmpty)
                                  kanji.kunyomi.join(', '),
                              ].join(' / '),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => KanjiQuizScreen(level: widget.level),
            ),
          );
        },
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.quiz_outlined, color: Colors.white),
        label: const Text('Mulai Kuis', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
