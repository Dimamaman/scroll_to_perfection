import 'package:flutter/material.dart';

class Ex8Staggered extends StatefulWidget {
  @override
  State<Ex8Staggered> createState() => _Ex8StaggeredState();
}

class _Ex8StaggeredState extends State<Ex8Staggered>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _items = [
    _ItemData(icon: Icons.mail, label: 'Xabarlar', color: Colors.indigo),
    _ItemData(icon: Icons.photo, label: 'Rasmlar', color: Colors.teal),
    _ItemData(icon: Icons.music_note, label: 'Musiqa', color: Colors.deepOrange),
    _ItemData(icon: Icons.videocam, label: 'Video', color: Colors.purple),
    _ItemData(icon: Icons.settings, label: 'Sozlamalar', color: Colors.blueGrey),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
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
      appBar: AppBar(title: const Text('Mashq 8: Staggered')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Har bir element o'z Interval'i bilan
            for (int i = 0; i < _items.length; i++)
              _StaggeredItem(
                item: _items[i],
                controller: _controller,
                index: i,
                total: _items.length,
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: _play,
              child: const Text('Boshlash'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _StaggeredItem extends StatelessWidget {
  final _ItemData item;
  final AnimationController controller;
  final int index;
  final int total;

  const _StaggeredItem({
    required this.item,
    required this.controller,
    required this.index,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    // Har bir element uchun boshlanish va tugash vaqtini hisoblash
    // index=0: 0.00 — 0.40
    // index=1: 0.15 — 0.55
    // index=2: 0.30 — 0.70
    // index=3: 0.45 — 0.85
    // index=4: 0.60 — 1.00
    final start = index * 0.15;
    final end = (start + 0.4).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutBack),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(-100 * (1 - animation.value), 0),
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: item.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(item.icon, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Text(
              item.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemData {
  final IconData icon;
  final String label;
  final Color color;

  const _ItemData({
    required this.icon,
    required this.label,
    required this.color,
  });
}
