import 'package:flutter/material.dart';

/// Mashq 18b — Mashq 18 ning aynan o'zi, lekin **SpringSimulation'siz**.
///
/// Prujina hissi `Curves.elasticOut` bilan taqlid qilinadi.
/// Natijada:
///   * 2 ta controller o'rniga — 1 ta yetadi
///   * `physics.dart` import qilinmaydi
///   * Kartochka to'g'ri chiziq bo'ylab qaytadi (prujinada egri edi)
class Ex18bCurves extends StatefulWidget {
  @override
  State<Ex18bCurves> createState() => _Ex18bCurvesState();
}

class _Ex18bCurvesState extends State<Ex18bCurves>
    with SingleTickerProviderStateMixin {
  // Bitta controller — chunki ikkala o'q bitta `t` bo'yicha qaytadi
  late final AnimationController _controller;

  // Qaytish animatsiyasi. onPanEnd da qaytadan yaratiladi.
  Animation<Offset>? _return;

  Offset _offset = Offset.zero;

  // Sinab ko'rish uchun egri chiziq tanlash
  static const _curves = <String, Curve>{
    'elasticOut': Curves.elasticOut,
    'easeOutBack': Curves.easeOutBack,
    'bounceOut': Curves.bounceOut,
    'easeOut': Curves.easeOut,
  };
  String _curveName = 'elasticOut';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() {
        // Animatsiya ishlayotgan paytdagina pozitsiyani boshqaradi
        if (_return != null) setState(() => _offset = _return!.value);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _controller.stop();
    _return = null; // barmoq boshqaruvni oladi
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() => _offset += details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    // Tezlikni butunlay tashlab yubormaslik uchun: qanchalik tez
    // otilgan bo'lsa, qaytish shuncha tez bo'ladi.
    // (SpringSimulation buni o'zi qilardi.)
    final speed = details.velocity.pixelsPerSecond.distance;
    final ms = (700 - speed / 6).clamp(280.0, 700.0).round();
    _controller.duration = Duration(milliseconds: ms);

    _return = Tween<Offset>(
      begin: _offset, // ← surat: qayerdan qaytadi
      end: Offset.zero, // ← markazga
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: _curves[_curveName]!,
    ));

    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    // Markazdan uzoqlashgan sari kichrayadi va aylanadi
    final distance = _offset.distance;
    // log("JJJJJJJ ${distance}");
    final scale = (1.0 - distance / 1000).clamp(0.7, 1.0);
    final angle = _offset.dx / 800;

    return Scaffold(
      appBar: AppBar(title: const Text('Mashq 18b: Curves (spring\'siz)')),
      body: Column(
        children: [
          _buildCurvePicker(),
          Expanded(
            child: Stack(
              children: [
                // Markazdan kartochkagacha nuqtali chiziq
                if (_offset != Offset.zero)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _LinePainter(offset: _offset),
                    ),
                  ),
                Center(
                  child: GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Transform.translate(
                      offset: _offset,
                      child: Transform.rotate(
                        angle: angle,
                        child: Transform.scale(
                          scale: scale,
                          child: _buildCard(),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'X: ${_offset.dx.round()}  Y: ${_offset.dy.round()}',
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
          ),
        ],
      ),
    );
  }

  Widget _buildCurvePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        alignment: WrapAlignment.center,
        children: _curves.keys.map((name) {
          return ChoiceChip(
            label: Text(name),
            selected: _curveName == name,
            onSelected: (_) => setState(() => _curveName = name),
          );
        }).toList(),
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
            blurRadius: 16 + _offset.distance / 20,
            offset: Offset(_offset.dx / 20, _offset.dy / 20 + 8),
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
            'Torting',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Markazdan kartochkagacha nuqtali chiziq chizadi.
///
/// Mashq 18 dan farqi: markaz `MediaQuery` dan emas, `paint()` ga
/// kelgan `size` dan olinadi. Shuning uchun AppBar yoki chip qatori
/// bo'lsa ham chiziq to'g'ri joyda turadi.
class _LinePainter extends CustomPainter {
  final Offset offset;

  _LinePainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final len = offset.distance;
    if (len < 1) return; // 0 ga bo'linishdan saqlanish

    final center = Offset(size.width / 2, size.height / 2);
    final dir = offset / len; // birlik vektor

    final paint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Nuqtali chiziq: dashLen chizamiz, dashLen tashlab ketamiz
    const dashLen = 6.0;
    final path = Path();
    for (double d = 0; d < len; d += dashLen * 2) {
      final start = center + dir * d;
      final end = center + dir * (d + dashLen).clamp(0.0, len);
      path.moveTo(start.dx, start.dy);
      path.lineTo(end.dx, end.dy);
    }
    canvas.drawPath(path, paint);

    // Markazdagi nuqta — kartochka qayerga qaytishini ko'rsatadi
    canvas.drawCircle(
      center,
      4,
      Paint()..color = Colors.grey.shade400,
    );
  }

  @override
  bool shouldRepaint(_LinePainter old) => old.offset != offset;
}
