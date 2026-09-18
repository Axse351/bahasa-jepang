import 'supabase_service.dart';

class VocabularyItem {
  final int id;
  final String kata;
  final String reading;
  final String arti;
  final int? jlptLevel;
  final String? partOfSpeech;
  final String? contohKalimat;
  final String? contohKalimatArti;

  VocabularyItem({
    required this.id,
    required this.kata,
    required this.reading,
    required this.arti,
    this.jlptLevel,
    this.partOfSpeech,
    this.contohKalimat,
    this.contohKalimatArti,
  });

  factory VocabularyItem.fromMap(Map<String, dynamic> map) {
    return VocabularyItem(
      id: map['id'] as int,
      kata: map['kata'] as String,
      reading: map['reading'] as String,
      arti: map['arti'] as String,
      jlptLevel: map['jlpt_level'] as int?,
      partOfSpeech: map['part_of_speech'] as String?,
      contohKalimat: map['contoh_kalimat'] as String?,
      contohKalimatArti: map['contoh_kalimat_arti'] as String?,
    );
  }
}

class VocabularyRepository {
  final _client = SupabaseService.client;

  Future<List<VocabularyItem>> loadVocabulary({int level = 5}) async {
    final res = await _client
        .from('vocabulary')
        .select()
        .eq('jlpt_level', level)
        .order('id');

    return (res as List)
        .map((e) => VocabularyItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Simpan hasil kuis. Kalau belum login (auth masih hardcoded), otomatis di-skip.
  Future<void> logAttempt({
    required int vocabularyId,
    required bool correct,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _client.from('review_logs').insert({
        'user_id': userId,
        'item_type': 'vocabulary',
        'item_id': vocabularyId,
        'rating': correct ? 'good' : 'again',
      });

      await _client.from('user_progress').upsert({
        'user_id': userId,
        'item_type': 'vocabulary',
        'item_id': vocabularyId,
        'status': correct ? 'mastered' : 'learning',
        'last_reviewed_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,item_type,item_id');
    } catch (_) {
      // Diam-diam diabaikan
    }
  }
}
