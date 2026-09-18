import 'supabase_service.dart';

class DashboardStats {
  final int kanjiMastered;
  final int kanjiTotal;
  final int vocabMastered;
  final int vocabTotal;
  final int reviewsDueToday;
  final double accuracyPercent;
  final int streakDays;

  DashboardStats({
    required this.kanjiMastered,
    required this.kanjiTotal,
    required this.vocabMastered,
    required this.vocabTotal,
    required this.reviewsDueToday,
    required this.accuracyPercent,
    required this.streakDays,
  });
}

class DeckProgress {
  final String title;
  final String subtitle;
  final double progress;

  DeckProgress({
    required this.title,
    required this.subtitle,
    required this.progress,
  });
}

class DashboardRepository {
  final _client = SupabaseService.client;

  /// Null kalau belum login (login masih hardcoded, belum pakai Supabase Auth)
  String? get _userIdOrNull => _client.auth.currentUser?.id;

  Future<DashboardStats> loadStats() async {
    // --- Bagian ini PUBLIK, tidak butuh login ---
    final kanjiTotalRes = await _client
        .from('kanji')
        .select()
        .eq('jlpt_level', 5)
        .count();
    final vocabTotalRes = await _client
        .from('vocabulary')
        .select()
        .eq('jlpt_level', 5)
        .count();

    final kanjiTotal = kanjiTotalRes.count;
    final vocabTotal = vocabTotalRes.count;

    final userId = _userIdOrNull;

    // --- Belum login -> semua data personal jadi 0, tidak error ---
    if (userId == null) {
      return DashboardStats(
        kanjiMastered: 0,
        kanjiTotal: kanjiTotal,
        vocabMastered: 0,
        vocabTotal: vocabTotal,
        reviewsDueToday: 0,
        accuracyPercent: 0,
        streakDays: 0,
      );
    }

    // --- Sudah login -> ambil data personal asli ---
    final kanjiMasteredRes = await _client
        .from('user_progress')
        .select()
        .eq('user_id', userId)
        .eq('item_type', 'kanji')
        .eq('status', 'mastered')
        .count();

    final vocabMasteredRes = await _client
        .from('user_progress')
        .select()
        .eq('user_id', userId)
        .eq('item_type', 'vocabulary')
        .eq('status', 'mastered')
        .count();

    final dueRes = await _client
        .from('user_progress')
        .select()
        .eq('user_id', userId)
        .lte('next_review_at', DateTime.now().toIso8601String())
        .count();

    final since = DateTime.now().subtract(const Duration(days: 30));
    final logs = await _client
        .from('review_logs')
        .select('rating')
        .eq('user_id', userId)
        .gte('reviewed_at', since.toIso8601String());

    double accuracy = 0;
    if (logs.isNotEmpty) {
      final correct = logs
          .where((l) => l['rating'] == 'good' || l['rating'] == 'easy')
          .length;
      accuracy = (correct / logs.length) * 100;
    }

    final streak = await _calculateStreak(userId);

    return DashboardStats(
      kanjiMastered: kanjiMasteredRes.count,
      kanjiTotal: kanjiTotal,
      vocabMastered: vocabMasteredRes.count,
      vocabTotal: vocabTotal,
      reviewsDueToday: dueRes.count,
      accuracyPercent: accuracy,
      streakDays: streak,
    );
  }

  Future<int> _calculateStreak(String userId) async {
    final logs = await _client
        .from('review_logs')
        .select('reviewed_at')
        .eq('user_id', userId)
        .order('reviewed_at', ascending: false)
        .limit(500);

    if (logs.isEmpty) return 0;

    final days = <DateTime>{};
    for (final log in logs) {
      final dt = DateTime.parse(log['reviewed_at'] as String).toLocal();
      days.add(DateTime(dt.year, dt.month, dt.day));
    }

    var today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    var cursor = today;
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Future<List<DeckProgress>> loadDeckProgress() async {
    // --- Total, PUBLIK, tidak butuh login ---
    final kanjiTotalRes = await _client
        .from('kanji')
        .select()
        .eq('jlpt_level', 5)
        .count();
    final vocabTotalRes = await _client
        .from('vocabulary')
        .select()
        .eq('jlpt_level', 5)
        .count();

    final kanjiTotal = kanjiTotalRes.count;
    final vocabTotal = vocabTotalRes.count;

    final userId = _userIdOrNull;

    // --- Belum login -> progress 0% tapi total tetap asli ---
    if (userId == null) {
      return [
        DeckProgress(
          title: 'Kanji N5',
          subtitle: '$kanjiTotal kanji',
          progress: 0,
        ),
        DeckProgress(
          title: 'Kosakata N5',
          subtitle: '$vocabTotal kosakata',
          progress: 0,
        ),
        DeckProgress(title: 'Hiragana', subtitle: '104 karakter', progress: 0),
        DeckProgress(title: 'Katakana', subtitle: '104 karakter', progress: 0),
      ];
    }

    // --- Sudah login -> progress asli ---
    final kanjiDoneRes = await _client
        .from('user_progress')
        .select()
        .eq('user_id', userId)
        .eq('item_type', 'kanji')
        .eq('status', 'mastered')
        .count();

    final vocabDoneRes = await _client
        .from('user_progress')
        .select()
        .eq('user_id', userId)
        .eq('item_type', 'vocabulary')
        .eq('status', 'mastered')
        .count();

    final kTotalSafe = kanjiTotal == 0 ? 1 : kanjiTotal;
    final vTotalSafe = vocabTotal == 0 ? 1 : vocabTotal;

    return [
      DeckProgress(
        title: 'Kanji N5',
        subtitle: '$kanjiTotal kanji',
        progress: kanjiDoneRes.count / kTotalSafe,
      ),
      DeckProgress(
        title: 'Kosakata N5',
        subtitle: '$vocabTotal kosakata',
        progress: vocabDoneRes.count / vTotalSafe,
      ),
      DeckProgress(
        title: 'Hiragana',
        subtitle: '104 karakter',
        progress: 0, // nanti disambungkan ke data asli
      ),
      DeckProgress(
        title: 'Katakana',
        subtitle: '104 karakter',
        progress: 0, // nanti disambungkan ke data asli
      ),
    ];
  }
}
