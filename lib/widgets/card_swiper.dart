import 'dart:math' as math;

import 'package:flutter/material.dart';

// ─── Data Model ───────────────────────────────────────────────
class CardData {
  final String name;
  final String subtitle;
  final String emoji;
  final Color color;
  final String desc;

  const CardData({
    required this.name,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.desc,
  });
}

const List<CardData> kCards = [
  CardData(
      name: 'Tokyo',
      subtitle: 'Japan',
      emoji: '🗼',
      color: Color(0xFFE8453C),
      desc: 'Neon lights meet ancient temples'),
  CardData(
      name: 'Paris',
      subtitle: 'France',
      emoji: '🗼',
      color: Color(0xFF2D5DA1),
      desc: 'Art, romance, and golden pastries'),
  CardData(
      name: 'New York',
      subtitle: 'USA',
      emoji: '🗽',
      color: Color(0xFF1A1A2E),
      desc: 'The city that never sleeps'),
  CardData(
      name: 'Istanbul',
      subtitle: 'Türkiye',
      emoji: '🕌',
      color: Color(0xFFC0392B),
      desc: 'Where East meets West'),
  CardData(
      name: 'Samarkand',
      subtitle: 'Uzbekistan',
      emoji: '🏰',
      color: Color(0xFF1E88E5),
      desc: 'The jewel of the Silk Road'),
  CardData(
      name: 'Sydney',
      subtitle: 'Australia',
      emoji: '🦘',
      color: Color(0xFFF39C12),
      desc: 'Sun, surf, and Opera House'),
  CardData(
      name: 'Rio',
      subtitle: 'Brazil',
      emoji: '🎭',
      color: Color(0xFF27AE60),
      desc: 'Carnival spirit all year round'),
];

/// Fon gradientining o'rta rangi.
/// Kartalarda alpha o'rniga shu rang bilan aralashtiriladi.
const Color _kBgMid = Color(0xFF302B63);

// ─── Main Screen ──────────────────────────────────────────────
class CardSwiperScreen extends StatefulWidget {
  const CardSwiperScreen({Key? key}) : super(key: key);

  @override
  State<CardSwiperScreen> createState() => _CardSwiperScreenState();
}

