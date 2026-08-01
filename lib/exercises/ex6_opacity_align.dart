import 'package:flutter/material.dart';

class Ex6OpacityAlign extends StatefulWidget {
  @override
  State<Ex6OpacityAlign> createState() => _Ex6OpacityAlignState();
}

class _Ex6OpacityAlignState extends State<Ex6OpacityAlign> {
  // 4 ta holat: har biri boshqa joy + shaffoflik
  int _step = 0;

  static const _steps = [
    _StepData(align: Alignment.topLeft, opacity: 1.0, color: Colors.indigo, label: 'Chap yuqori'),
    _StepData(align: Alignment.topRight, opacity: 0.6, color: Colors.teal, label: 'O\'ng yuqori'),
    _StepData(align: Alignment.bottomRight, opacity: 0.3, color: Colors.deepOrange, label: 'O\'ng pastda'),
    _StepData(align: Alignment.bottomLeft, opacity: 1.0, color: Colors.purple, label: 'Chap pastda'),
  ];

  void _next() {
    setState(() {
      // 0 → 1 → 2 → 3 → 0 → 1 → ...
      _step = (_step + 1) % _steps.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = _steps[_step];
    return Scaffold(
      appBar: AppBar(title: const Text('Mashq 6: Opacity + Align')),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Expanded(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                alignment: current.align,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  opacity: current.opacity,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: current.color,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.flutter_dash,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              current.label,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _next,
              child: const Text('Keyingisi'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepData {
  final Alignment align;
  final double opacity;
  final Color color;
  final String label;

  const _StepData({
    required this.align,
    required this.opacity,
    required this.color,
    required this.label,
  });
}
