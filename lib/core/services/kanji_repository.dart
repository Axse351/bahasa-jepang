import 'supabase_service.dart';

class KanjiItem {
  final int id;
  final String karakter;
  final String arti;
  final List<String> onyomi;
  final List<String> kunyomi;
  final int? jlptLevel;
  final int? strokeCount;

  KanjiItem({
    required this.id,
    required this.karakter,
    required this.arti,
    required this.onyomi,
    required this.kunyomi,
    this.jlptLevel,
    this.strokeCount,
  });

  factory KanjiItem.fromMap(Map<String, dynamic> map) {
    return KanjiItem(
      id: map['id'] as int,
      karakter: map['karakter'] as String,
      arti: map['arti'] as String,
      onyomi: ((map['onyomi'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      kunyomi: ((map['kunyomi'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      jlptLevel: map['jlpt_level'] as int?,
      strokeCount: map['stroke_count'] as int?,
    );
  }
}

class KanjiRepository {
  final _client = SupabaseService.client;

  Future<List<KanjiItem>> loadKanji({int level = 5}) async {
    final res = await _client
        .from('kanji')
        .select()
        .eq('jlpt_level', level)
        .order('id');

    return (res as List)
        .map((e) => KanjiItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Simpan hasil kuis. Kalau belum login (auth masih hardcoded), otomatis di-skip.
  Future<void> logAttempt({required int kanjiId, required bool correct}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _client.from('review_logs').insert({
        'user_id': userId,
        'item_type': 'kanji',
        'item_id': kanjiId,
        'rating': correct ? 'good' : 'again',
      });

      await _client.from('user_progress').upsert({
        'user_id': userId,
        'item_type': 'kanji',
        'item_id': kanjiId,
        'status': correct ? 'mastered' : 'learning',
        'last_reviewed_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,item_type,item_id');
    } catch (_) {
      // Diam-diam diabaikan
    }
  }
}
