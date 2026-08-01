import 'dart:math';

import 'package:flutter/material.dart';

class TimerAnimation extends StatefulWidget {
  @override
  State<TimerAnimation> createState() => _TimerAnimationState();
}

class _TimerAnimationState extends State<TimerAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  /// 0..60 oralig'ida, necha daqiqa tanlangan
  double _minutes = 17.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, Offset center) {
    final pos = details.localPosition - center;
    double angle = atan2(pos.dx, -pos.dy);
    if (angle < 0) angle += 2 * pi;
    setState(() {
      _minutes = (angle / (2 * pi) * 60).clamp(0, 60);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Timer'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth * 0.85;
            final center = Offset(size / 2, size / 2);
            return GestureDetector(
              onPanUpdate: (details) => _onPanUpdate(details, center),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  final animatedMinutes = _minutes * _animation.value;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: size,
                        height: size,
                        child: CustomPaint(
                          painter: _TimerPainter(
                            minutes: animatedMinutes,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildStartButton(),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: 200,
      height: 56,
      decoration: BoxDecoration(
        color: const Color(0xFFF5E960),
        borderRadius: BorderRadius.circular(28),
      ),
      alignment: Alignment.center,
      child: const Text(
        'Start',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _TimerPainter extends CustomPainter {
  final double minutes;

  _TimerPainter({required this.minutes});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 30;

    _drawBackgroundCircle(canvas, center, radius);
    _drawArc(canvas, center, radius);
    _drawLabels(canvas, center, radius);
    _drawHandle(canvas, center, radius);
    _drawCenterText(canvas, center);
  }

  void _drawBackgroundCircle(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius, paint);
  }

  void _drawArc(Canvas canvas, Offset center, double radius) {
    if (minutes <= 0) return;
    final sweepAngle = (minutes / 60) * 2 * pi;
    final paint = Paint()
      ..color = const Color(0xFFF5D623)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  void _drawHandle(Canvas canvas, Offset center, double radius) {
    if (minutes <= 0) return;
    final angle = (minutes / 60) * 2 * pi - pi / 2;
    final handlePos = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );

    // tashqi oq doira (soya effekti)
    canvas.drawCircle(
      handlePos,
      14,
      Paint()
        ..color = Colors.white
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // asosiy sariq doira
    canvas.drawCircle(
      handlePos,
      12,
      Paint()..color = const Color(0xFFF5D623),
    );
  }

  void _drawLabels(Canvas canvas, Offset center, double radius) {
    for (int i = 0; i < 12; i++) {
      final value = i * 5;
      final angle = (value / 60) * 2 * pi - pi / 2;
      final labelRadius = radius + 24;
      final pos = Offset(
        center.dx + labelRadius * cos(angle),
        center.dy + labelRadius * sin(angle),
      );

      final text = value == 0 ? '00' : '$value';
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - textPainter.width / 2, pos.dy - textPainter.height / 2),
      );
    }
  }

  void _drawCenterText(Canvas canvas, Offset center) {
    final mins = minutes.round();
    final text = '${mins.toString().padLeft(2, '0')}:00';
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 52,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(_TimerPainter oldDelegate) =>
      oldDelegate.minutes != minutes;
}
