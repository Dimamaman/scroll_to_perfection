import 'package:flutter/material.dart';

class Ex4Rotation extends StatefulWidget {
  @override
  State<Ex4Rotation> createState() => _Ex4RotationState();
}

class _Ex4RotationState extends State<Ex4Rotation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Tween: 0 dan 1 gacha = 360° (to'liq aylana)
    // 0 dan 0.5 ga o'zgartirsang = 180° (yarim aylana)
    // 0 dan 2 ga o'zgartirsang = 720° (ikki marta aylana)
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _rotate() {
    // reset() = 0 ga qaytaradi (animatsiyasiz)
    // forward() = 0 → 1 (aylantiradi)
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mashq 4: Rotation')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _animation,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.refresh,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _rotate,
              child: const Text('Aylantir'),
            ),
          ],
        ),
      ),
    );
  }
}
