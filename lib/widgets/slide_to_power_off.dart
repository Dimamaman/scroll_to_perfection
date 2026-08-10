import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

/// iOS'ning klassik "slide to power off" tugmasi.
///
/// Asosiy detal — matn bo'ylab chapdan o'ngga **yorug'lik yuguradi**
/// (shimmer). Bu foydalanuvchiga "bu yerni suring" degan ishora beradi.
class SlideToPowerOff extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onSlideComplete;

  /// Necha foiz surilganda tasdiq hisoblanadi
  final double threshold;

  const SlideToPowerOff({
    Key? key,
    required this.onSlideComplete,
    this.label = 'slide to power off',
    this.icon = Icons.power_settings_new,
    this.iconColor = const Color(0xFFD32F2F),
    this.threshold = 0.92,
  }) : super(key: key);

  @override
  State<SlideToPowerOff> createState() => _SlideToPowerOffState();
}

class _SlideToPowerOffState extends State<SlideToPowerOff>
    with TickerProviderStateMixin {
  static const _height = 72.0;
  static const _padding = 4.0;

  /// Thumb pozitsiyasi: 0.0 = chapda, 1.0 = o'ngda
  late final AnimationController _slide;

  /// Shimmer — to'xtovsiz aylanadi
  late final AnimationController _shimmer;

  bool _done = false;

  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 420,
    damping: 24,
  );

  @override
  void initState() {
    super.initState();

    _slide = AnimationController.unbounded(vsync: this)
      ..addListener(() => setState(() {}));

    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _slide.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  void _onStart(DragStartDetails _) => _slide.stop();

  void _onUpdate(DragUpdateDetails d, double maxDrag) {
    log("MMMMMMMMM ${d.delta.dx}");
    if (_done) return;
    _slide.value = (_slide.value + d.delta.dx / maxDrag).clamp(0.0, 1.0);
  }

  void _onEnd(DragEndDetails d, double maxDrag) {
    if (_done) return;
    final v = d.velocity.pixelsPerSecond.dx / maxDrag;

    if (_slide.value >= widget.threshold) {
      _slide
          .animateWith(SpringSimulation(_spring, _slide.value, 1.0, v))
          .then((_) {
        if (!mounted) return;
        HapticFeedback.mediumImpact();
        setState(() => _done = true);
        _shimmer.stop();
        widget.onSlideComplete();
      });
    } else {
      // Yetmadi — prujinaday orqaga qaytadi
      _slide.animateWith(SpringSimulation(_spring, _slide.value, 0.0, v));
    }
  }

  void reset() {
    setState(() => _done = false);
    _shimmer.repeat();
    _slide.animateWith(SpringSimulation(_spring, _slide.value, 0.0, 0.0));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackW = constraints.maxWidth;
        final thumbSize = _height - _padding * 2;
        final maxDrag = trackW - thumbSize - _padding * 2;

        final t = _slide.value.clamp(0.0, 1.0);
        // log("RRRRR ${_padding + maxDrag * t} ~~~ $t");
        return SizedBox(
          height: _height,
          child: Stack(
            children: [
              // ── Yo'lak
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_height / 2),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFDDD6D0), Color(0xFFB8ADA5)],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.45),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Center(
                  child: Padding(
                    // Matn thumb bilan to'qnashmasligi uchun
                    padding: EdgeInsets.only(left: thumbSize + 8, right: 20),
                    child: Opacity(
                      // Surilgan sari matn so'nadi
                      opacity: (1.0 - t * 1.5).clamp(0.0, 1.0),
                      child: _ShimmerText(
                        text: widget.label,
                        animation: _shimmer,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Thumb
              Positioned(
                left: _padding + maxDrag * t,
                top: _padding,
                child: GestureDetector(
                  onHorizontalDragStart: _onStart,
                  onHorizontalDragUpdate: (d) => _onUpdate(d, maxDrag),
                  onHorizontalDragEnd: (d) => _onEnd(d, maxDrag),
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white, Color(0xFFF0EDE9)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Shimmer matn — yorug'lik chapdan o'ngga yuguradi
// ─────────────────────────────────────────────
class _ShimmerText extends StatelessWidget {
  final String text;
  final Animation<double> animation;

  const _ShimmerText({required this.text, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ShaderMask(
          // srcIn: gradient ranglari matnning o'ziga bo'yaladi
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFF3A3A3A), // oddiy — to'q kulrang
                Color(0xFF3A3A3A),
                Colors.white, // yorug'lik nuqtasi
                Color(0xFF3A3A3A),
                Color(0xFF3A3A3A),
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              // Gradientni chapdan o'ngga surib turamiz
              transform: _SlideGradient(animation.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.2,
          // ShaderMask ishlashi uchun rang oq bo'lishi kerak
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Gradientni gorizontal siljitadi.
/// [t] 0→1 bo'lganda gradient chapdan o'ngga to'liq o'tib ketadi.
class _SlideGradient extends GradientTransform {
  final double t;
  const _SlideGradient(this.t);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    // -1 → +1 oralig'ida: butunlay chapdan butunlay o'ngga
    final dx = bounds.width * (t * 2 - 1);
    return Matrix4.translationValues(dx, 0, 0);
  }
}

// ─────────────────────────────────────────────
// Demo ekran
// ─────────────────────────────────────────────
class SlideToPowerOffDemo extends StatefulWidget {
  @override
  State<SlideToPowerOffDemo> createState() => _SlideToPowerOffDemoState();
}

class _SlideToPowerOffDemoState extends State<SlideToPowerOffDemo> {
  final _key = GlobalKey<_SlideToPowerOffState>();
  bool _off = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              SlideToPowerOff(
                key: _key,
                onSlideComplete: () => setState(() => _off = true),
              ),
              const SizedBox(height: 40),
              if (_off)
                Column(
                  children: [
                    const Text(
                      'O\'chirilmoqda...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() => _off = false);
                        _key.currentState?.reset();
                      },
                      child: const Text('Qaytarish'),
                    ),
                  ],
                ),
              const Spacer(),
              const Text(
                'Cancel',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
