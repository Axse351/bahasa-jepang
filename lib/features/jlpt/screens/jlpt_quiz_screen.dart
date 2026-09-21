import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/quiz_repository.dart';

/// Layar kuis untuk section JLPT.
/// Menampilkan soal pilihan ganda (arti / cara baca / isian kalimat)
/// yang diambil acak dari Supabase, satu per satu, dengan skor di akhir.
class JlptQuizScreen extends StatefulWidget {
  final int level; // 5, 4, 3, ...
  final String? category; // null = campur kanji & kosakata
  final String? questionType; // null = campur semua tipe soal
  final int jumlahSoal;

  const JlptQuizScreen({
    super.key,
    required this.level,
    this.category,
    this.questionType,
    this.jumlahSoal = 10,
  });

  @override
  State<JlptQuizScreen> createState() => _JlptQuizScreenState();
}

class _JlptQuizScreenState extends State<JlptQuizScreen> {
  final _repo = QuizRepository();
  late Future<List<QuizQuestion>> _future;

  int _currentIndex = 0;
  int _score = 0;
  int? _selectedOption;
  bool _showResultForCurrent = false;
  final List<bool> _isCorrectHistory = [];

  @override
  void initState() {
    super.initState();
    _future = _repo.loadQuizSession(
      level: widget.level,
      category: widget.category,
      questionType: widget.questionType,
      count: widget.jumlahSoal,
    );
  }

  void _selectOption(int index, QuizQuestion soal) {
    if (_showResultForCurrent) return;
    setState(() {
      _selectedOption = index;
      _showResultForCurrent = true;
      final benar = index == soal.correctIndex;
      if (benar) _score++;
      _isCorrectHistory.add(benar);
    });
  }

  void _nextQuestion(int total) {
    if (_currentIndex < total - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _showResultForCurrent = false;
      });
    } else {
      setState(() {
        _currentIndex = total; // tandai selesai -> tampilkan ringkasan
      });
    }
  }

  String _labelTipeSoal(String type) {
    switch (type) {
      case 'arti':
        return 'Arti';
      case 'yomikata':
        return 'Cara Baca';
      case 'cloze':
        return 'Isian Kalimat';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.washi,
      appBar: AppBar(title: Text('Kuis JLPT N${widget.level}')),
      body: SafeArea(
        child: FutureBuilder<List<QuizQuestion>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Gagal memuat soal: ${snapshot.error}'),
              );
            }

            final soalList = snapshot.data ?? [];
            if (soalList.isEmpty) {
              return const Center(
                child: Text('Belum ada soal untuk level ini.'),
              );
            }

            if (_currentIndex >= soalList.length) {
              return _buildSummary(soalList.length);
            }

            final soal = soalList[_currentIndex];
            return _buildQuestion(soal, soalList.length);
          },
        ),
      ),
    );
  }

  Widget _buildQuestion(QuizQuestion soal, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (_currentIndex) / total,
              minHeight: 8,
              backgroundColor: AppTheme.border,
              valueColor: const AlwaysStoppedAnimation(AppTheme.primaryBlue),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Soal ${_currentIndex + 1} / $total',
            style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.softBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _labelTipeSoal(soal.questionType),
              style: const TextStyle(fontSize: 11, color: AppTheme.primaryBlue),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            soal.question,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          Expanded(
            child: ListView.separated(
              itemCount: soal.options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final isSelected = _selectedOption == index;
                final isCorrectOption = index == soal.correctIndex;

                Color borderColor = AppTheme.border;
                Color bgColor = Colors.white;
                if (_showResultForCurrent) {
                  if (isCorrectOption) {
                    borderColor = const Color(0xFF2E7D32);
                    bgColor = const Color(0xFFE8F5E9);
                  } else if (isSelected && !isCorrectOption) {
                    borderColor = AppTheme.primaryBlue;
                    bgColor = AppTheme.sakura.withOpacity(0.4);
                  }
                }

                return Material(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _selectOption(index, soal),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Text(
                        soal.options[index],
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_showResultForCurrent && soal.explanation != null) ...[
            const SizedBox(height: 8),
            Text(
              soal.explanation!,
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ],

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showResultForCurrent
                  ? () => _nextQuestion(total)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentIndex < total - 1 ? 'Lanjut' : 'Lihat Hasil',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(int total) {
    final persen = total == 0 ? 0 : ((_score / total) * 100).round();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              persen >= 70 ? Icons.emoji_events_outlined : Icons.refresh,
              size: 64,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 16),
            Text(
              'Skor kamu: $_score / $total',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$persen% benar',
              style: const TextStyle(fontSize: 15, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                    _score = 0;
                    _selectedOption = null;
                    _showResultForCurrent = false;
                    _isCorrectHistory.clear();
                    _future = _repo.loadQuizSession(
                      level: widget.level,
                      category: widget.category,
                      questionType: widget.questionType,
                      count: widget.jumlahSoal,
                    );
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Ulangi Kuis'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kembali'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
