import 'package:supabase_flutter/supabase_flutter.dart';

/// Model satu entri kosakata, sesuai kolom tabel `vocabulary` di Supabase.
class VocabularyItem {
  final int id;
  final int level;
  final String kata;
  final String reading;
  final String arti;
  final String? partOfSpeech;
  final String? contohKalimat;
  final String? contohKalimatArti;

  VocabularyItem({
    required this.id,
    required this.level,
    required this.kata,
    required this.reading,
    required this.arti,
    this.partOfSpeech,
    this.contohKalimat,
    this.contohKalimatArti,
  });

  factory VocabularyItem.fromMap(Map<String, dynamic> map) {
    return VocabularyItem(
      id: map['id'] as int,
      level: map['jlpt_level'] as int,
      kata: map['kata'] as String,
      reading: map['reading'] as String,
      arti: map['arti'] as String,
      partOfSpeech: map['part_of_speech'] as String?,
      contohKalimat: map['contoh_kalimat'] as String?,
      contohKalimatArti: map['contoh_kalimat_arti'] as String?,
    );
  }
}

/// Mengambil data kosakata dari Supabase, per level JLPT (5,4,3,...),
/// dan mencatat progress belajar user (dipakai oleh dashboard).
class VocabularyRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<VocabularyItem>> loadVocabulary({required int level}) async {
    final response = await _client
        .from('vocabulary')
        .select()
        .eq('jlpt_level', level)
        .order('id', ascending: true);

    final data = response as List<dynamic>;
    return data
        .map((e) => VocabularyItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<VocabularyItem?> loadVocabularyById(int id) async {
    final response = await _client
        .from('vocabulary')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return VocabularyItem.fromMap(response);
  }

  /// Mencatat hasil satu soal kuis kosakata ke `user_progress` (status hafal/belum,
  /// dipakai dashboard) dan `review_logs` (riwayat, dipakai untuk akurasi & streak).
  /// Kalau user belum login, tidak dicatat (tidak melempar error, kuis tetap jalan).
  Future<void> logAttempt({
    required int vocabularyId,
    required bool correct,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final existing = await _client
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .eq('item_type', 'vocabulary')
          .eq('item_id', vocabularyId)
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
        'item_type': 'vocabulary',
        'item_id': vocabularyId,
        'correct_streak': newStreak,
        'status': newStatus,
        'next_review_at': nextReview.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      await _client.from('review_logs').insert({
        'user_id': userId,
        'item_type': 'vocabulary',
        'item_id': vocabularyId,
        'rating': correct ? 'good' : 'again',
      });
    } catch (_) {
      // Jangan sampai gagal mencatat progress mengganggu jalannya kuis.
    }
  }
}
