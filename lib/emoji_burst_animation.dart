import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// 2GIS "Friends" xaritasidagi kabi: emoji tugmasi bosilganda, do'stning
/// belgisi ("SS" marker) atrofida, turli tomonlarda (yuqori, past, chap,
/// o'ng) katta holda emoji paydo bo'ladi va markerga yaqinlashgan sari
/// asta-sekin kichrayib, unga "so'rilib" g'oyib bo'ladi. Har bir emoji
/// o'z yo'liga ega: to'lqinsimon, zigzag, yon tomonga fanlanib egilib
/// boruvchi, aylanib-yaltirab boruvchi, sakrab-pulslovchi yoki uzoqdan
/// egri yo'l bilan qaytib keluvchi (fire) yo'l.
class EmojiBurstAnimation extends StatefulWidget {
  @override
  State<EmojiBurstAnimation> createState() => _EmojiBurstAnimationState();
}

enum _BurstStyle {
  floatUpDrift,
  zigzagRise,
  spiralFan,
  spinPulse,
  heartBounce,
  fireRingExplode,
}

const _emojiStyles = <String, _BurstStyle>{
  '🤗': _BurstStyle.floatUpDrift,
  '🥒': _BurstStyle.zigzagRise,
  '🧅': _BurstStyle.spiralFan,
  '🪩': _BurstStyle.spinPulse,
  '❤️': _BurstStyle.heartBounce,
  '🔥': _BurstStyle.fireRingExplode,
  '🦁': _BurstStyle.zigzagRise,
  '👋': _BurstStyle.heartBounce,
  '🎉': _BurstStyle.fireRingExplode,
  '🫂': _BurstStyle.floatUpDrift,
};

/// Faqat shu emoji(lar) markerdan turli tomonlarda, katta holda paydo
/// bo'lib, unga yaqinlashgan sari kichrayadi. Qolganlari tugmadan chiqadi.
const _scatterFromMarkerEmojis = <String>{'🪩'};

