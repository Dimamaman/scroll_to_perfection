import 'package:flutter/material.dart';
import 'dart:math' as math;

class CollapsingCardStack extends StatefulWidget {
  @override
  State<CollapsingCardStack> createState() => _CollapsingCardStackState();
}

class _CollapsingCardStackState extends State<CollapsingCardStack> {
  final _scrollController = ScrollController();

  static const _cardHeight = 320.0;
  static const _minHeight = 64.0;
  static const _cardSpacing = 340.0;

  static final _cards = <_CardData>[
    _CardData('Calories eaten', '568', Color(0xFFFF9500), Icons.restaurant),
    _CardData('Calories to burn', '200', Color(0xFFFF3B30), Icons.local_fire_department),
    _CardData('Meal plan', '5 meals', Color(0xFF34C759), Icons.lunch_dining),
    _CardData('Water intake', '1.5 L', Color(0xFF007AFF), Icons.water_drop),
    _CardData('Sleep', '7h 30m', Color(0xFF5856D6), Icons.bedtime),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double get _offset => _scrollController.hasClients ? _scrollController.offset : 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewH = constraints.maxHeight;
            final totalH = _cards.length * _cardSpacing + viewH;

            return Stack(
              children: [
                SizedBox.expand(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(height: totalH),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (int i = _cards.length - 1; i >= 0; i--)
                          _buildCard(i, viewH),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard(int i, double viewH) {
    final naturalY = i * _cardSpacing - _offset + 24;
    final y = math.max(0.0, naturalY);

    // Keyingi karta yaqinlashganda progress 0→1
    double progress = 0.0;
    if (i < _cards.length - 1) {
      final nextNaturalY = (i + 1) * _cardSpacing - _offset + 24;
      final nextY = math.max(0.0, nextNaturalY);
      progress = (1.0 - nextY / _cardSpacing).clamp(0.0, 1.0);
    }

    // Faza 1 (progress 0..0.8): karta YIQILADI — balandlik kamayadi
    // Faza 2 (progress 0.8..1.0): yig'ilgan karta OPACITY bilan yo'qoladi
    final shrinkT = (progress / 0.8).clamp(0.0, 1.0);
    final fadeT = ((progress - 0.8) / 0.2).clamp(0.0, 1.0);

    final currentH = _cardHeight - shrinkT * (_cardHeight - _minHeight);
    final opacity = 1.0 - fadeT;
    final contentShift = shrinkT * (_cardHeight - _minHeight);

    if (y > viewH || opacity <= 0.0) return const SizedBox.shrink();

    return Positioned(
      top: y,
      left: 16,
      right: 16,
      height: currentH,
      child: Opacity(
        opacity: opacity,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Kontent yuqoriga sirg'aladi
              Positioned(
                top: -contentShift,
                left: 0,
                right: 0,
                height: _cardHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                  child: _CardBody(data: _cards[i]),
                ),
              ),
              // Sarlavha qotib turadi
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: const Color(0xFF2C2C2E),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _cards[i].color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_cards[i].icon, color: _cards[i].color, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _cards[i].title,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  final _CardData data;
  const _CardBody({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(),
        Text(
          data.value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 56,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.6,
            child: Container(
              decoration: BoxDecoration(
                color: data.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardData {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  const _CardData(this.title, this.value, this.color, this.icon);
}
