import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

/// Bosilishi "his qilinadigan" tugma.
///
/// Muhim detallar:
/// * Barmoq tekkan **zahoti** javob beradi (onTapDown, kutish yo'q)
/// * Bosilganda kichrayadi, qo'yib yuborilganda **prujinaday** qaytadi
/// * Haptic (titrash) — bosilganda darhol
/// * Barmoq tugmadan sirg'alib chiqsa — bekor bo'ladi
class PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color color;

  /// Bosilgandagi o'lcham (1.0 = o'zgarmaydi)
  final double pressedScale;

  /// Prujinaning qattiqligi — katta bo'lsa tezroq qaytadi
  final double stiffness;

  /// So'nish — kichik bo'lsa ko'proq tebranadi
  final double damping;

  const PressableButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.color = const Color(0xFF007AFF),
    this.pressedScale = 0.94,
    this.stiffness = 700,
    this.damping = 22,
  }) : super(key: key);

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton>
    with SingleTickerProviderStateMixin {
  /// 0.0 = bosilmagan, 1.0 = to'liq bosilgan
  late final AnimationController _press;
  bool _isDown = false;

  /// Tugma kamida shuncha vaqt bosilgan holatda turadi.
  /// Busiz: tez "chiq etib" bosilganda barmoq juda tez ko'tariladi va
  /// kichrayish animatsiyasi boshlanib ham ulgurmaydi — tugma o'lik tuyuladi.
  static const _minPressDuration = Duration(milliseconds: 90);

  DateTime? _pressStart;
  Timer? _releaseTimer;

  SpringDescription get _spring => SpringDescription(
        mass: 1,
        stiffness: widget.stiffness,
        damping: widget.damping,
      );

  @override
  void initState() {
    super.initState();
    // unbounded — qaytishda 0 dan pastga "otib" chiqadi, shundan tirik his
    _press = AnimationController.unbounded(vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _releaseTimer?.cancel();
    _press.dispose();
    super.dispose();
  }

  void _down(TapDownDetails _) {
    _releaseTimer?.cancel();
    _pressStart = DateTime.now();
    setState(() => _isDown = true);
    HapticFeedback.lightImpact();
    // Bosilish TEZ bo'lishi kerak — qattiq prujina, tebranishsiz
    _press.animateWith(
      SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 900, damping: 40),
        _press.value,
        1.0,
        0.0,
      ),
    );
  }

  /// Barmoq ko'tarildi. Agar bosilish juda qisqa bo'lgan bo'lsa —
  /// qaytishni minimal vaqt to'lguncha kechiktiramiz.
  void _up() {
    final held = _pressStart == null
        ? Duration.zero
        : DateTime.now().difference(_pressStart!);

    if (held >= _minPressDuration) {
      _release();
    } else {
      _releaseTimer?.cancel();
      _releaseTimer = Timer(_minPressDuration - held, _release);
    }
  }

  void _release() {
    if (!mounted) return;
    setState(() => _isDown = false);
    // Qaytish esa PRUJINA — biroz tebranadi
    _press.animateWith(
      SpringSimulation(_spring, _press.value, 0.0, 0.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    // t: 0..1 (bosilish darajasi). Prujina 0 dan pastga chiqishi mumkin.
    final t = _press.value;

    final scale = 1.0 - (1.0 - widget.pressedScale) * t;
    // Bosilganda soya kichrayadi — tugma "yerga yaqinlashgandek"
    final elevation = 10.0 * (1.0 - t.clamp(0.0, 1.0));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _down,
      onTapUp: (_) {
        _up();
        widget.onPressed();
      },
      onTapCancel: _up,
      child: Transform.scale(
        scale: scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 56,
          decoration: BoxDecoration(
            // Bosilganda biroz to'qroq
            color: _isDown
                ? Color.lerp(widget.color, Colors.black, 0.12)
                : widget.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.35),
                blurRadius: elevation,
                offset: Offset(0, elevation * 0.4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: DefaultTextStyle(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            child: IconTheme(
              data: const IconThemeData(color: Colors.white, size: 20),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Demo ekran
// ─────────────────────────────────────────────
class PressableButtonDemo extends StatefulWidget {
  @override
  State<PressableButtonDemo> createState() => _PressableButtonDemoState();
}

class _PressableButtonDemoState extends State<PressableButtonDemo> {
  int _count = 0;
  double _stiffness = 700;
  double _damping = 22;
  double _scale = 0.94;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pressable Button')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Text(
              'Bosilgan: $_count',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 28),

          PressableButton(
            color: const Color(0xFF007AFF),
            pressedScale: _scale,
            stiffness: _stiffness,
            damping: _damping,
            onPressed: () => setState(() => _count++),
            child: const Text('Bosing'),
          ),
          const SizedBox(height: 16),

          PressableButton(
            color: const Color(0xFF34C759),
            pressedScale: _scale,
            stiffness: _stiffness,
            damping: _damping,
            onPressed: () => setState(() => _count++),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline),
                SizedBox(width: 8),
                Text('Tasdiqlash'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          PressableButton(
            color: const Color(0xFFFF3B30),
            pressedScale: _scale,
            stiffness: _stiffness,
            damping: _damping,
            onPressed: () => setState(() => _count++),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_outline),
                SizedBox(width: 8),
                Text('O\'chirish'),
              ],
            ),
          ),

          const SizedBox(height: 36),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            'Prujina sozlamalari',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          _slider(
            'Kichrayish: ${_scale.toStringAsFixed(2)}',
            _scale,
            0.80,
            1.00,
            (v) => setState(() => _scale = v),
          ),
          _slider(
            'Stiffness (qattiqlik): ${_stiffness.toStringAsFixed(0)}',
            _stiffness,
            100,
            1500,
            (v) => setState(() => _stiffness = v),
          ),
          _slider(
            'Damping (so\'nish): ${_damping.toStringAsFixed(0)}',
            _damping,
            5,
            50,
            (v) => setState(() => _damping = v),
          ),
          const SizedBox(height: 8),
          Text(
            'Damping ni 10 ga tushiring — tugma qaytganda tebranadi.\n'
            'Stiffness ni oshiring — tezroq qaytadi.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _slider(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }
}
