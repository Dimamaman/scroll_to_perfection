import 'package:flutter/material.dart';

class Ex12RepeatShimmer extends StatefulWidget {
  const Ex12RepeatShimmer({Key? key}) : super(key: key);

  @override
  State<Ex12RepeatShimmer> createState() => _Ex12RepeatShimmerState();
}

class _Ex12RepeatShimmerState extends State<Ex12RepeatShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _running = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _running = !_running);
    if (_running) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mashq 12: Repeat + Shimmer')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'repeat() cheksiz animatsiya uchun ishlatiladi: loading, shimmer, puls yoki dekorativ harakatlar.',
              style: TextStyle(fontSize: 17, height: 1.35),
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  children: [
                    _PulsingButton(progress: _controller.value),
                    const SizedBox(height: 36),
                    _ShimmerLine(progress: _controller.value, width: 280),
                    const SizedBox(height: 12),
                    _ShimmerLine(progress: _controller.value, width: 220),
                    const SizedBox(height: 12),
                    _ShimmerLine(progress: _controller.value, width: 260),
                  ],
                );
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _toggle,
              child: Text(_running ? 'To\'xtatish' : 'Davom ettirish'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PulsingButton extends StatelessWidget {
  final double progress;

  const _PulsingButton({required this.progress});

  @override
  Widget build(BuildContext context) {
    final pulse = 1.0 + (Curves.easeInOut.transform(progress) * 0.08);

    return Transform.scale(
      scale: pulse,
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withValues(alpha: 0.25),
              blurRadius: 30 * progress,
              spreadRadius: 12 * progress,
            ),
          ],
        ),
        child: const Icon(Icons.favorite, color: Colors.white, size: 42),
      ),
    );
  }
}

class _ShimmerLine extends StatelessWidget {
  final double progress;
  final double width;

  const _ShimmerLine({
    required this.progress,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment(-1.0 + progress * 2.4, 0),
          end: Alignment(-0.2 + progress * 2.4, 0),
          colors: const [
            Color(0xFFE0E0E0),
            Color(0xFFF7F7F7),
            Color(0xFFE0E0E0),
          ],
        ),
      ),
    );
  }
}
