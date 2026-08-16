import 'dart:math' as math;

import 'package:flutter/material.dart';

class Ex13TicketTear extends StatefulWidget {
  const Ex13TicketTear({Key? key}) : super(key: key);

  @override
  State<Ex13TicketTear> createState() => _Ex13TicketTearState();
}

class _Ex13TicketTearState extends State<Ex13TicketTear>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _tear;

  bool get _isTorn => _controller.isCompleted;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _tear = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isTorn) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mashq 13: Ticket Tear')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Chipta ikki bo\'lakka ajraladi. Bu mashqda bitta controllerdan slide, rotate va shadow effektlarini birga boshqaramiz.',
              style: TextStyle(fontSize: 17, height: 1.35),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _tear,
              builder: (context, child) {
                final t = _tear.value;
                const halfWidth = 166.0;
                const tearDepth = 8.0;
                const joinedOffset = halfWidth / 2 - tearDepth;
                return SizedBox(
                  width: 330,
                  height: 190,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(-joinedOffset - 44 * t, -6 * t),
                        child: Transform.rotate(
                          angle: -0.08 * t,
                          alignment: Alignment.centerRight,
                          child: _TicketHalf(
                            side: _TicketSide.left,
                            progress: t,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(joinedOffset + 44 * t, 8 * t),
                        child: Transform.rotate(
                          angle: 0.09 * t,
                          alignment: Alignment.centerLeft,
                          child: _TicketHalf(
                            side: _TicketSide.right,
                            progress: t,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _toggle,
              child: Text(_isTorn ? 'Qayta yopishtirish' : 'Yirtish'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

enum _TicketSide { left, right }

class _TicketHalf extends StatelessWidget {
  final _TicketSide side;
  final double progress;

  const _TicketHalf({
    required this.side,
    required this.progress,
  });

  bool get _isLeft => side == _TicketSide.left;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _TicketTearClipper(side),
      child: Container(
        width: 166,
        height: 170,
        decoration: BoxDecoration(
          color: _isLeft ? const Color(0xFFFFC857) : const Color(0xFFFFD875),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16 + progress * 0.14),
              blurRadius: 18 + progress * 12,
              offset: Offset(0, 10 + progress * 8),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            _isLeft ? 22 : 18,
            22,
            _isLeft ? 16 : 22,
            22,
          ),
          child: _isLeft
              ? const _TicketLeftContent()
              : const _TicketRightContent(),
        ),
      ),
    );
  }
}

class _TicketTearClipper extends CustomClipper<Path> {
  final _TicketSide side;

  const _TicketTearClipper(this.side);

  bool get _isLeft => side == _TicketSide.left;

  @override
  Path getClip(Size size) {
    final path = Path();
    const tooth = 13.0;
    const depth = 8.0;

    if (_isLeft) {
      path.moveTo(0, 18);
      path.quadraticBezierTo(0, 0, 18, 0);
      path.lineTo(size.width, 0);

      for (double y = 0; y <= size.height; y += tooth) {
        final nextY = math.min(y + tooth / 2, size.height);
        final endY = math.min(y + tooth, size.height);
        path.lineTo(size.width - depth, nextY);
        path.lineTo(size.width, endY);
      }

      path.lineTo(18, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - 18);
      path.close();
      return path;
    }

    path.moveTo(0, 0);
    path.lineTo(size.width - 18, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 18);
    path.lineTo(size.width, size.height - 18);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - 18,
      size.height,
    );
    path.lineTo(0, size.height);

    for (double y = size.height; y >= 0; y -= tooth) {
      final nextY = math.max(y - tooth / 2, 0.0);
      final endY = math.max(y - tooth, 0.0);
      path.lineTo(depth, nextY);
      path.lineTo(0, endY);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _TicketTearClipper oldClipper) {
    return oldClipper.side != side;
  }
}

class _TicketLeftContent extends StatelessWidget {
  const _TicketLeftContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'CINEMA',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 18),
        Text(
          'Flutter\nNight',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            height: 1.0,
          ),
        ),
        Spacer(),
        Text(
          'ROW 4',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _TicketRightContent extends StatelessWidget {
  const _TicketRightContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            border: Border.all(width: 3, color: Colors.black87),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.qr_code_2, size: 42),
        ),
        const Spacer(),
        const Text(
          'SEAT',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const Text(
          'A12',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}
