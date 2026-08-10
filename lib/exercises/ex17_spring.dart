import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class Ex17Spring extends StatefulWidget {
  @override
  State<Ex17Spring> createState() => _Ex17SpringState();
}

class _Ex17SpringState extends State<Ex17Spring>
    with SingleTickerProviderStateMixin {
  /// Yagona haqiqat manbai: -1 = chapda, 0 = markazda, 1 = o'ngda.
  /// Alohida `_dragOffset` maydoni endi kerak emas —
  /// pozitsiyani controllerning o'zi saqlaydi.
  late final AnimationController _controller;

  // Spring parametrlari — slider bilan o'zgartiramiz
  double _stiffness = 200;
  double _damping = 12;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    // addListener + setState YO'Q.
    // AnimatedBuilder controllerni o'zi tinglaydi va faqat
    // kartochkaning transform qismini qayta quradi.
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    // Uchayotgan prujinani to'xtatib, barmoqqa nazorat berish
    _controller.stop();
  }

  void _onPanUpdate(DragUpdateDetails details, double maxWidth) {
    // delta.dx = har frame'dagi piksel siljishi
    // maxWidth/2 ga bo'lib nisbiy qiymatga aylantiramiz
    // clamp — kartochka chegaradan uchib ketmasligi uchun
    _controller.value = (_controller.value + details.delta.dx / (maxWidth / 2))
        .clamp(-1.0, 1.0);

    log("TTTTTTT ${details.delta.dx} ~~~ ${_controller.value}");
  }

  void _onPanEnd(DragEndDetails details, double maxWidth) {
    // Tezlikni pikseldan nisbiy qiymatga aylantirish
    final velocity = details.velocity.pixelsPerSecond.dx / (maxWidth / 2);

    final spring = SpringDescription(
      mass: 1,
      stiffness: _stiffness,
      damping: _damping,
    );

    // Spring simulatsiya: hozirgi joydan 0 ga (markazga) qaytish
    _controller.animateWith(SpringSimulation(
      spring,
      _controller.value, // boshlanish: hozirgi joy
      0, // maqsad: markaz
      velocity, // boshlang'ich tezlik: barmoq tezligi
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mashq 17: Spring')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;

          return Column(
            children: [
              const SizedBox(height: 20),
              // Parametrlar paneli
              _buildSlider('Bikrlik (stiffness)', _stiffness, 50, 500, (v) {
                setState(() => _stiffness = v);
              }),
              _buildSlider('Damping', _damping, 2, 30, (v) {
                setState(() => _damping = v);
              }),
              const Spacer(),

              // Kartochka
              GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: (d) => _onPanUpdate(d, maxWidth),
                onPanEnd: (d) => _onPanEnd(d, maxWidth),
                child: AnimatedBuilder(
                  animation: _controller,
                  // child BIR MARTA quriladi va har frameda qayta ishlatiladi
                  child: _buildCard(),
                  builder: (context, child) {
                    final t = _controller.value;

                    // Bitta qiymatdan uchta effekt
                    final translateX = t * (maxWidth / 2 - 40);
                    final rotation = t * 0.1;
                    final scale = 1.0 - (t.abs() * 0.5).clamp(0.0, 0.3);

                    return Transform.translate(
                      offset: Offset(translateX, 0),
                      child: Transform.rotate(
                        angle: rotation,
                        child: Transform.scale(
                          scale: scale,
                          child: child, // qayta ishlatilmoqda
                        ),
                      ),
                    );
                  },
                ),
              ),

              const Spacer(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Kartochkani chapga-o\'ngga torting',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: 200,
      height: 260,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.indigo, Colors.purple],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bolt, size: 60, color: Colors.amber),
          SizedBox(height: 12),
          Text(
            'Spring!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text('$label: ${value.round()}'),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