class _CardSwiperScreenState extends State<CardSwiperScreen>
    with SingleTickerProviderStateMixin {
  late List<CardData> _cards;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  late AnimationController _exitController;
  late Animation<Offset> _exitAnimation;
  late Animation<double> _exitRotation;
  bool _isAnimating = false;

  static const double _swipeThreshold = 100.0;
  static const int _maxVisible = 4;

  @override
  void initState() {
    super.initState();
    _cards = List.from(kCards);
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _cards.removeAt(0);
            _dragOffset = Offset.zero;
            _isAnimating = false;
            _exitController.reset();
          });
        }
      });
  }

  @override
  void dispose() {
    _exitController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_isAnimating || _cards.isEmpty) return;
    setState(() => _isDragging = true);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() => _dragOffset += details.delta);
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    if (_dragOffset.dx > _swipeThreshold) {
      _animateExit(1); // right
    } else if (_dragOffset.dx < -_swipeThreshold) {
      _animateExit(-1); // left
    } else {
      setState(() => _dragOffset = Offset.zero);
    }
  }

  void _animateExit(int direction) {
    _isAnimating = true;
    _exitAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset(direction * 500, -40),
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInOut,
    ));
    _exitRotation = Tween<double>(
      begin: _dragOffset.dx * 0.001,
      end: direction * 0.4,
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeInOut,
    ));
    _exitController.forward();
  }

  void _swipe(int direction) {
    if (_cards.isEmpty || _isAnimating) return;
    _animateExit(direction);
  }

  void _reset() {
    setState(() {
      _cards = List.from(kCards);
      _dragOffset = Offset.zero;
      _isAnimating = false;
      _exitController.reset();
    });
  }

  // ─── Fan offset for back cards ─────────────────────────────
  double _fanX(int index) {
    if (index == 0) return 0;
    final direction = index.isOdd ? 1.0 : -1.0;
    return direction * (8 + index * 10);
  }

  double _fanRotation(int index) {
    if (index == 0) return 0;
    final direction = index.isOdd ? 1.0 : -1.0;
    return direction * index * 3 * (math.pi / 180);
  }

  double _fanScale(int index) => 1 - index * 0.04;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Container bolasiga qarab o'lchanadi — Column esa eng keng
        // bolasi qadar (320px) bo'lib qolardi. Shuning uchun majburan
        // butun ekranni egallashini aytamiz.
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 32),
              // ── Title
              Text(
                'EXPLORE DESTINATIONS',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 3,
                ),
              ),
              const Spacer(),
              // ── Card Stack
              SizedBox(
                width: 320,
                height: 440,
                child: _cards.isEmpty && !_isAnimating
                    ? _buildEmptyState()
                    : _buildCardStack(),
              ),
              const Spacer(),
              // ── Buttons
              if (_cards.isNotEmpty) _buildActions(),
              // ── Counter
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 24),
                child: Text(
                  _cards.isNotEmpty ? '${_cards.length} ta karta qoldi' : '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Card Stack ─────────────────────────────────────────────
  Widget _buildCardStack() {
    final visible = _cards.length > _maxVisible
        ? _cards.sublist(0, _maxVisible)
        : List<CardData>.from(_cards);

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Back cards (reversed so first is on top)
        for (int i = visible.length - 1; i >= 1; i--)
          _buildBackCard(visible[i], i),
        // Top card (draggable)
        if (visible.isNotEmpty) _buildTopCard(visible[0]),
      ],
    );
  }

  Widget _buildBackCard(CardData card, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      transform: Matrix4.identity()
        ..translateByDouble(_fanX(index), 0.0, 0.0, 1.0)
        ..rotateZ(_fanRotation(index))
        ..scaleByDouble(
            _fanScale(index), _fanScale(index), _fanScale(index), 1.0),
      transformAlignment: Alignment.bottomCenter,
      // Opacity YO'Q — kartalar to'liq qorong'i (opaque) qoladi,
      // bir-birining orqasi ko'rinmaydi. Chuqurlik hissi faqat
      // qoraytirish (ColorFiltered) va scale orqali beriladi.
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.black.withValues(alpha: (index * 0.12).clamp(0.0, 1.0)),
          BlendMode.darken,
        ),
        child: _buildCard(card),
      ),
    );
  }

  Widget _buildTopCard(CardData card) {
    return AnimatedBuilder(
      animation: _exitController,
      builder: (context, child) {
        Offset offset = _dragOffset;
        double rot = _dragOffset.dx * 0.001;

        if (_isAnimating) {
          offset = _exitAnimation.value;
          rot = _exitRotation.value;
        }

        return GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: _onPanEnd,
          child: Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()
              ..translateByDouble(offset.dx, offset.dy, 0.0, 1.0)
              ..rotateZ(rot),
            child: Stack(
              children: [
                _buildCard(card),
                // LIKE / NOPE label
                if (_dragOffset.dx.abs() > 30 && !_isAnimating)
                  _buildSwipeLabel(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Swipe Label ────────────────────────────────────────────
  Widget _buildSwipeLabel() {
    final isLike = _dragOffset.dx > 0;
    final opacity = (_dragOffset.dx.abs() / 100).clamp(0.0, 1.0);

    return Positioned(
      top: 24,
      left: isLike ? 24 : null,
      right: isLike ? null : 24,
      child: Transform.rotate(
        angle: isLike ? -0.2 : 0.2,
        child: Opacity(
          opacity: opacity,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isLike ? const Color(0xFF4ADE80) : const Color(0xFFF87171),
                width: 3,
              ),
            ),
            child: Text(
              isLike ? 'LIKE 💚' : 'NOPE 👋',
              style: TextStyle(
                color:
                    isLike ? const Color(0xFF4ADE80) : const Color(0xFFF87171),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Single Card ────────────────────────────────────────────
  Widget _buildCard(CardData card) {
    return Container(
      width: 300,
      height: 420,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          // Alpha ISHLATILMAYDI — aks holda orqadagi karta ko'rinib qoladi.
          // O'sha ko'rinishni olish uchun rangni fon rangi tomon
          // aralashtiramiz: natija bir xil, lekin to'liq opaque.
          colors: [
            Color.lerp(card.color, _kBgMid, 0.10)!,
            Color.lerp(card.color, _kBgMid, 0.45)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          Text(card.emoji, style: const TextStyle(fontSize: 56)),
          Column(
            children: [
              Text(
                card.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                card.subtitle.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              card.desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 15,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Action Buttons ─────────────────────────────────────────
  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(
            icon: Icons.close,
            color: const Color(0xFFF87171),
            onTap: () => _swipe(-1),
          ),
          const SizedBox(width: 24),
          _buildActionButton(
            icon: Icons.favorite,
            color: const Color(0xFF4ADE80),
            onTap: () => _swipe(1),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          color: color.withValues(alpha: 0.1),
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }

  // ─── Empty State ────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('✨',
              style: TextStyle(
                  fontSize: 48, color: Colors.white.withValues(alpha: 0.4))),
          const SizedBox(height: 16),
          Text(
            'Barcha kartalar ko\'rib chiqildi',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 14),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _reset,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: const Text(
                'Qayta boshlash',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