class _EmojiBurstAnimationState extends State<EmojiBurstAnimation>
    with TickerProviderStateMixin {
  final List<_Particle> _particles = [];
  final _random = Random();
  final _stackKey = GlobalKey();
  final _markerKey = GlobalKey();
  Timer? _holdTimer;
  Offset? _markerCenter;

  void _onMarkerPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    setState(() {
      final next = _markerCenter! + details.delta;
      _markerCenter = Offset(
        next.dx.clamp(28, constraints.maxWidth - 28),
        next.dy.clamp(28, constraints.maxHeight - 28),
      );
    });
  }

  void _startHold(String emoji, Offset globalOrigin) {
    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(const Duration(milliseconds: 260), (_) {
      _spawnBurst(emoji, globalOrigin);
    });
  }

  void _stopHold() {
    _holdTimer?.cancel();
    _holdTimer = null;
  }

  void _spawnBurst(String emoji, Offset globalOrigin) {
    final stackBox = _stackKey.currentContext!.findRenderObject() as RenderBox;
    final markerBox = _markerKey.currentContext!.findRenderObject() as RenderBox;

    final markerGlobalCenter =
        markerBox.localToGlobal(markerBox.size.center(Offset.zero));
    final destination = stackBox.globalToLocal(markerGlobalCenter);

    final isScatter = _scatterFromMarkerEmojis.contains(emoji);
    Offset origin;
    if (isScatter) {
      // Markerdan turli tomonlarda, tasodifiy burchak va masofada paydo bo'ladi.
      final angle = _random.nextDouble() * 2 * pi;
      final distance = 170 + _random.nextDouble() * 260;
      origin = destination + Offset(cos(angle), sin(angle)) * distance;
    } else {
      // Tugma bosilgan nuqtadan chiqadi.
      origin = stackBox.globalToLocal(globalOrigin);
    }

    final style = _emojiStyles[emoji] ?? _BurstStyle.floatUpDrift;

    late final _Particle particle;
    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1100 + _random.nextInt(500)),
    );
    particle = _Particle(
      emoji: emoji,
      style: style,
      isScatter: isScatter,
      origin: origin,
      destination: destination,
      controller: controller,
      driftAmplitude: 14 + _random.nextDouble() * 30,
      driftFrequency: 1 + _random.nextDouble() * 1.4,
      phase: _random.nextDouble() * 2 * pi,
      rotationAmplitude: (_random.nextDouble() - 0.5) * 0.8,
      baseScale: isScatter
          ? 1.7 + _random.nextDouble() * 0.9
          : 1.3 + _random.nextDouble() * 0.5,
      angle: _random.nextDouble() * 2 * pi,
      explodeDistance: 40 + _random.nextDouble() * 70,
      sideSign: _random.nextBool() ? 1.0 : -1.0,
      spinTurns: 1.5 + _random.nextDouble() * 2,
    );
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _particles.remove(particle));
        controller.dispose();
      }
    });
    setState(() => _particles.add(particle));
    controller.forward();
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    for (final p in _particles) {
      p.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emoji Burst (2GIS uslubida)')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          _markerCenter ??= Offset(
            constraints.maxWidth / 2,
            constraints.maxHeight * 0.4,
          );
          return Stack(
            key: _stackKey,
            children: [
              Container(color: const Color(0xFFEFEAE0)),
              ..._particles.map(
                (p) => Positioned.fill(child: _ParticleWidget(particle: p)),
              ),
              Positioned(
                left: _markerCenter!.dx - 28,
                top: _markerCenter!.dy - 28,
                child: GestureDetector(
                  onPanUpdate: (details) => _onMarkerPanUpdate(details, constraints),
                  child: _MarkerBubble(key: _markerKey),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildEmojiRow(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmojiRow() {
    final emojis = _emojiStyles.keys.toList();
    final mid = (emojis.length / 2).ceil();
    final firstRow = emojis.sublist(0, mid);
    final secondRow = emojis.sublist(mid);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEmojiRowLine(firstRow),
            const SizedBox(height: 8),
            _buildEmojiRowLine(secondRow),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiRowLine(List<String> emojis) {
    return Row(
      children: emojis
          .map(
            (emoji) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _EmojiButton(
                  emoji: emoji,
                  onTapDown: (pos) => _spawnBurst(emoji, pos),
                  onLongPressStart: (pos) => _startHold(emoji, pos),
                  onLongPressEnd: _stopHold,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Particle {
  final String emoji;
  final _BurstStyle style;
  final bool isScatter;
  final Offset origin;
  final Offset destination;
  final AnimationController controller;
  final double driftAmplitude;
  final double driftFrequency;
  final double phase;
  final double rotationAmplitude;
  final double baseScale;
  final double angle;
  final double explodeDistance;
  final double sideSign;
  final double spinTurns;

  _Particle({
    required this.emoji,
    required this.style,
    required this.isScatter,
    required this.origin,
    required this.destination,
    required this.controller,
    required this.driftAmplitude,
    required this.driftFrequency,
    required this.phase,
    required this.rotationAmplitude,
    required this.baseScale,
    required this.angle,
    required this.explodeDistance,
    required this.sideSign,
    required this.spinTurns,
  });
}

/// Juda tez paydo bo'lish (0 -> 1), animatsiya boshida.
double _appear(double t) => (t / 0.05).clamp(0.0, 1.0);

/// Butun yo'l davomida asta-sekin, oxiriga borgan sari tezroq kichrayadi —
/// markerga "so'rilib" ketayotgandek tuyuladi. Faqat scatter emoji uchun.
double _shrinkEnvelope(double t) => 1.0 - Curves.easeIn.transform(t) * 0.94;

/// Kichikdan kattaga "pop" bilan chiqadi (tugmadan chiquvchi emojilar uchun).
double _popIn(double t) {
  final popT = (t / 0.15).clamp(0.0, 1.0);
  return Curves.easeOutBack.transform(popT);
}

/// t=1ga yaqinlashganda marker ichiga "so'rilib" kichraytiradi.
double _absorb(double t) {
  if (t < 0.85) return 1.0;
  return (1 - (t - 0.85) / 0.15).clamp(0.0, 1.0);
}

double _fadeOpacity(double t, {double fadeOutStart = 0.85}) {
  if (t < 0.06) return t / 0.06;
  if (t > fadeOutStart) {
    return (1 - (t - fadeOutStart) / (1 - fadeOutStart)).clamp(0.0, 1.0);
  }
  return 1.0;
}

double _triangleWave(double x) {
  final frac = x - x.floorToDouble();
  return frac < 0.5 ? (frac * 4 - 1) : (3 - frac * 4);
}

/// Ikkinchi darajali Bezier egri chizig'i: A -> control -> B.
Offset _quadraticBezier(Offset a, Offset control, Offset b, double t) {
  final u = 1 - t;
  return a * (u * u) + control * (2 * u * t) + b * (t * t);
}

class _ParticleWidget extends StatelessWidget {
  final _Particle particle;

  const _ParticleWidget({required this.particle});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: particle.controller,
      builder: (context, _) {
        final t = particle.controller.value;
        final p = particle;

        final travel = p.destination - p.origin;
        final travelDistance = travel.distance;
        final dir = travelDistance > 0 ? travel / travelDistance : const Offset(1, 0);
        final perp = Offset(-dir.dy, dir.dx);

        Offset pos = p.origin;
        double pulse = 1.0;
        double rotation = 0;

        switch (p.style) {
          case _BurstStyle.floatUpDrift:
            final pathT = Curves.easeIn.transform(t);
            final wobble =
                sin(t * p.driftFrequency * 2 * pi + p.phase) * p.driftAmplitude * (1 - t);
            pos = p.origin + travel * pathT + perp * wobble;
            rotation = sin(t * pi * 2 + p.phase) * p.rotationAmplitude;
            break;

          case _BurstStyle.zigzagRise:
            final pathT = Curves.easeIn.transform(t);
            final wave = _triangleWave(t * p.driftFrequency + p.phase);
            final wobble = wave * p.driftAmplitude * 1.4 * (1 - t);
            pos = p.origin + travel * pathT + perp * wobble;
            rotation = wave * p.rotationAmplitude * 1.5;
            break;

          case _BurstStyle.spiralFan:
            final control = p.origin +
                travel * 0.5 +
                perp * p.explodeDistance * p.sideSign;
            pos = _quadraticBezier(p.origin, control, p.destination, t);
            rotation = t * p.rotationAmplitude * 3 * p.sideSign;
            break;

          case _BurstStyle.spinPulse:
            final pathT = Curves.easeIn.transform(t);
            final wobble = sin(t * p.spinTurns * 2 * pi) * p.driftAmplitude * 0.5 * (1 - t);
            pos = p.origin + travel * pathT + perp * wobble;
            pulse = 1 + 0.12 * sin(t * pi * 8);
            rotation = t * p.spinTurns * 2 * pi;
            break;

          case _BurstStyle.heartBounce:
            final pathT = Curves.easeIn.transform(t);
            final wobble = sin(t * pi * 6 + p.phase) * p.driftAmplitude * 0.35 * (1 - t);
            pos = p.origin + travel * pathT + perp * wobble;
            pulse = 1 + 0.18 * sin(t * pi * 6) * (1 - t);
            rotation = sin(t * pi * 4 + p.phase) * 0.15 * (1 - t);
            break;

          case _BurstStyle.fireRingExplode:
            final control = p.origin +
                Offset(cos(p.angle), sin(p.angle)) * p.explodeDistance;
            pos = _quadraticBezier(p.origin, control, p.destination, t);
            rotation = t * p.rotationAmplitude * 2;
            break;
        }

        final opacity = _fadeOpacity(t);
        final finalScale = p.isScatter
            ? p.baseScale * _appear(t) * _shrinkEnvelope(t) * pulse
            : p.baseScale * _popIn(t) * pulse * _absorb(t);

        const emojiSize = 46.0;
        return Align(
          alignment: Alignment.topLeft,
          child: Transform.translate(
            offset: Offset(pos.dx - emojiSize / 2, pos.dy - emojiSize / 2),
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: finalScale.clamp(0.0, double.infinity),
                  child: Text(
                    p.emoji,
                    style: const TextStyle(
                      fontSize: emojiSize,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmojiButton extends StatelessWidget {
  final String emoji;
  final ValueChanged<Offset> onTapDown;
  final ValueChanged<Offset> onLongPressStart;
  final VoidCallback onLongPressEnd;

  const _EmojiButton({
    required this.emoji,
    required this.onTapDown,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => onTapDown(details.globalPosition),
      onLongPressStart: (details) => onLongPressStart(details.globalPosition),
      onLongPressEnd: (_) => onLongPressEnd(),
      onLongPressCancel: onLongPressEnd,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: FittedBox(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }
}

class _MarkerBubble extends StatelessWidget {
  const _MarkerBubble({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
      alignment: Alignment.center,
      child: const Text(
        'SS',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
