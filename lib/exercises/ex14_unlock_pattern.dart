import 'dart:math' as math;

import 'package:flutter/material.dart';

class Ex14UnlockPattern extends StatefulWidget {
  const Ex14UnlockPattern({Key? key}) : super(key: key);

  @override
  State<Ex14UnlockPattern> createState() => _Ex14UnlockPatternState();
}

class _Ex14UnlockPatternState extends State<Ex14UnlockPattern>
    with TickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final AnimationController _successController;

  final List<int> _selected = [];
  final List<int> _answer = const [0, 1, 2, 5, 8];

  Offset? _dragPosition;
  _PatternResult _result = _PatternResult.idle;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _start(DragStartDetails details) {
    _shakeController.stop();
    _successController.stop();
    _shakeController.value = 0;
    _successController.value = 0;

    setState(() {
      _selected.clear();
      _dragPosition = details.localPosition;
      _result = _PatternResult.drawing;
      _addPoint(details.localPosition, const Size(300, 300));
    });
  }

  void _update(DragUpdateDetails details) {
    if (_result != _PatternResult.drawing) return;

    setState(() {
      _dragPosition = details.localPosition;
      _addPoint(details.localPosition, const Size(300, 300));
    });
  }

  void _end(DragEndDetails details) {
    if (_selected.isEmpty) {
      _reset();
      return;
    }

    final isCorrect = _selected.length == _answer.length;
    final matches = isCorrect &&
        List.generate(_answer.length, (i) => _selected[i] == _answer[i])
            .every((match) => match);

    setState(() {
      _dragPosition = null;
      _result = matches ? _PatternResult.success : _PatternResult.error;
    });

    if (matches) {
      _successController.forward(from: 0);
    } else {
      _shakeController.forward(from: 0).whenComplete(() {
        if (mounted && _result == _PatternResult.error) {
          Future.delayed(const Duration(milliseconds: 350), () {
            if (mounted && _result == _PatternResult.error) _reset();
          });
        }
      });
    }
  }

  void _reset({bool keepState = false}) {
    _shakeController.stop();
    _successController.stop();
    _shakeController.value = 0;
    _successController.value = 0;

    setState(() {
      _selected.clear();
      _dragPosition = null;
      if (!keepState) _result = _PatternResult.idle;
    });
  }

  void _addPoint(Offset position, Size size) {
    final points = _PatternGrid.points(size);
    for (int i = 0; i < points.length; i++) {
      final distance = (position - points[i]).distance;
      if (distance < 34 && !_selected.contains(i)) {
        _selected.add(i);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _statusText();
    final color = _result.color;

    return Scaffold(
      appBar: AppBar(title: const Text('Unlock Pattern Animation')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Nuqtalarni barmoq bilan ulang. To\'g\'ri pattern: yuqori qator, keyin o\'ng pastga.',
              style: TextStyle(fontSize: 17, height: 1.35),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final shake = math.sin(_shakeController.value * math.pi * 8);
                return Transform.translate(
                  offset: Offset(shake * 12 * (1 - _shakeController.value), 0),
                  child: child,
                );
              },
              child: GestureDetector(
                onPanStart: _start,
                onPanUpdate: _update,
                onPanEnd: _end,
                onPanCancel: _reset,
                child: AnimatedBuilder(
                  animation: _successController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(300, 300),
                      painter: _PatternPainter(
                        selected: List<int>.from(_selected),
                        dragPosition: _dragPosition,
                        result: _result,
                        successProgress: _successController.value,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 22),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              child: Text(status),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _reset,
              child: const Text('Reset'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _statusText() {
    switch (_result) {
      case _PatternResult.idle:
        return 'Pattern chizing';
      case _PatternResult.drawing:
        return 'Davom eting...';
      case _PatternResult.success:
        return 'Unlocked';
      case _PatternResult.error:
        return 'Xato pattern';
    }
  }
}

enum _PatternResult { idle, drawing, success, error }

extension _PatternResultColor on _PatternResult {
  Color get color {
    switch (this) {
      case _PatternResult.success:
        return Colors.green;
      case _PatternResult.error:
        return Colors.redAccent;
      case _PatternResult.drawing:
        return Colors.deepPurple;
      case _PatternResult.idle:
        return Colors.blueGrey;
    }
  }
}

class _PatternPainter extends CustomPainter {
  final List<int> selected;
  final Offset? dragPosition;
  final _PatternResult result;
  final double successProgress;

  const _PatternPainter({
    required this.selected,
    required this.dragPosition,
    required this.result,
    required this.successProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final points = _PatternGrid.points(size);
    final activeColor = result.color;
    final inactivePaint = Paint()
      ..color = const Color(0xFFE1E7EF)
      ..style = PaintingStyle.fill;
    final ringPaint = Paint()
      ..color = activeColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = activeColor
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (selected.length > 1) {
      final path = Path()
        ..moveTo(points[selected.first].dx, points[selected.first].dy);
      for (final index in selected.skip(1)) {
        path.lineTo(points[index].dx, points[index].dy);
      }
      canvas.drawPath(path, linePaint);
    }

    if (selected.isNotEmpty &&
        dragPosition != null &&
        result == _PatternResult.drawing) {
      final last = points[selected.last];
      canvas.drawLine(last, dragPosition!, linePaint);
    }

    for (int i = 0; i < points.length; i++) {
      final isSelected = selected.contains(i);
      final point = points[i];
      if (isSelected) {
        final pulse = result == _PatternResult.success
            ? math.sin(successProgress * math.pi).clamp(0.0, 1.0)
            : 0.0;
        canvas.drawCircle(point, 30 + 16 * pulse, ringPaint);
        canvas.drawCircle(point, 14, Paint()..color = activeColor);
        canvas.drawCircle(point, 5, Paint()..color = Colors.white);
      } else {
        canvas.drawCircle(point, 16, inactivePaint);
        canvas.drawCircle(
          point,
          6,
          Paint()..color = const Color(0xFF8FA1B3),
        );
      }
    }

    if (result == _PatternResult.success) {
      final center = Offset(size.width / 2, size.height / 2);
      final checkPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final progress = Curves.easeOutCubic.transform(successProgress);
      final start = center + const Offset(-42, 18);
      final middle = center + const Offset(-12, 48);
      final end = center + const Offset(52, -36);
      final path = Path()..moveTo(start.dx, start.dy);

      if (progress < 0.45) {
        final t = progress / 0.45;
        path.lineTo(
          start.dx + (middle.dx - start.dx) * t,
          start.dy + (middle.dy - start.dy) * t,
        );
      } else {
        final t = (progress - 0.45) / 0.55;
        path
          ..lineTo(middle.dx, middle.dy)
          ..lineTo(
            middle.dx + (end.dx - middle.dx) * t,
            middle.dy + (end.dy - middle.dy) * t,
          );
      }

      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PatternPainter oldDelegate) {
    return oldDelegate.selected != selected ||
        oldDelegate.dragPosition != dragPosition ||
        oldDelegate.result != result ||
        oldDelegate.successProgress != successProgress;
  }
}

class _PatternGrid {
  static List<Offset> points(Size size) {
    final gapX = size.width / 4;
    final gapY = size.height / 4;
    final points = <Offset>[];

    for (int row = 1; row <= 3; row++) {
      for (int col = 1; col <= 3; col++) {
        points.add(Offset(gapX * col, gapY * row));
      }
    }

    return points;
  }
}
