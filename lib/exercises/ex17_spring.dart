import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class Ex17Spring extends StatefulWidget {
  @override
  State<Ex17Spring> createState() => _Ex17SpringState();
}

class _Ex17SpringState extends State<Ex17Spring>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Kartochka hozirgi pozitsiyasi (0 = markazda, -1 = chapda, 1 = o'ngda)
  double _dragOffset = 0;
  double _startOffset = 0;

  // Spring parametrlari — slider bilan o'zgartiramiz
  double _stiffness = 200;
  double _damping = 12;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    _controller.addListener(() {
      setState(() {
        _dragOffset = _controller.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    // Tortishni boshlaganda animatsiyani to'xtat
    _controller.stop();
    _startOffset = _dragOffset;
  }

  void _onPanUpdate(DragUpdateDetails details, double maxWidth) {
    setState(() {
      // delta.dx = har frame'dagi piksel siljishi
      // maxWidth/2 ga bo'lib nisbiy qiymatga aylantiramiz
      _dragOffset += details.delta.dx / (maxWidth / 2);
    });
  }

  void _onPanEnd(DragEndDetails details, double maxWidth) {
    // Tezlikni pikseldan nisbiy qiymatga aylantirish
    final velocity = details.velocity.pixelsPerSecond.dx / maxWidth * 2;

    // Spring simulatsiya: hozirgi joydan 0 ga (markazga) qaytish
    final spring = SpringDescription(
      mass: 1,
      stiffness: _stiffness,
      damping: _damping,
    );

    final simulation = SpringSimulation(
      spring,
      _dragOffset, // boshlanish: hozirgi joy
      0,           // maqsad: markaz
      velocity,    // boshlang'ich tezlik: barmoq tezligi
    );

    _controller.animateWith(simulation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mashq 17: Spring')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          // _dragOffset: -1..1 → pikselga aylantirish
          final translateX = _dragOffset * (maxWidth / 2 - 40);
          // Markazdan uzoqlashganda biroz kichiklashadi
          final scale = 1.0 - (_dragOffset.abs() * 0.2).clamp(0.0, 0.3);
          // Markazdan uzoqlashganda biroz aylanadi
          final rotation = _dragOffset * 0.1;

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
                child: Transform.translate(
                  offset: Offset(translateX, 0),
                  child: Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(
                      scale: scale,
                      child: _buildCard(),
                    ),
                  ),
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
