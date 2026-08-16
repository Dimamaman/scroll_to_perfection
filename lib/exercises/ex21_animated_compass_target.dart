import 'dart:math' as math;

import 'package:flutter/material.dart';

class Ex21AnimatedCompassTarget extends StatefulWidget {
  const Ex21AnimatedCompassTarget({Key? key}) : super(key: key);

  @override
  State<Ex21AnimatedCompassTarget> createState() =>
      _Ex21AnimatedCompassTargetState();
}

class _Ex21AnimatedCompassTargetState extends State<Ex21AnimatedCompassTarget>
    with TickerProviderStateMixin {
  late final AnimationController _needleController;
  late final AnimationController _pulseController;
  late Animation<double> _needleAnimation;

  double _currentAngle = 0;
  double _targetAngle = 65;

  bool get _isLocked {
    final diff = (_normalizeAngle(_targetAngle - _currentAngle)).abs();
    return diff < 0.5 || (360 - diff) < 0.5;
  }

  @override
  void initState() {
    super.initState();
    _needleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
    _needleAnimation = AlwaysStoppedAnimation(_currentAngle);
  }

  @override
  void dispose() {
    _needleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _setTarget(double value) {
    final newTarget = value.roundToDouble();
    final shortestDelta = _normalizeAngle(newTarget - _currentAngle);
    final endAngle = _currentAngle + shortestDelta;

    _needleAnimation = Tween<double>(
      begin: _currentAngle,
      end: endAngle,
    ).animate(
      CurvedAnimation(parent: _needleController, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() => _currentAngle = _needleAnimation.value);
      });

    setState(() => _targetAngle = newTarget);
    _needleController.forward(from: 0);
  }

  void _randomTarget() {
    final next = (_targetAngle + 75 + math.Random().nextInt(160)) % 360;
    _setTarget(next);
  }

  double _normalizeAngle(double angle) {
    var value = angle % 360;
    if (value > 180) value -= 360;
    if (value < -180) value += 360;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final shownAngle = ((_currentAngle % 360) + 360) % 360;

    return Scaffold(
      appBar: AppBar(title: const Text('Animated Compass Target')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Target burchagini o\'zgartiring. Kompas ignasi eng qisqa yo\'l bilan smooth buriladi.',
              style: TextStyle(fontSize: 17, height: 1.35),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation:
                  Listenable.merge([_pulseController, _needleController]),
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(300, 300),
                  painter: _CompassPainter(
                    needleAngle: shownAngle,
                    targetAngle: _targetAngle,
                    pulse: _pulseController.value,
                    isLocked: _isLocked,
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: _isLocked ? Colors.green : Colors.blueGrey,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
              child: Text(
                  _isLocked ? 'Target locked' : '${shownAngle.round()} deg'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('0 deg'),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 359,
                    divisions: 359,
                    value: _targetAngle,
                    label: '${_targetAngle.round()} deg',
                    onChanged: _setTarget,
                  ),
                ),
                const Text('359 deg'),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _randomTarget,
              child: const Text('Random target'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double needleAngle;
  final double targetAngle;
  final double pulse;
  final bool isLocked;

  const _CompassPainter({
    required this.needleAngle,
    required this.targetAngle,
    required this.pulse,
    required this.isLocked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final ringPaint = Paint()
      ..color = const Color(0xFFE8EDF3)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFF263238)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius - 6, ringPaint);
    canvas.drawCircle(center, radius - 8, borderPaint);

    _drawTicks(canvas, center, radius);
    _drawTarget(canvas, center, radius);
    _drawNeedle(canvas, center, radius);

    canvas.drawCircle(center, 16, Paint()..color = const Color(0xFF263238));
    canvas.drawCircle(center, 6, Paint()..color = Colors.white);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius) {
    final tickPaint = Paint()
      ..color = const Color(0xFF546E7A)
      ..strokeCap = StrokeCap.round;
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < 360; i += 15) {
      final angle = _toRadians(i as double);
      final isMajor = i % 45 == 0;
      final outer =
          center + Offset(math.sin(angle), -math.cos(angle)) * (radius - 22);
      final inner = center +
          Offset(math.sin(angle), -math.cos(angle)) *
              (radius - (isMajor ? 42 : 32));

      tickPaint
        ..strokeWidth = isMajor ? 3 : 1.5
        ..color = isMajor ? const Color(0xFF263238) : const Color(0xFF90A4AE);
      canvas.drawLine(inner, outer, tickPaint);
    }

    const labels = {
      0: 'N',
      90: 'E',
      180: 'S',
      270: 'W',
    };

    labels.forEach((degree, label) {
      final angle = _toRadians(degree as double);
      final position =
          center + Offset(math.sin(angle), -math.cos(angle)) * (radius - 62);
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFF263238),
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    });
  }

  void _drawTarget(Canvas canvas, Offset center, double radius) {
    final angle = _toRadians(targetAngle);
    final direction = Offset(math.sin(angle), -math.cos(angle));
    final position = center + direction * (radius - 82);
    final pulseSize = 16 + 22 * pulse;
    final color = isLocked ? Colors.green : Colors.orange;

    canvas.drawCircle(
      position,
      pulseSize,
      Paint()..color = color.withValues(alpha: 0.20 * (1 - pulse)),
    );
    canvas.drawCircle(position, 14, Paint()..color = color);
    canvas.drawCircle(position, 6, Paint()..color = Colors.white);
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    final angle = _toRadians(needleAngle);
    final direction = Offset(math.sin(angle), -math.cos(angle));
    final side = Offset(-direction.dy, direction.dx);
    final tip = center + direction * (radius - 78);
    final tail = center - direction * 42;

    final needlePath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo((center + side * 16).dx, (center + side * 16).dy)
      ..lineTo(tail.dx, tail.dy)
      ..lineTo((center - side * 16).dx, (center - side * 16).dy)
      ..close();

    canvas.drawShadow(needlePath, Colors.black, 8, true);
    canvas.drawPath(needlePath, Paint()..color = const Color(0xFFE53935));

    final tailPath = Path()
      ..moveTo(tail.dx, tail.dy)
      ..lineTo((center + side * 10).dx, (center + side * 10).dy)
      ..lineTo((center - side * 10).dx, (center - side * 10).dy)
      ..close();
    canvas.drawPath(tailPath, Paint()..color = const Color(0xFF455A64));
  }

  double _toRadians(double degree) => degree * math.pi / 180;

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) {
    return oldDelegate.needleAngle != needleAngle ||
        oldDelegate.targetAngle != targetAngle ||
        oldDelegate.pulse != pulse ||
        oldDelegate.isLocked != isLocked;
  }
}
