import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/dashboard_repository.dart';
import '../../dashboard/widgets/deck_tile.dart';
import '../../kana/screens/kana_list_screen.dart';
import '../../kanji/screens/kanji_list_screen.dart';
import '../../vocabulary/screens/vocabulary_list_screen.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final _repo = DashboardRepository();
  late Future<List<DeckProgress>> _decksFuture;

  @override
  void initState() {
    super.initState();
    _decksFuture = _repo.loadDeckProgress();
  }

  Future<void> _refresh() async {
    setState(() => _decksFuture = _repo.loadDeckProgress());
    await _decksFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.washi,
      appBar: AppBar(
        title: const Text(
          'Belajar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<DeckProgress>>(
            future: _decksFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError || !snap.hasData) {
                return ListView(
                  children: const [
                    SizedBox(height: 80),
                    Center(child: Text('Gagal memuat deck.')),
                  ],
                );
              }

              final decks = snap.data!;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  for (final deck in decks) ...[
                    DeckTile(
                      title: deck.title,
                      subtitle: deck.subtitle,
                      progress: deck.progress.clamp(0.0, 1.0),
                      icon: deck.title.contains('Kanji')
                          ? Icons.brush_outlined
                          : deck.title.contains('Kosakata')
                          ? Icons.menu_book_outlined
                          : Icons.text_fields,
                      onTap: () {
                        if (deck.title == 'Hiragana') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const KanaListScreen(type: 'hiragana'),
                            ),
                          );
                        } else if (deck.title == 'Katakana') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const KanaListScreen(type: 'katakana'),
                            ),
                          );
                        } else if (deck.title == 'Kanji N5') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const KanjiListScreen(level: 5),
                            ),
                          );
                        } else if (deck.title == 'Kosakata N5') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const VocabularyListScreen(level: 5),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
