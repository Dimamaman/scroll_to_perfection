import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class Ex18Draggable extends StatefulWidget {
  @override
  State<Ex18Draggable> createState() => _Ex18DraggableState();
}

class _Ex18DraggableState extends State<Ex18Draggable>
    with TickerProviderStateMixin {
  // 2 ta controller: X va Y uchun alohida
  late final AnimationController _xController;
  late final AnimationController _yController;

  // Kartochka hozirgi pozitsiyasi (pikselda)
  double _dx = 0;
  double _dy = 0;

  // Masshtab va aylanish (tortganda o'zgaradi)
  double _scale = 1.0;
  double _angle = 0.0;

  final _spring = const SpringDescription(
    mass: 1,
    stiffness: 300,
    damping: 15,
  );

  @override
  void initState() {
    super.initState();
    _xController = AnimationController.unbounded(vsync: this);
    _yController = AnimationController.unbounded(vsync: this);

    _xController.addListener(_onAnimate);
    _yController.addListener(_onAnimate);
  }

  void _onAnimate() {
    setState(() {
      _dx = _xController.value;
      _dy = _yController.value;
      _updateTransforms();
    });
  }

  void _updateTransforms() {
    // Markazdan uzoqlashgan sari kichiklashadi va aylanadi
    final distance = Offset(_dx, _dy).distance;
    _scale = (1.0 - distance / 1000).clamp(0.7, 1.0);
    _angle = _dx / 800;
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _xController.stop();
    _yController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dx += details.delta.dx;
      _dy += details.delta.dy;
      _updateTransforms();
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final vx = details.velocity.pixelsPerSecond.dx;
    final vy = details.velocity.pixelsPerSecond.dy;

    // X o'qi uchun spring: hozirgi joydan 0 ga qaytish
    _xController.animateWith(SpringSimulation(_spring, _dx, 0, vx));
    // Y o'qi uchun spring: hozirgi joydan 0 ga qaytish
    _yController.animateWith(SpringSimulation(_spring, _dy, 0, vy));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mashq 18: Drag + Snap')),
      body: Stack(
        children: [
          // Markaz nuqtasi (qaytish joyi)
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.center_focus_weak,
                color: Colors.grey.shade300,
                size: 30,
              ),
            ),
          ),
          // Tortish chizig'i (markazdan kartochkagacha)
          if (_dx != 0 || _dy != 0)
            CustomPaint(
              size: Size.infinite,
              painter: _LinePainter(
                dx: _dx,
                dy: _dy,
                center: MediaQuery.of(context).size / 2,
              ),
            ),
          // Kartochka
          Center(
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: Transform.translate(
                offset: Offset(_dx, _dy),
                child: Transform.rotate(
                  angle: _angle,
                  child: Transform.scale(
                    scale: _scale,
                    child: _buildCard(),
                  ),
                ),
              ),
            ),
          ),
          // Masofa ko'rsatkichi
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'X: ${_dx.round()}  Y: ${_dy.round()}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: 160,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.teal, Colors.indigo],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16 + (_dx.abs() + _dy.abs()) / 20,
            offset: Offset(_dx / 20, _dy / 20 + 8),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app, size: 50, color: Colors.white),
          SizedBox(height: 12),
          Text(
            'Torting!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Markazdan kartochkagacha chiziq chizadi
class _LinePainter extends CustomPainter {
  final double dx;
  final double dy;
  final Size center;

  _LinePainter({required this.dx, required this.dy, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    final centerPoint = Offset(center.width, center.height);
    final cardPoint = centerPoint + Offset(dx, dy);

    final paint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Nuqtali chiziq
    const dashLen = 6.0;
    final path = Path();
    final diff = cardPoint - centerPoint;
    final len = diff.distance;
    final dir = diff / len;

    for (double d = 0; d < len; d += dashLen * 2) {
      final start = centerPoint + dir * d;
      final end = centerPoint + dir * (d + dashLen).clamp(0, len);
      path.moveTo(start.dx, start.dy);
      path.lineTo(end.dx, end.dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.dx != dx || old.dy != dy;
}
