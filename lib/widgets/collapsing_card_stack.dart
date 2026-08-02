import 'dart:math' as math;

import 'package:flutter/material.dart';

class CollapsingCardStack extends StatefulWidget {
  @override
  State<CollapsingCardStack> createState() => _CollapsingCardStackState();
}

class _CollapsingCardStackState extends State<CollapsingCardStack> {
  final _scrollController = ScrollController();

  static const _minHeight = 64.0;
  static const _cardSpacing = 20.0;

  static final _items = <_Item>[
    _Item.single(
      _CardData('Calories eaten', '568', Color(0xFFFF9500), Icons.restaurant),
      height: 320,
    ),
    _Item.single(
      _CardData('Calories to burn', '200', Color(0xFFFF3B30),
          Icons.local_fire_department),
      height: 320,
    ),
    _Item.pair(
      _CardData('Feels like', '36°', Color(0xFF64D2FF), Icons.thermostat),
      _CardData('UV Index', '8', Color(0xFFFFD60A), Icons.wb_sunny),
      height: 200,
    ),
    _Item.single(
      _CardData('Meal plan', '5 meals', Color(0xFF34C759), Icons.lunch_dining),
      height: 320,
    ),
    _Item.pair(
      _CardData('Steps', '8,432', Color(0xFF30D158), Icons.directions_walk),
      _CardData('Heart rate', '72 bpm', Color(0xFFFF2D55), Icons.favorite),
      height: 200,
    ),
    _Item.single(
      _CardData('Water intake', '1.5 L', Color(0xFF007AFF), Icons.water_drop),
      height: 320,
    ),
    _Item.single(
      _CardData('Sleep', '7h 30m', Color(0xFF5856D6), Icons.bedtime),
      height: 320,
    ),
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

  double get _offset =>
      _scrollController.hasClients ? _scrollController.offset : 0.0;

  // Har bir itemning tabiiy Y pozitsiyasi
  double _naturalY(int i) {
    double y = 24.0;
    for (int j = 0; j < i; j++) {
      y += _items[j].height + _cardSpacing;
    }
    return y;
  }

  double get _totalHeight {
    double h = 24.0;
    for (final item in _items) {
      h += item.height + _cardSpacing;
    }
    return h;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewH = constraints.maxHeight;

            return Stack(
              children: [
                SizedBox.expand(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(height: _totalHeight + viewH),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (int i = 0; i < _items.length; i++)
                          _buildItem(i, viewH),
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

  Widget _buildItem(int i, double viewH) {
    final itemH = _items[i].height;
    final natY = _naturalY(i) - _offset;
    final y = math.max(0.0, natY);

    double progress = 0.0;
    if (i < _items.length - 1) {
      final nextNatY = _naturalY(i + 1) - _offset;
      final nextY = math.max(0.0, nextNatY);
      final dist = _items[i].height + _cardSpacing;
      progress = (1.0 - nextY / dist).clamp(0.0, 1.0);
    }

    final shrinkT = (progress / 0.8).clamp(0.0, 1.0);
    final fadeT = ((progress - 0.8) / 0.2).clamp(0.0, 1.0);

    final currentH = itemH - shrinkT * (itemH - _minHeight);
    final opacity = 1.0 - fadeT;
    final contentShift = shrinkT * (itemH - _minHeight);

    if (y > viewH || opacity <= 0.0) return const SizedBox.shrink();

    final isBeingCovered = progress > 0.0;
    final displayOpacity = isBeingCovered ? opacity : 1.0;

    final item = _items[i];

    return Positioned(
      top: y,
      left: 16,
      right: 16,
      height: currentH,
      child: Opacity(
        opacity: displayOpacity,
        child: item.isPair
            ? _buildPairCard(item, contentShift)
            : _buildSingleCard(item.left, itemH, contentShift),
      ),
    );
  }

  Widget _buildSingleCard(
      _CardData data, double fullH, double contentShift) {
    return Container(
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
          Positioned(
            top: -contentShift,
            left: 0,
            right: 0,
            height: fullH,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
              child: _CardBody(data: data),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: const Color(0xFF2C2C2E),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: _TitleRow(data: data),
            ),
          ),
        ],
      ),
    );
  }

  // Ikkita alohida kichik karta — har biri mustaqil yig'iladi
  Widget _buildPairCard(_Item item, double contentShift) {
    final fullH = item.height;
    return Row(
      children: [
        Expanded(child: _buildMiniCard(item.left, fullH, contentShift)),
        const SizedBox(width: 12),
        Expanded(child: _buildMiniCard(item.right!, fullH, contentShift)),
      ],
    );
  }

  Widget _buildMiniCard(_CardData data, double fullH, double contentShift) {
    return Container(
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
            height: fullH,
            child: Padding(
              padding: const EdgeInsets.only(top: 48),
              child: _SmallCardBody(data: data),
            ),
          ),
          // Sarlavha qotib turadi
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: const Color(0xFF2C2C2E),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: _TitleRow(data: data),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
class _TitleRow extends StatelessWidget {
  final _CardData data;
  const _TitleRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: data.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Icon(data.icon, color: data.color, size: 16),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            data.title.toUpperCase(),
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
class _SmallCardBody extends StatelessWidget {
  final _CardData data;
  const _SmallCardBody({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const Spacer(),
          Container(
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: data.color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
class _Item {
  final _CardData left;
  final _CardData? right;
  final double height;
  bool get isPair => right != null;

  _Item.single(this.left, {required this.height}) : right = null;
  _Item.pair(this.left, _CardData r, {required this.height}) : right = r;
}

class _CardData {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  const _CardData(this.title, this.value, this.color, this.icon);
}
