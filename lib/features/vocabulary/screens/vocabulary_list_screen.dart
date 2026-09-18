import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/vocabulary_repository.dart';
import '../../writing/screens/writing_practice_screen.dart';
import 'vocabulary_quiz_screen.dart';

class VocabularyListScreen extends StatefulWidget {
  final int level;
  const VocabularyListScreen({super.key, this.level = 5});

  @override
  State<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  final _repo = VocabularyRepository();
  late Future<List<VocabularyItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.loadVocabulary(level: widget.level);
  }

  void _showDetail(VocabularyItem vocab) {
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
                  vocab.kata,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  vocab.reading,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  vocab.arti,
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              if (vocab.partOfSpeech != null) ...[
                const SizedBox(height: 4),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.softBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      vocab.partOfSpeech!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ],
              if (vocab.contohKalimat != null) ...[
                const SizedBox(height: 24),
                const Text(
                  'Contoh Kalimat',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 6),
                Text(
                  vocab.contohKalimat!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textDark,
                  ),
                ),
                if (vocab.contohKalimatArti != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    vocab.contohKalimatArti!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _openWritingPractice(vocab);
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

  List<VocabularyItem>? _lastLoadedItems;

  void _openWritingPractice(VocabularyItem vocab) {
    final all = (_lastLoadedItems ?? [vocab]);
    final index = all.indexWhere((v) => v.id == vocab.id);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WritingPracticeScreen(
          title: 'Latihan Menulis Kosakata',
          characters: all.map((v) => v.kata).toList(),
          labels: all.map((v) => '${v.reading} — ${v.arti}').toList(),
          initialIndex: index == -1 ? 0 : index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kosakata N5')),
      body: FutureBuilder<List<VocabularyItem>>(
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
            return const Center(child: Text('Belum ada data kosakata.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final vocab = items[index];
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
                        onTap: () => _openWritingPractice(vocab),
                        child: Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          child: Text(
                            vocab.kata.characters.isNotEmpty ? vocab.kata : '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: InkWell(
                        onTap: () => _showDetail(vocab),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  vocab.kata,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  vocab.reading,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              vocab.arti,
                              style: const TextStyle(
                                fontSize: 13,
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
              builder: (_) => VocabularyQuizScreen(level: widget.level),
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
