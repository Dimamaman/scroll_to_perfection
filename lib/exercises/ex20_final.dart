import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class Ex20Final extends StatefulWidget {
  @override
  State<Ex20Final> createState() => _Ex20FinalState();
}

class _Ex20FinalState extends State<Ex20Final>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerController;
  bool _loaded = false;

  static const _cards = [
    _CardData(
      icon: Icons.landscape,
      title: 'Tog\'lar',
      subtitle: 'Tabiat go\'zalligi',
      gradient: [Color(0xFF2196F3), Color(0xFF0D47A1)],
    ),
    _CardData(
      icon: Icons.music_note,
      title: 'Musiqa',
      subtitle: 'Ruhingizni ko\'taring',
      gradient: [Color(0xFFE91E63), Color(0xFF880E4F)],
    ),
    _CardData(
      icon: Icons.code,
      title: 'Dasturlash',
      subtitle: 'Flutter animatsiyalar',
      gradient: [Color(0xFF00BCD4), Color(0xFF006064)],
    ),
    _CardData(
      icon: Icons.restaurant,
      title: 'Taom',
      subtitle: 'Mazali retseptlar',
      gradient: [Color(0xFFFF9800), Color(0xFFE65100)],
    ),
    _CardData(
      icon: Icons.flight,
      title: 'Sayohat',
      subtitle: 'Dunyoni kashf eting',
      gradient: [Color(0xFF9C27B0), Color(0xFF4A148C)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Sahifa ochilganda biroz kutib stagger boshlanadi
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _loaded = true);
        _staggerController.forward();
      }
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _replay() {
    setState(() => _loaded = false);
    _staggerController.reset();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _loaded = true);
        _staggerController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mashq 20: Final'),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay),
            onPressed: _replay,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          return _StaggeredCard(
            data: _cards[index],
            staggerController: _staggerController,
            index: index,
            total: _cards.length,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Staggered + Spring draggable kartochka
// ─────────────────────────────────────────────
class _StaggeredCard extends StatefulWidget {
  final _CardData data;
  final AnimationController staggerController;
  final int index;
  final int total;

  const _StaggeredCard({
    required this.data,
    required this.staggerController,
    required this.index,
    required this.total,
  });

  @override
  State<_StaggeredCard> createState() => _StaggeredCardState();
}

class _StaggeredCardState extends State<_StaggeredCard>
    with TickerProviderStateMixin {
  // Spring drag uchun
  late final AnimationController _xController;
  late final AnimationController _yController;
  double _dx = 0;
  double _dy = 0;

  // Like animatsiya uchun
  late final AnimationController _likeController;
  late final Animation<double> _likeAnimation;
  bool _isLiked = false;

  // Particle system
  final List<_Particle> _particles = [];
  late final AnimationController _particleController;
  final _random = Random();

  final _spring = const SpringDescription(mass: 1, stiffness: 400, damping: 18);

  @override
  void initState() {
    super.initState();

    _xController = AnimationController.unbounded(vsync: this);
    _yController = AnimationController.unbounded(vsync: this);
    _xController.addListener(_onDragAnimate);
    _yController.addListener(_onDragAnimate);

    // Like: TweenSequence — kichik→katta→normal (Mashq 9)
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _likeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.5)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.5, end: 0.8)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.8, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
    ]).animate(_likeController);

    // Particle controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _particleController.addListener(_updateParticles);
  }

  void _onDragAnimate() {
    setState(() {
      _dx = _xController.value;
      _dy = _yController.value;
    });
  }

  void _updateParticles() {
    setState(() {
      for (final p in _particles) {
        p.position += p.velocity;
        p.velocity = Offset(p.velocity.dx * 0.97, p.velocity.dy + 0.12);
        p.opacity -= 0.018;
        p.size *= 0.97;
      }
      _particles.removeWhere((p) => p.opacity <= 0);
      if (_particles.isEmpty) _particleController.stop();
    });
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    _likeController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _xController.stop();
    _yController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dx += details.delta.dx;
      _dy += details.delta.dy;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final vx = details.velocity.pixelsPerSecond.dx;
    final vy = details.velocity.pixelsPerSecond.dy;
    _xController.animateWith(SpringSimulation(_spring, _dx, 0, vx));
    _yController.animateWith(SpringSimulation(_spring, _dy, 0, vy));
  }

  void _toggleLike(Offset tapPosition) {
    setState(() => _isLiked = !_isLiked);
    if (_isLiked) {
      _likeController.reset();
      _likeController.forward();
      _emitParticles(tapPosition);
    }
  }

  void _emitParticles(Offset position) {
    for (int i = 0; i < 20; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = _random.nextDouble() * 4 + 1.5;
      _particles.add(_Particle(
        position: position,
        velocity: Offset(cos(angle) * speed, sin(angle) * speed - 2.5),
        size: _random.nextDouble() * 4 + 2,
        opacity: 1.0,
        color: [Colors.red, Colors.pink, Colors.orange, Colors.yellow]
            [_random.nextInt(4)],
      ));
    }
    _particleController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    // Stagger: Mashq 8 — har kartochka ketma-ket paydo bo'ladi
    final start = widget.index * 0.12;
    final end = (start + 0.35).clamp(0.0, 1.0);
    final staggerAnimation = CurvedAnimation(
      parent: widget.staggerController,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );

    final angle = _dx * 0.001;
    final scale = (1.0 - Offset(_dx, _dy).distance / 1500).clamp(0.85, 1.0);

    return AnimatedBuilder(
      animation: staggerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 60 * (1 - staggerAnimation.value)),
          child: Opacity(
            opacity: staggerAnimation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Transform.translate(
          offset: Offset(_dx, _dy),
          child: Transform.rotate(
            angle: angle,
            child: Transform.scale(
              scale: scale,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _buildCardBody(),
                  // Particle effekt
                  if (_particles.isNotEmpty)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ConfettiPainter(particles: _particles),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardBody() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.data.gradient,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.data.gradient[0].withValues(alpha: 0.4),
            blurRadius: 12 + (_dx.abs() + _dy.abs()) / 30,
            offset: Offset(_dx / 25, _dy / 25 + 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(widget.data.icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.data.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Like tugmasi — TweenSequence animatsiya
          GestureDetector(
            onTapDown: (details) => _toggleLike(details.localPosition),
            child: AnimatedBuilder(
              animation: _likeController,
              builder: (context, child) {
                final s = _likeController.isAnimating
                    ? _likeAnimation.value
                    : 1.0;
                return Transform.scale(
                  scale: s,
                  child: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red.shade200 : Colors.white70,
                    size: 28,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Ma'lumotlar
// ─────────────────────────────────────────────
class _CardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _CardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}

class _Particle {
  Offset position;
  Offset velocity;
  double size;
  double opacity;
  Color color;

  _Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.opacity,
    required this.color,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;

  _ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      canvas.drawCircle(
        p.position,
        p.size,
        Paint()..color = p.color.withValues(alpha: p.opacity.clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => true;
}
