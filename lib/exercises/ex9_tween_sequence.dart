import 'dart:developer';

import 'package:flutter/material.dart';

class Ex9TweenSequence extends StatefulWidget {
  @override
  State<Ex9TweenSequence> createState() => _Ex9TweenSequenceState();
}

class _Ex9TweenSequenceState extends State<Ex9TweenSequence>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Scale: kichik → katta → juda kichik → normal
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween:
            Tween(begin: 1.4, end: 0.3).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
    ]).animate(_controller);

    // Rotation: 0 → 0.5 → 0 (yarim aylana borib qaytadi)
    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.5),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 0.0),
        weight: 50,
      ),
    ]).animate(_controller);

    // Rang: indigo → orange → teal → indigo
    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.indigo, end: Colors.deepOrange),
        weight: 33,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.deepOrange, end: Colors.teal),
        weight: 33,
      ),
      TweenSequenceItem(
        tween: ColorTween(begin: Colors.teal, end: Colors.indigo),
        weight: 34,
      ),
    ]).animate(_controller);

    _controller.addListener(() {
      log("JJJJJJ ${_controller.value} ~~ ${_colorAnimation.value?.r}");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _play() {
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mashq 9: TweenSequence')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return RotationTransition(
                  turns: _rotationAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: _colorAnimation.value,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.favorite,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: _play,
              child: const Text('Ijro etish'),
            ),
          ],
        ),
      ),
    );
  }
}
