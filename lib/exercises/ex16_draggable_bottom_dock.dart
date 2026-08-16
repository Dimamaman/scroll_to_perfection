import 'dart:ui';

import 'package:flutter/material.dart';

class Ex16DraggableBottomDock extends StatefulWidget {
  const Ex16DraggableBottomDock({Key? key}) : super(key: key);

  @override
  State<Ex16DraggableBottomDock> createState() =>
      _Ex16DraggableBottomDockState();
}

class _Ex16DraggableBottomDockState extends State<Ex16DraggableBottomDock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _items = [
    _DockItem(
        icon: Icons.home_rounded, label: 'Home', color: Color(0xFF1976D2)),
    _DockItem(
      icon: Icons.search_rounded,
      label: 'Search',
      color: Color(0xFF00897B),
    ),
    _DockItem(
      icon: Icons.add_rounded,
      label: 'Create',
      color: Color(0xFF7B1FA2),
    ),
    _DockItem(
      icon: Icons.chat_bubble_rounded,
      label: 'Chat',
      color: Color(0xFFE53935),
    ),
    _DockItem(
      icon: Icons.person_rounded,
      label: 'Profile',
      color: Color(0xFF5D4037),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _controller.value =
        (_controller.value - details.delta.dy / 180).clamp(0.0, 1.0);
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond.dy;
    final shouldOpen =
        velocity < -350 || (_controller.value > 0.5 && velocity < 350);

    _controller.animateTo(
      shouldOpen ? 1 : 0,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  void _toggle() {
    final target = _controller.value < 0.5 ? 1.0 : 0.0;
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Draggable Bottom Dock')),
      body: Stack(
        children: [
          const _DemoContent(),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                child: GestureDetector(
                  onTap: _toggle,
                  onVerticalDragUpdate: _onDragUpdate,
                  onVerticalDragEnd: _onDragEnd,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final t =
                          Curves.easeOutCubic.transform(_controller.value);
                      final width = lerpDouble(300, 352, t)!;
                      final height = lerpDouble(86, 228, t)!;

                      return Container(
                        width: width,
                        height: height,
                        padding: EdgeInsets.lerp(
                          const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          const EdgeInsets.fromLTRB(18, 12, 18, 18),
                          t,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151A22),
                          borderRadius: BorderRadius.circular(28 - 8 * t),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.22),
                              blurRadius: 26,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _Grabber(progress: t),
                            Expanded(
                              child: Stack(
                                children: [
                                  Opacity(
                                    opacity: 1 - t,
                                    child: _CollapsedDock(items: _items),
                                  ),
                                  Opacity(
                                    opacity: t,
                                    child: _ExpandedDock(items: _items),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoContent extends StatelessWidget {
  const _DemoContent();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 150),
      children: [
        const Text(
          'Pastdagi dockni yuqoriga torting. U compact holatdan expanded holatga o\'tadi.',
          style: TextStyle(fontSize: 17, height: 1.35),
        ),
        const SizedBox(height: 24),
        for (int i = 0; i < 6; i++)
          Container(
            height: 86,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              'Content card ${i + 1}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}

class _Grabber extends StatelessWidget {
  final double progress;

  const _Grabber({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: lerpDouble(42, 64, progress)!,
      height: 5,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.36 + 0.22 * progress),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _CollapsedDock extends StatelessWidget {
  final List<_DockItem> items;

  const _CollapsedDock({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final item in items)
          _DockIcon(
            item: item,
            showLabel: false,
            size: item.label == 'Create' ? 58 : 48,
          ),
      ],
    );
  }
}

class _ExpandedDock extends StatelessWidget {
  final List<_DockItem> items;

  const _ExpandedDock({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 6, bottom: 10),
          child: Text(
            'Quick actions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.2,
            children: [
              for (final item in items)
                _DockIcon(
                  item: item,
                  showLabel: true,
                  size: 52,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DockIcon extends StatelessWidget {
  final _DockItem item;
  final bool showLabel;
  final double size;

  const _DockIcon({
    required this.item,
    required this.showLabel,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final labelSpace = showLabel ? 26.0 : 0.0;
        final availableHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight - labelSpace
            : size;
        final iconSize = size.clamp(36.0, availableHeight);

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(showLabel ? 18 : 24),
              ),
              child: Icon(
                item.icon,
                color: Colors.white,
                size: iconSize * 0.58,
              ),
            ),
            if (showLabel) ...[
              const SizedBox(height: 7),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DockItem {
  final IconData icon;
  final String label;
  final Color color;

  const _DockItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}
