import 'package:supabase_flutter/supabase_flutter.dart';

/// Model satu entri kanji, sesuai kolom tabel `kanji` di Supabase.
class KanjiItem {
  final int id;
  final int level;
  final String karakter;
  final String arti;
  final List<String> onyomi;
  final List<String> kunyomi;
  final int? strokeCount;

  KanjiItem({
    required this.id,
    required this.level,
    required this.karakter,
    required this.arti,
    required this.onyomi,
    required this.kunyomi,
    this.strokeCount,
  });

  factory KanjiItem.fromMap(Map<String, dynamic> map) {
    return KanjiItem(
      id: map['id'] as int,
      level: map['jlpt_level'] as int,
      karakter: map['karakter'] as String,
      arti: map['arti'] as String,
      onyomi: (map['onyomi'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      kunyomi: (map['kunyomi'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      strokeCount: map['stroke_count'] as int?,
    );
  }
}

/// Mengambil data kanji dari Supabase, per level JLPT (5,4,3,...),
/// dan mencatat progress belajar user (dipakai oleh dashboard).
class KanjiRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<KanjiItem>> loadKanji({required int level}) async {
    final response = await _client
        .from('kanji')
        .select()
        .eq('jlpt_level', level)
        .order('id', ascending: true);

    final data = response as List<dynamic>;
    return data
        .map((e) => KanjiItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Ambil satu kanji spesifik berdasarkan id (dipakai misal untuk deep-link).
  Future<KanjiItem?> loadKanjiById(int id) async {
    final response = await _client
        .from('kanji')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return KanjiItem.fromMap(response);
  }

  /// Mencatat hasil satu soal kuis kanji ke `user_progress` (status hafal/belum,
  /// dipakai dashboard) dan `review_logs` (riwayat, dipakai untuk akurasi & streak).
  /// Kalau user belum login, tidak dicatat (tidak melempar error, kuis tetap jalan).
  Future<void> logAttempt({required int kanjiId, required bool correct}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Ambil progress saat ini (kalau belum ada, mulai dari nol).
      final existing = await _client
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('item_type', 'kanji')
          .eq('item_id', kanjiId)
          .maybeSingle();

      final currentStreak = existing == null
          ? 0
          : (existing['correct_streak'] as int? ?? 0);

      final newStreak = correct ? currentStreak + 1 : 0;
      final newStatus = newStreak >= 3
          ? 'mastered'
          : (newStreak > 0 ? 'learning' : 'learning');
      final nextReview = correct
          ? DateTime.now().add(Duration(days: newStreak >= 3 ? 7 : newStreak))
          : DateTime.now();

      await _client.from('user_progress').upsert({
        'user_id': userId,
        'item_type': 'kanji',
        'item_id': kanjiId,
        'correct_streak': newStreak,
        'status': newStatus,
        'next_review_at': nextReview.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      await _client.from('review_logs').insert({
        'user_id': userId,
        'item_type': 'kanji',
        'item_id': kanjiId,
        'rating': correct ? 'good' : 'again',
      });
    } catch (_) {
      // Jangan sampai gagal mencatat progress mengganggu jalannya kuis.
    }
  }
}
