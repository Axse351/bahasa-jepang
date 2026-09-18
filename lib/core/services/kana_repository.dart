import 'supabase_service.dart';

class KanaItem {
  final int id;
  final String karakter;
  final String romaji;
  final String type; // 'hiragana' | 'katakana'
  final String groupName; // 'seion' | 'dakuon' | 'handakuon' | 'yoon'

  KanaItem({
    required this.id,
    required this.karakter,
    required this.romaji,
    required this.type,
    required this.groupName,
  });

  factory KanaItem.fromMap(Map<String, dynamic> map) {
    return KanaItem(
      id: map['id'] as int,
      karakter: map['karakter'] as String,
      romaji: map['romaji'] as String,
      type: map['type'] as String,
      groupName: map['group_name'] as String,
    );
  }
}

class KanaRepository {
  final _client = SupabaseService.client;

  /// Ambil semua kana (hiragana atau katakana), sudah publik jadi tidak butuh login
  Future<List<KanaItem>> loadKana(String type) async {
    final res = await _client
        .from('kana')
        .select()
        .eq('type', type)
        .order('id');

    return (res as List)
        .map((e) => KanaItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Simpan hasil kuis. Kalau belum login (auth masih hardcoded), ini di-skip diam-diam.
  Future<void> logAttempt({required int kanaId, required bool correct}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return; // belum login, tidak disimpan dulu

    try {
      await _client.from('review_logs').insert({
        'user_id': userId,
        'item_type': 'kana',
        'item_id': kanaId,
        'rating': correct ? 'good' : 'again',
      });

      await _client.from('user_progress').upsert({
        'user_id': userId,
        'item_type': 'kana',
        'item_id': kanaId,
        'status': correct ? 'mastered' : 'learning',
        'last_reviewed_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id,item_type,item_id');
    } catch (_) {
      // Diam-diam diabaikan; jangan ganggu pengalaman kuis kalau gagal simpan
    }
  }
}
