import 'dart:developer';

import 'package:flutter/material.dart';

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

  /// 0.0 = boshida, 1.0 = oxirida
  double get _progress => _controller.value;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d, double maxDrag) {
    if (_confirmed) return;
    // delta ni 0..1 oralig'iga o'girish
    _controller.value += d.delta.dx / maxDrag;
  }

  void _onDragEnd(DragEndDetails d) {
    if (_confirmed) return;

    if (_progress >= widget.threshold) {
      // Oxirigacha yetdi — tasdiqlash
      _controller.animateTo(1.0, curve: Curves.easeOut).then((_) {
        if (!mounted) return;
        setState(() => _confirmed = true);
        widget.onConfirmed();
      });
    } else {
      // Yetmadi — orqaga qaytish
      _controller.animateTo(0.0, curve: Curves.easeOutBack);
    }
  }

  /// Tashqaridan boshlang'ich holatga qaytarish
  void reset() {
    setState(() => _confirmed = false);
    _controller.animateTo(0.0, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackW = constraints.maxWidth;
        final thumbSize = _height - _padding * 2;
        final maxDrag = trackW - thumbSize - _padding * 2;

        log("FFFFFFFF ${_padding + maxDrag * _progress}");

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
                            (thumbSize + _padding * 2 + maxDrag * _progress) /
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
                        opacity: (1.0 - _progress * 1.6).clamp(0.0, 1.0),
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
                        opacity: ((_progress - 0.6) / 0.4).clamp(0.0, 1.0),
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
                left: _padding + maxDrag * _progress,
                top: _padding,
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) => _onDragUpdate(d, maxDrag),
                  onHorizontalDragEnd: _onDragEnd,
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
