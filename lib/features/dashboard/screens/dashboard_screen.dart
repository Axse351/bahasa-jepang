import 'package:flutter/material.dart';
import '../../../core/services/dashboard_repository.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/stats_grid.dart';
import '../widgets/review_card.dart';
import '../widgets/deck_tile.dart';
import '../../kana/screens/kana_list_screen.dart';
import '../../kanji/screens/kanji_list_screen.dart';
import '../../vocabulary/screens/vocabulary_list_screen.dart';


class DashboardScreen extends StatefulWidget {
  final String username;
  const DashboardScreen({super.key, required this.username});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _repo = DashboardRepository();

  late Future<DashboardStats> _statsFuture;
  late Future<List<DeckProgress>> _decksFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _repo.loadStats();
    _decksFuture = _repo.loadDeckProgress();
  }

  Future<void> _refresh() async {
    setState(() {
      _statsFuture = _repo.loadStats();
      _decksFuture = _repo.loadDeckProgress();
    });
    await Future.wait([_statsFuture, _decksFuture]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<DashboardStats>(
            future: _statsFuture,
            builder: (context, statsSnap) {
              if (statsSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (statsSnap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Gagal memuat data: ${statsSnap.error}'),
                  ),
                );
              }

              final stats = statsSnap.data!;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: DashboardHeader(
                      username: widget.username,
                      streakDays: stats.streakDays,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        StatsGrid(
                          items: [
                            StatItem(
                              label: 'Kanji Dikuasai',
                              value:
                                  '${stats.kanjiMastered} / ${stats.kanjiTotal}',
                              icon: Icons.brush_outlined,
                            ),
                            StatItem(
                              label: 'Kosakata Dikuasai',
                              value:
                                  '${stats.vocabMastered} / ${stats.vocabTotal}',
                              icon: Icons.menu_book_outlined,
                            ),
                            StatItem(
                              label: 'Review Hari Ini',
                              value: '${stats.reviewsDueToday}',
                              icon: Icons.today_outlined,
                            ),
                            StatItem(
                              label: 'Akurasi',
                              value:
                                  '${stats.accuracyPercent.toStringAsFixed(0)}%',
                              icon: Icons.trending_up,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ReviewCard(
                          cardsDue: stats.reviewsDueToday,
                          onStartReview: () {
                            // TODO: arahkan ke halaman review SRS
                          },
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Deck Belajar',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FutureBuilder<List<DeckProgress>>(
                          future: _decksFuture,
                          builder: (context, deckSnap) {
                            if (deckSnap.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (deckSnap.hasError || !deckSnap.hasData) {
                              return const Text('Gagal memuat deck.');
                            }

                            final decks = deckSnap.data!;
                            return Column(
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
                                                const KanaListScreen(
                                                  type: 'hiragana',
                                                ),
                                          ),
                                        );
                                      } else if (deck.title == 'Katakana') {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const KanaListScreen(
                                                  type: 'katakana',
                                                ),
                                          ),
                                        );
                                      } else if (deck.title == 'Kanji N5') {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const KanjiListScreen(level: 5),
                                          ),
                                        );
                                      } else if (deck.title == 'Kosakata N5') {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const VocabularyListScreen(
                                                  level: 5,
                                                ),
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
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
