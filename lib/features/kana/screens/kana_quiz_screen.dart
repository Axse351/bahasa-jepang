import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/kana_repository.dart';
import '../../../core/services/sound_service.dart';

class KanaQuizScreen extends StatefulWidget {
  final String type; // 'hiragana' | 'katakana'

  const KanaQuizScreen({super.key, required this.type});

  @override
  State<KanaQuizScreen> createState() => _KanaQuizScreenState();
}

class _KanaQuizScreenState extends State<KanaQuizScreen> {
  final _repo = KanaRepository();
  final _random = Random();

  List<KanaItem> _allKana = [];
  List<KanaItem> _questions = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;

  List<String> _options = [];
  String? _selectedAnswer;
  bool _answered = false;

  bool _loading = true;
  String? _error;

  static const _sessionSize = 15;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final kana = await _repo.loadKana(widget.type);
      kana.shuffle(_random);
      setState(() {
        _allKana = kana;
        _questions = kana.take(_sessionSize).toList();
        _loading = false;
      });
      _prepareOptions();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _prepareOptions() {
    if (_currentIndex >= _questions.length) return;

    final correct = _questions[_currentIndex];
    final distractorPool = _allKana.where((k) => k.id != correct.id).toList()
      ..shuffle(_random);
    final distractors = distractorPool.take(3).map((k) => k.romaji).toList();

    final options = [correct.romaji, ...distractors]..shuffle(_random);

    setState(() {
      _options = options;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  void _selectAnswer(String answer) {
    if (_answered) return;

    final correct = _questions[_currentIndex];
    final isCorrect = answer == correct.romaji;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (isCorrect) {
        _correctCount++;
      } else {
        _wrongCount++;
      }
    });

    if (isCorrect) {
      SoundService.playCorrect();
    } else {
      SoundService.playWrong();
    }

    _repo.logAttempt(kanaId: correct.id, correct: isCorrect);

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (_currentIndex < _questions.length - 1) {
        setState(() => _currentIndex++);
        _prepareOptions();
      } else {
        setState(() => _currentIndex++);
      }
    });
  }

  Color _optionColor(String option) {
    if (!_answered) return Colors.white;
    final correct = _questions[_currentIndex].romaji;
    if (option == correct) return Colors.green.shade100;
    if (option == _selectedAnswer) return Colors.red.shade100;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == 'hiragana' ? 'Kuis Hiragana' : 'Kuis Katakana';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (_loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_error != null) {
              return Center(child: Text('Gagal memuat data: $_error'));
            }
            if (_questions.isEmpty) {
              return const Center(
                child: Text('Belum ada data kana untuk kuis.'),
              );
            }

            final isFinished = _currentIndex >= _questions.length;
            return isFinished ? _buildResultView() : _buildQuestionView();
          },
        ),
      ),
    );
  }

  Widget _buildQuestionView() {
    final current = _questions[_currentIndex];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            backgroundColor: AppTheme.border,
            valueColor: const AlwaysStoppedAnimation(AppTheme.primaryBlue),
          ),
          const SizedBox(height: 8),
          Text(
            'Soal ${_currentIndex + 1} dari ${_questions.length}',
            style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          const Spacer(),
          Text(
            current.karakter,
            style: const TextStyle(fontSize: 96, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih romaji yang benar',
            style: TextStyle(color: AppTheme.textMuted),
          ),
          const Spacer(),
          for (final option in _options) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _selectAnswer(option),
                style: OutlinedButton.styleFrom(
                  backgroundColor: _optionColor(option),
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: AppTheme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final total = _correctCount + _wrongCount;
    final percent = total == 0 ? 0 : (_correctCount / total * 100).round();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(height: 16),
            Text(
              '$percent%',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Benar $_correctCount, Salah $_wrongCount dari $total soal',
              style: const TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                    _correctCount = 0;
                    _wrongCount = 0;
                    _allKana.shuffle(_random);
                    _questions = _allKana.take(_sessionSize).toList();
                  });
                  _prepareOptions();
                },
                child: const Text('Ulangi Kuis'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kembali ke Daftar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
