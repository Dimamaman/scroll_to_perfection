import 'dart:math';

import 'package:flutter/material.dart';

class Ex15Wave extends StatefulWidget {
  @override
  State<Ex15Wave> createState() => _Ex15WaveState();
}

class _Ex15WaveState extends State<Ex15Wave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(); // cheksiz aylana beradi
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mashq 15: Wave')),
      body: Column(
        children: [
          const SizedBox(height: 60),
          // 1. Doiralar to'lqini
          _WaveDots(controller: _controller),
          const SizedBox(height: 80),
          // 2. Chiziqli to'lqin (CustomPainter)
          _WavePainter(controller: _controller),
          const SizedBox(height: 80),
          // 3. Loading indikator (3 ta doira)
          _LoadingWave(controller: _controller),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 1. Doiralar to'lqini — 10 ta doira yuqoriga-pastga
// ─────────────────────────────────────────────
class _WaveDots extends StatelessWidget {
  final AnimationController controller;
  static const _dotCount = 10;

  const _WaveDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    print("RRRRRRRR 15");
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_dotCount, (i) {
            // Har bir doiraga vaqt siljishi (phase) beramiz
            // i * 0.5 = har doira 0.5 radian kechikib boshlanadi
            final phase = i * 0.5;

            // sin() = -1..1, biz -30..30 ga aylantiramir (30px tepaga-pastga)
            final y = sin(2 * pi * controller.value + phase) * 30;

            // Rang ham to'lqinsimon o'zgaradi
            final t = (sin(2 * pi * controller.value + phase) + 1) / 2;
            final color = Color.lerp(Colors.indigo, Colors.teal, t)!;

            print("RRRRRRRR $y ~~~ $t");

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, y),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// 2. CustomPainter bilan sin() to'lqin chizig'i
// ─────────────────────────────────────────────
class _WavePainter extends StatelessWidget {
  final AnimationController controller;

  const _WavePainter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(double.infinity, 100),
          painter: _SinePainter(progress: controller.value),
        );
      },
    );
  }
}

class _SinePainter extends CustomPainter {
  final double progress;

  _SinePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final centerY = size.height / 2;

    for (double x = 0; x <= size.width; x += 1) {
      // sin() ga ikkita narsa beramiz:
      // 1. x / 40 — to'lqin uzunligi (40 px da bir to'liq to'lqin)
      // 2. progress * 2 * pi — vaqt o'tishi (animatsiya)
      final y = centerY + sin(x / 40 + progress * 2 * pi) * 30;

      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Gradient effekt: chapdan o'ngga rang o'zgaradi
    paint.shader = const LinearGradient(
      colors: [Colors.indigo, Colors.teal, Colors.deepOrange],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SinePainter old) => old.progress != progress;
}

// ─────────────────────────────────────────────
// 3. Loading indikator — 3 ta doira navbatma-navbat sakraydi
// ─────────────────────────────────────────────
class _LoadingWave extends StatelessWidget {
  final AnimationController controller;

  const _LoadingWave({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Yuklanmoqda...',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                // Har bir doira uchun: sin() ning faqat yuqori qismi (0..1)
                final phase = i * 0.8;
                final raw = sin(2 * pi * controller.value + phase);
                // faqat tepaga sakrash: manfiy qiymatni 0 qilamiz
                final bounce = raw > 0 ? raw : 0.0;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Transform.translate(
                    offset: Offset(0, -bounce * 20),
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Colors.indigo,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}
