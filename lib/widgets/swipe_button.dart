import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

/// Surib tasdiqlash tugmasi (slide to confirm).
///
/// Strelkali dumaloq "thumb" ni o'ngga surasiz. Oxirigacha yetsa
/// [onConfirmed] chaqiriladi. Yetmasa — orqaga qaytib keladi.
class SwipeButton extends StatefulWidget {
  final String label;
  final String confirmedLabel;
  final Color color;
  final VoidCallback onConfirmed;

  /// Qancha foizga surilganda tasdiq hisoblanadi (0..1)
  final double threshold;

  const SwipeButton({
    Key? key,
    required this.label,
    required this.onConfirmed,
    this.confirmedLabel = 'Tayyor!',
    this.color = const Color(0xFF34C759),
    this.threshold = 0.9,
  }) : super(key: key);

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton>
    with SingleTickerProviderStateMixin {
  static const _height = 64.0;
  static const _padding = 6.0;

  late final AnimationController _controller;
  bool _confirmed = false;

  /// Prujina tavsifi: qattiqlik (stiffness) va so'nish (damping).
  /// damping past bo'lsa — ko'proq tebranadi.
  static const _spring = SpringDescription(
    mass: 1,
    stiffness: 500,
    damping: 20,
  );

  /// 0.0 = boshida, 1.0 = oxirida.
  /// unbounded controller bo'lgani uchun bu qiymat 0 dan past yoki
  /// 1 dan yuqori chiqishi mumkin — prujina "otib ketishi" (overshoot) shundan.
  double get _progress => _controller.value;

  @override
  void initState() {
    super.initState();
    // unbounded: 0..1 chegarasidan chiqa oladi → prujina tebranishi ko'rinadi
    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails d) {
    // Uchayotgan prujinani to'xtatib, barmoqqa nazorat berish
    _controller.stop();
  }

  void _onDragUpdate(DragUpdateDetails d, double maxDrag) {
    if (_confirmed) return;
    // Barmoq bilan surganda chegaradan chiqmaydi
    _controller.value =
        (_controller.value + d.delta.dx / maxDrag).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails d, double maxDrag) {
    if (_confirmed) return;

    // Piksel/sekund → progress/sekund
    final velocity = d.velocity.pixelsPerSecond.dx / maxDrag;

    if (_progress >= widget.threshold) {
      // Oxirigacha yetdi — 1.0 ga prujina bilan borib tasdiqlanadi
      _springTo(1.0, velocity).then((_) {
        if (!mounted) return;
        setState(() => _confirmed = true);
        widget.onConfirmed();
      });
    } else {
      // Yetmadi — prujinaday orqaga otiladi
      _springTo(0.0, velocity);
    }
  }

  /// Hozirgi pozitsiyadan [target] ga prujina simulyatsiyasi bilan borish.
  /// [velocity] — qo'yib yuborilgandagi tezlik (progress birligida).
  TickerFuture _springTo(double target, double velocity) {
    return _controller.animateWith(
      SpringSimulation(_spring, _progress, target, velocity),
    );
  }

  /// Tashqaridan boshlang'ich holatga qaytarish
  void reset() {
    setState(() => _confirmed = false);
    _springTo(0.0, 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackW = constraints.maxWidth;
        final thumbSize = _height - _padding * 2;
        final maxDrag = trackW - thumbSize - _padding * 2;

        // Prujina 0..1 dan chiqib ketishi mumkin. Thumb yo'lakdan
        // tashqariga chiqmasligi uchun overshoot'ni padding hajmida cheklaymiz.
        final overshoot = _padding / maxDrag;
        final t = _progress.clamp(-overshoot, 1.0 + overshoot);
        // Fon va matnlar uchun toza 0..1
        final tSafe = _progress.clamp(0.0, 1.0);

        log("FFFFFFFF ${_padding + maxDrag * t}");

        return SizedBox(
          height: _height,
          child: Stack(
            children: [
              // ── Yo'lak (track)
              Container(
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(_height / 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // To'ldiriladigan fon — thumb ortidan ergashadi
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor:
                            (thumbSize + _padding * 2 + maxDrag * tSafe) /
                                trackW,
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.color,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Matn — surilgan sari so'nadi
                    Center(
                      child: Opacity(
                        opacity: (1.0 - tSafe * 1.6).clamp(0.0, 1.0),
                        child: Padding(
                          padding: EdgeInsets.only(left: thumbSize),
                          child: Text(
                            widget.label,
                            style: TextStyle(
                              color: widget.color,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Tasdiqlangan matn — oxirida paydo bo'ladi
                    Center(
                      child: Opacity(
                        opacity: ((tSafe - 0.6) / 0.4).clamp(0.0, 1.0),
                        child: Text(
                          widget.confirmedLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Strelkali thumb
              Positioned(
                left: _padding + maxDrag * t,
                top: _padding,
                child: GestureDetector(
                  onHorizontalDragStart: _onDragStart,
                  onHorizontalDragUpdate: (d) => _onDragUpdate(d, maxDrag),
                  onHorizontalDragEnd: (d) => _onDragEnd(d, maxDrag),
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _confirmed
                          ? Icon(Icons.check,
                              key: const ValueKey('check'),
                              color: widget.color,
                              size: 26)
                          : Icon(Icons.arrow_forward,
                              key: const ValueKey('arrow'),
                              color: widget.color,
                              size: 26),
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
// Demo ekran
// ─────────────────────────────────────────────
class SwipeButtonDemo extends StatefulWidget {
  @override
  State<SwipeButtonDemo> createState() => _SwipeButtonDemoState();
}

class _SwipeButtonDemoState extends State<SwipeButtonDemo> {
  String _status = 'Hali tasdiqlanmagan';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        // backgroundColor: const Color(0xFF1C1C1E),
        // foregroundColor: Colors.white,
        title: const Text('Swipe Button'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            Text(
              _status,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            ),
            const SizedBox(height: 40),
            SwipeButton(
              label: 'Surib tasdiqlang',
              confirmedLabel: 'Tasdiqlandi',
              color: const Color(0xFF34C759),
              onConfirmed: () =>
                  setState(() => _status = 'To\'lov tasdiqlandi'),
            ),
            const SizedBox(height: 20),
            SwipeButton(
              label: 'Buyurtmani yuborish',
              confirmedLabel: 'Yuborildi',
              color: const Color(0xFF007AFF),
              onConfirmed: () => setState(() => _status = 'Buyurtma yuborildi'),
            ),
            const SizedBox(height: 20),
            SwipeButton(
              label: 'O\'chirish uchun suring',
              confirmedLabel: 'O\'chirildi',
              color: const Color(0xFFFF3B30),
              onConfirmed: () =>
                  setState(() => _status = 'Element o\'chirildi'),
            ),
          ],
        ),
      ),
    );
  }
}
