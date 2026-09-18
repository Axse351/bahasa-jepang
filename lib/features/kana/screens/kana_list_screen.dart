import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/kana_repository.dart';
import '../../writing/screens/writing_practice_screen.dart';
import 'kana_quiz_screen.dart';

class KanaListScreen extends StatefulWidget {
  final String type; // 'hiragana' | 'katakana'

  const KanaListScreen({super.key, required this.type});

  @override
  State<KanaListScreen> createState() => _KanaListScreenState();
}

class _KanaListScreenState extends State<KanaListScreen> {
  final _repo = KanaRepository();
  late Future<List<KanaItem>> _future;

  static const _groupOrder = ['seion', 'dakuon', 'handakuon', 'yoon'];
  static const _groupLabel = {
    'seion': 'Dasar (Seion)',
    'dakuon': 'Bersuara (Dakuon)',
    'handakuon': 'Setengah Bersuara (Handakuon)',
    'yoon': 'Gabungan (Yōon)',
  };

  static const Map<String, List<String>> _canonicalOrder = {
    'hiragana_seion': [
      'あ',
      'い',
      'う',
      'え',
      'お',
      'か',
      'き',
      'く',
      'け',
      'こ',
      'さ',
      'し',
      'す',
      'せ',
      'そ',
      'た',
      'ち',
      'つ',
      'て',
      'と',
      'な',
      'に',
      'ぬ',
      'ね',
      'の',
      'は',
      'ひ',
      'ふ',
      'へ',
      'ほ',
      'ま',
      'み',
      'む',
      'め',
      'も',
      'や',
      'ゆ',
      'よ',
      'ら',
      'り',
      'る',
      'れ',
      'ろ',
      'わ',
      'を',
      'ん',
    ],
    'hiragana_dakuon': [
      'が',
      'ぎ',
      'ぐ',
      'げ',
      'ご',
      'ざ',
      'じ',
      'ず',
      'ぜ',
      'ぞ',
      'だ',
      'ぢ',
      'づ',
      'で',
      'ど',
      'ば',
      'び',
      'ぶ',
      'べ',
      'ぼ',
    ],
    'hiragana_handakuon': ['ぱ', 'ぴ', 'ぷ', 'ぺ', 'ぽ'],
    'hiragana_yoon': [
      'きゃ',
      'きゅ',
      'きょ',
      'しゃ',
      'しゅ',
      'しょ',
      'ちゃ',
      'ちゅ',
      'ちょ',
      'にゃ',
      'にゅ',
      'にょ',
      'ひゃ',
      'ひゅ',
      'ひょ',
      'みゃ',
      'みゅ',
      'みょ',
      'りゃ',
      'りゅ',
      'りょ',
      'ぎゃ',
      'ぎゅ',
      'ぎょ',
      'じゃ',
      'じゅ',
      'じょ',
      'びゃ',
      'びゅ',
      'びょ',
      'ぴゃ',
      'ぴゅ',
      'ぴょ',
    ],
    'katakana_seion': [
      'ア',
      'イ',
      'ウ',
      'エ',
      'オ',
      'カ',
      'キ',
      'ク',
      'ケ',
      'コ',
      'サ',
      'シ',
      'ス',
      'セ',
      'ソ',
      'タ',
      'チ',
      'ツ',
      'テ',
      'ト',
      'ナ',
      'ニ',
      'ヌ',
      'ネ',
      'ノ',
      'ハ',
      'ヒ',
      'フ',
      'ヘ',
      'ホ',
      'マ',
      'ミ',
      'ム',
      'メ',
      'モ',
      'ヤ',
      'ユ',
      'ヨ',
      'ラ',
      'リ',
      'ル',
      'レ',
      'ロ',
      'ワ',
      'ヲ',
      'ン',
    ],
    'katakana_dakuon': [
      'ガ',
      'ギ',
      'グ',
      'ゲ',
      'ゴ',
      'ザ',
      'ジ',
      'ズ',
      'ゼ',
      'ゾ',
      'ダ',
      'ヂ',
      'ヅ',
      'デ',
      'ド',
      'バ',
      'ビ',
      'ブ',
      'ベ',
      'ボ',
    ],
    'katakana_handakuon': ['パ', 'ピ', 'プ', 'ペ', 'ポ'],
    'katakana_yoon': [
      'キャ',
      'キュ',
      'キョ',
      'シャ',
      'シュ',
      'ショ',
      'チャ',
      'チュ',
      'チョ',
      'ニャ',
      'ニュ',
      'ニョ',
      'ヒャ',
      'ヒュ',
      'ヒョ',
      'ミャ',
      'ミュ',
      'ミョ',
      'リャ',
      'リュ',
      'リョ',
      'ギャ',
      'ギュ',
      'ギョ',
      'ジャ',
      'ジュ',
      'ジョ',
      'ビャ',
      'ビュ',
      'ビョ',
      'ピャ',
      'ピュ',
      'ピョ',
    ],
  };

  @override
  void initState() {
    super.initState();
    _future = _repo.loadKana(widget.type);
  }

  List<KanaItem> _sortByCanonicalOrder(List<KanaItem> items, String group) {
    final order = _canonicalOrder['${widget.type}_$group'];
    if (order == null) return items;

    final sorted = [...items];
    sorted.sort((a, b) {
      final indexA = order.indexOf(a.karakter);
      final indexB = order.indexOf(b.karakter);
      final safeA = indexA == -1 ? 9999 : indexA;
      final safeB = indexB == -1 ? 9999 : indexB;
      return safeA.compareTo(safeB);
    });
    return sorted;
  }

  void _openWritingPractice(List<KanaItem> allSorted, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WritingPracticeScreen(
          title: widget.type == 'hiragana'
              ? 'Latihan Menulis Hiragana'
              : 'Latihan Menulis Katakana',
          characters: allSorted.map((k) => k.karakter).toList(),
          labels: allSorted.map((k) => k.romaji).toList(),
          initialIndex: index,
          showStrokeGuide: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == 'hiragana' ? 'Hiragana' : 'Katakana';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: FutureBuilder<List<KanaItem>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada data kana.'));
          }

          final grouped = <String, List<KanaItem>>{};
          for (final item in items) {
            grouped.putIfAbsent(item.groupName, () => []).add(item);
          }

          // Gabungan semua item terurut, dipakai untuk navigasi next/prev
          // di layar latihan menulis lintas grup.
          final allSortedFlat = <KanaItem>[];
          for (final group in _groupOrder) {
            if (grouped.containsKey(group)) {
              allSortedFlat.addAll(
                _sortByCanonicalOrder(grouped[group]!, group),
              );
            }
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              for (final group in _groupOrder)
                if (grouped.containsKey(group)) ...[
                  Text(
                    _groupLabel[group] ?? group,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Builder(
                    builder: (context) {
                      final sortedItems = _sortByCanonicalOrder(
                        grouped[group]!,
                        group,
                      );
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sortedItems.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.9,
                            ),
                        itemBuilder: (context, index) {
                          final kana = sortedItems[index];
                          final flatIndex = allSortedFlat.indexWhere(
                            (k) => k.id == kana.id,
                          );
                          return Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _openWritingPractice(
                                allSortedFlat,
                                flatIndex == -1 ? 0 : flatIndex,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      kana.karakter,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      kana.romaji,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => KanaQuizScreen(type: widget.type),
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
