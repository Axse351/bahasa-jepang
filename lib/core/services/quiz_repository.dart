import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Model satu soal kuis, sesuai kolom tabel `quiz_questions` di Supabase.
class QuizQuestion {
  final int id;
  final int level;
  final String category; // 'kanji' | 'vocabulary'
  final String questionType; // 'arti' | 'yomikata' | 'cloze'
  final String question;
  final List<String> options; // selalu 4 opsi
  final int correctIndex;
  final String? explanation;

  QuizQuestion({
    required this.id,
    required this.level,
    required this.category,
    required this.questionType,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  String get correctAnswer => options[correctIndex];

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] as int,
      level: map['level'] as int,
      category: map['category'] as String,
      questionType: map['question_type'] as String,
      question: map['question'] as String,
      options: (map['options'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      correctIndex: map['correct_index'] as int,
      explanation: map['explanation'] as String?,
    );
  }
}

/// Mengambil bank soal kuis JLPT dari Supabase.
class QuizRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Ambil sesi kuis acak.
  /// [category]: null = campur kanji & kosakata, atau isi 'kanji'/'vocabulary'.
  /// [questionType]: null = campur semua tipe soal, atau isi 'arti'/'yomikata'/'cloze'.
  Future<List<QuizQuestion>> loadQuizSession({
    required int level,
    String? category,
    String? questionType,
    int count = 10,
  }) async {
    var query = _client.from('quiz_questions').select().eq('level', level);

    if (category != null) {
      query = query.eq('category', category);
    }
    if (questionType != null) {
      query = query.eq('question_type', questionType);
    }

    final response = await query;
    final all = (response as List<dynamic>)
        .map((e) => QuizQuestion.fromMap(e as Map<String, dynamic>))
        .toList();

    all.shuffle(Random());
    if (all.length <= count) return all;
    return all.sublist(0, count);
  }
}
