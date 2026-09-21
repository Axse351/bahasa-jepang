import 'package:supabase_flutter/supabase_flutter.dart';

/// Model satu karakter kana, sesuai kolom tabel `kana` di Supabase.
class KanaItem {
  final int id;
  final String type; // 'hiragana' | 'katakana'
  final String groupName; // 'seion' | 'dakuon' | 'handakuon' | 'yoon'
  final String karakter;
  final String romaji;

  KanaItem({
    required this.id,
    required this.type,
    required this.groupName,
    required this.karakter,
    required this.romaji,
  });

  factory KanaItem.fromMap(Map<String, dynamic> map) {
    return KanaItem(
      id: map['id'] as int,
      type: map['type'] as String,
      groupName: map['group_name'] as String,
      karakter: map['karakter'] as String,
      romaji: map['romaji'] as String,
    );
  }
}

/// Mengambil data hiragana/katakana dari Supabase, dan mencatat progress
/// belajar user ke `user_progress` + `review_logs` (sistem yang sama
/// dengan kanji & kosakata, dipakai juga oleh dashboard nantinya).
class KanaRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<KanaItem>> loadKana(String type) async {
    final response = await _client
        .from('kana')
        .select()
        .eq('type', type)
        .order('id', ascending: true);

    final data = response as List<dynamic>;
    return data
        .map((e) => KanaItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Mencatat hasil satu soal kuis. Kalau user belum login, percobaan
  /// tidak dicatat (tidak melempar error, supaya kuis tetap jalan).
  Future<void> logAttempt({required int kanaId, required bool correct}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final existing = await _client
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('item_type', 'kana')
          .eq('item_id', kanaId)
          .maybeSingle();

      final currentStreak = existing == null
          ? 0
          : (existing['correct_streak'] as int? ?? 0);

      final newStreak = correct ? currentStreak + 1 : 0;
      final newStatus = newStreak >= 3 ? 'mastered' : 'learning';
      final nextReview = correct
          ? DateTime.now().add(Duration(days: newStreak >= 3 ? 7 : newStreak))
          : DateTime.now();

      await _client.from('user_progress').upsert({
        'user_id': userId,
        'item_type': 'kana',
        'item_id': kanaId,
        'correct_streak': newStreak,
        'status': newStatus,
        'next_review_at': nextReview.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      await _client.from('review_logs').insert({
        'user_id': userId,
        'item_type': 'kana',
        'item_id': kanaId,
        'rating': correct ? 'good' : 'again',
      });
    } catch (_) {
      // Jangan sampai gagal mencatat progress mengganggu jalannya kuis.
    }
  }
}
