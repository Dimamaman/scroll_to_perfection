import 'dart:math';

import 'package:flutter/material.dart';

class Ex19Particles extends StatefulWidget {
  @override
  State<Ex19Particles> createState() => _Ex19ParticlesState();
}

class _Ex19ParticlesState extends State<Ex19Particles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = [];
  final _random = Random();

  // Qayerga bosilgan — shu joydan portlaydi
  Offset _emitPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _controller.addListener(_updateParticles);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Har frame'da zarrachalarni yangilash
  void _updateParticles() {
    setState(() {
      for (final p in _particles) {
        // 1. Pozitsiyani yangilash (tezlik bo'yicha siljitish)
        p.position += p.velocity;

        // 2. Gravitatsiya — pastga tortish
        p.velocity = Offset(
          p.velocity.dx * 0.98, // havo qarshiligi (X sekinlashadi)
          p.velocity.dy + 0.15, // gravitatsiya (Y tezlashadi pastga)
        );

        // 3. Shaffoflik kamayadi → zarracha so'nadi
        p.opacity -= p.fadeSpeed;

        // 4. O'lcham kichiklashadi
        p.size *= 0.98;
      }

      // O'lgan zarrachalarni olib tashlash
      _particles.removeWhere((p) => p.opacity <= 0);

      // Hamma zarracha tugasa — animatsiyani to'xtat
      if (_particles.isEmpty) {
        _controller.stop();
      }
    });
  }

  void _emit(Offset position) {
    _emitPosition = position;

    // 50 ta yangi zarracha yaratish
    for (int i = 0; i < 50; i++) {
      // Random yo'nalish (360°)
      final angle = _random.nextDouble() * 2 * pi;
      // Random tezlik (2..8)
      final speed = _random.nextDouble() * 6 + 2;

      _particles.add(_Particle(
        position: position,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed - 3),
        size: _random.nextDouble() * 6 + 2,
        opacity: 1.0,
        fadeSpeed: _random.nextDouble() * 0.02 + 0.01,
        color: _randomColor(),
      ));
    }

    // Animatsiyani ishga tushirish
    _controller.repeat();
  }

  Color _randomColor() {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.pink,
      Colors.amber,
      Colors.deepOrange,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mashq 19: Particles')),
      body: GestureDetector(
        // Ekranning istalgan joyiga bosish = portlash
        onTapDown: (details) => _emit(details.localPosition),
        child: CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            emitPosition: _emitPosition,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

// Bitta zarracha holati
class _Particle {
  Offset position;
  Offset velocity;
  double size;
  double opacity;
  double fadeSpeed;
  Color color;

  _Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.fadeSpeed,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Offset emitPosition;

  _ParticlePainter({required this.particles, required this.emitPosition});

  @override
  void paint(Canvas canvas, Size size) {
    // "Ekranning istalgan joyiga bosing" matni
    if (particles.isEmpty) {
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'Ekranga bosing!',
          style: TextStyle(fontSize: 24, color: Colors.grey),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(
          size.width / 2 - textPainter.width / 2,
          size.height / 2 - textPainter.height / 2,
        ),
      );
      return;
    }

    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity.clamp(0.0, 1.0));

      // Asosiy doira
      canvas.drawCircle(p.position, p.size, paint);

      // Yorug'lik effekti (kichikroq oq doira)
      if (p.opacity > 0.5) {
        final glowPaint = Paint()
          ..color = Colors.white.withValues(alpha: (p.opacity - 0.5).clamp(0.0, 0.5));
        canvas.drawCircle(p.position, p.size * 0.4, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}
