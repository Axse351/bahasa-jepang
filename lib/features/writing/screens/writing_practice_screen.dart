import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class WritingPracticeScreen extends StatefulWidget {
  final String title;
  final List<String> characters;
  final List<String>? labels;
  final int initialIndex;
  final bool showStrokeGuide;
  final List<int?>? strokeCounts; // hanya diisi untuk kanji

  const WritingPracticeScreen({
    super.key,
    required this.title,
    required this.characters,
    this.labels,
    this.initialIndex = 0,
    this.showStrokeGuide = false,
    this.strokeCounts,
  });

  @override
  State<WritingPracticeScreen> createState() => _WritingPracticeScreenState();
}

class _WritingPracticeScreenState extends State<WritingPracticeScreen> {
  late int _index;
  final List<List<Offset>> _strokes = [];

  static const List<String> _generalRules = [
    'Tulis dari atas ke bawah',
    'Tulis dari kiri ke kanan',
    'Garis horizontal biasanya ditulis sebelum garis vertikal yang berpotongan',
    'Untuk bentuk kotak/bingkai, tulis sisi luar dulu, baru isi di dalamnya, tutup bagian bawah terakhir',
    'Untuk bentuk simetris kiri-kanan, tulis bagian tengah dulu, baru sisi kiri, lalu sisi kanan',
    'Coretan vertikal yang menembus ke bawah biasanya ditulis paling akhir',
    'Coretan horizontal yang menembus biasanya ditulis paling akhir',
    'Tulis dengan gerakan mengalir dan konsisten, jangan mengulang coretan yang sama',
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.characters.length - 1);
  }

  void _clear() {
    setState(() => _strokes.clear());
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.removeLast());
  }

  void _goTo(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.characters.length) return;
    setState(() {
      _index = newIndex;
      _strokes.clear();
    });
  }

  void _showStrokeGuideSheet() {
    final strokeCount =
        (widget.strokeCounts != null && widget.strokeCounts!.length > _index)
        ? widget.strokeCounts![_index]
        : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.rule, color: AppTheme.primaryBlue),
                  const SizedBox(width: 8),
                  const Text(
                    'Panduan Urutan Menulis',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (strokeCount != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.softBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Karakter ini memiliki $strokeCount goresan',
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'Kaidah umum penulisan huruf Jepang:',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < _generalRules.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 10, top: 1),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _generalRules[i],
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: AppTheme.textDark,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final character = widget.characters[_index];
    final label = (widget.labels != null && widget.labels!.length > _index)
        ? widget.labels![_index]
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (widget.showStrokeGuide)
            IconButton(
              onPressed: _showStrokeGuideSheet,
              icon: const Icon(Icons.help_outline),
              tooltip: 'Panduan urutan menulis',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              '${_index + 1} / ${widget.characters.length}',
              style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
            if (label != null) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppTheme.border, width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: GestureDetector(
                      onPanStart: (details) {
                        setState(() {
                          _strokes.add([details.localPosition]);
                        });
                      },
                      onPanUpdate: (details) {
                        setState(() {
                          _strokes.last.add(details.localPosition);
                        });
                      },
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _WritingPainter(
                          character: character,
                          strokes: _strokes,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _undo,
                      icon: const Icon(Icons.undo),
                      label: const Text('Undo'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _clear,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Hapus'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _index > 0 ? () => _goTo(_index - 1) : null,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('Sebelumnya'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _index < widget.characters.length - 1
                          ? () => _goTo(_index + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                      label: const Text('Berikutnya'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _WritingPainter extends CustomPainter {
  final String character;
  final List<List<Offset>> strokes;

  _WritingPainter({required this.character, required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppTheme.border
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      gridPaint,
    );

    final dashPaint = Paint()
      ..color = AppTheme.border.withOpacity(0.6)
      ..strokeWidth = 1;
    _drawDashedLine(
      canvas,
      const Offset(0, 0),
      Offset(size.width, size.height),
      dashPaint,
    );
    _drawDashedLine(
      canvas,
      Offset(size.width, 0),
      Offset(0, size.height),
      dashPaint,
    );

    final fontSize = character.length > 1
        ? size.height * 0.4
        : size.height * 0.7;
    final textPainter = TextPainter(
      text: TextSpan(
        text: character,
        style: TextStyle(
          fontSize: fontSize,
          color: AppTheme.textMuted.withOpacity(0.35),
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width);

    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    final inkPaint = Paint()
      ..color = AppTheme.primaryBlue
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length < 2) {
        canvas.drawCircle(
          stroke.first,
          4,
          inkPaint..style = PaintingStyle.fill,
        );
        inkPaint.style = PaintingStyle.stroke;
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, inkPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 6.0;
    const gapLength = 6.0;
    final totalDistance = (end - start).distance;
    if (totalDistance == 0) return;
    final direction = (end - start) / totalDistance;
    var distance = 0.0;
    while (distance < totalDistance) {
      final segStart = start + direction * distance;
      final segEndDist = (distance + dashLength) > totalDistance
          ? totalDistance
          : (distance + dashLength);
      final segEnd = start + direction * segEndDist;
      canvas.drawLine(segStart, segEnd, paint);
      distance += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant _WritingPainter oldDelegate) {
    return true;
  }
}
