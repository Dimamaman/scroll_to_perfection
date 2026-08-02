import 'dart:ui';

import 'package:flutter/material.dart';

const double kMin = 0.22;
const double kMax = 0.88;

class FriendSheetDemo extends StatefulWidget {
  @override
  State<FriendSheetDemo> createState() => _FriendSheetDemoState();
}

class _FriendSheetDemoState extends State<FriendSheetDemo> {
  final _sheetController = DraggableScrollableController();
  double t = 0.0;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
  }

  void _onSheetChanged() {
    final extent = _sheetController.size;
    final progress = (extent - kMin) / (kMax - kMin);
    setState(() {
      t = progress.clamp(0.0, 1.0);
      _isOpen = t > 0.5;
    });
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  void _toggleSheet() {
    final target = _isOpen ? kMin : kMax;
    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMapBackground(),
          // Qorayish overlay
          IgnorePointer(
            child: Container(
              color: Colors.black.withValues(
                alpha: lerpDouble(0.0, 0.25, t)!,
              ),
            ),
          ),
          // Debug: t qiymati + play tugma
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      't = ${t.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: t,
                        backgroundColor: Colors.white24,
                        color: const Color(0xFF34C759),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Play/Stop tugma
                  GestureDetector(
                    onTap: _toggleSheet,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _isOpen
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom sheet
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: kMin,
            minChildSize: kMin,
            maxChildSize: kMax,
            snap: true,
            snapSizes: const [kMin, kMax],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(lerpDouble(24, 12, t)!),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                // CustomScrollView — BUTUN kontent bitta scrollController bilan
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // Drag handle + header + actions — scrollable lekin fixed ko'rinishda
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildDragHandle(),
                          _MorphHeader(t: t),
                          _MorphActions(t: t),
                        ],
                      ),
                    ),
                    // Pastdagi ro'yxat
                    _MorphListSliver(t: t),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        ),
      ),
      child: CustomPaint(
        painter: _MapPainter(),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 6),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Morph Header: avatar + ism + subtitle + stat
// ─────────────────────────────────────────────
class _MorphHeader extends StatelessWidget {
  final double t;
  const _MorphHeader({required this.t});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final headerHeight = lerpDouble(104, 224, t)!;
    final avatarSize = lerpDouble(52, 92, t)!;
    final avatarLeft = lerpDouble(20, (width - 92) / 2, t)!;
    final avatarTop = lerpDouble(2, 8, t)!;
    final initialsSize = lerpDouble(17, 30, t)!;
    final borderWidth = lerpDouble(2, 3, t)!;

    final nameTop = lerpDouble(6, 112, t)!;
    final namePadLeft = lerpDouble(88, 24, t)!;
    final namePadRight = lerpDouble(104, 24, t)!;
    final nameFontSize = lerpDouble(19, 22, t)!;

    final subtitleTop = lerpDouble(36, 148, t)!;
    final subtitlePadLeft = lerpDouble(88, 24, t)!;
    final subtitlePadRight = lerpDouble(104, 24, t)!;

    final statTop = lerpDouble(74, 186, t)!;

    return SizedBox(
      height: headerHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar
          Positioned(
            left: avatarLeft,
            top: avatarTop,
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF34C759),
                  width: borderWidth,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'SS',
                style: TextStyle(
                  fontSize: initialsSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),

          // Ism
          Positioned(
            left: 0,
            right: 0,
            top: nameTop,
            child: Padding(
              padding: EdgeInsets.only(
                left: namePadLeft,
                right: namePadRight,
              ),
              child: Align(
                alignment: Alignment.lerp(
                  Alignment.centerLeft,
                  Alignment.center,
                  t,
                )!,
                child: Text(
                  'Sarbinaz Saparniyazova',
                  style: TextStyle(
                    fontSize: nameFontSize,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),

          // Subtitle
          Positioned(
            left: 0,
            right: 0,
            top: subtitleTop,
            child: Padding(
              padding: EdgeInsets.only(
                left: subtitlePadLeft,
                right: subtitlePadRight,
              ),
              child: Align(
                alignment: Alignment.lerp(
                  Alignment.centerLeft,
                  Alignment.center,
                  t,
                )!,
                child: Text(
                  'Hozirgina yangilandi',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ),

          // Statistika qatori
          Positioned(
            left: 20,
            right: 20,
            top: statTop,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '2 soat 2 daqiqa shu yerda',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.navigation,
                        size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      '331 m',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Yuqori tugmalar: [...] va [✕]
          Positioned(
            right: 14,
            top: 0,
            child: Row(
              children: [
                _TopButton(icon: Icons.more_horiz),
                const SizedBox(width: 8),
                _TopButton(icon: Icons.close),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Yuqori tugmalar (••• va ✕)
// ─────────────────────────────────────────────
class _TopButton extends StatelessWidget {
  final IconData icon;
  const _TopButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: Colors.grey.shade700),
    );
  }
}

// ─────────────────────────────────────────────
// Morph Action tugmalari
// ─────────────────────────────────────────────
class _MorphActions extends StatelessWidget {
  final double t;
  const _MorphActions({required this.t});

  static const _actions = [
    _ActionData(icon: Icons.chat_bubble_outline, label: 'Xabar'),
    _ActionData(icon: Icons.directions_car_outlined, label: 'Yo\'l'),
    _ActionData(icon: Icons.notifications_none, label: 'Signal'),
    _ActionData(icon: Icons.near_me_outlined, label: 'Kuzatish'),
  ];

  @override
  Widget build(BuildContext context) {
    final btnHeight = lerpDouble(48, 74, t)!;
    final btnRadius = lerpDouble(12, 16, t)!;
    final iconSize = lerpDouble(17, 21, t)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (int i = 0; i < _actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final btnWidth = constraints.maxWidth;
                  final iconLeft =
                      lerpDouble(11, (btnWidth - iconSize) / 2, t)!;
                  final iconTop =
                      lerpDouble((btnHeight - iconSize) / 2, 14, t)!;

                  final textFontSize = lerpDouble(13.5, 11.5, t)!;
                  final textTop = lerpDouble(
                    (btnHeight - 13.5 * 1.3) / 2,
                    44,
                    t,
                  )!;
                  final textPadLeft = lerpDouble(36, 0, t)!;

                  return Container(
                    height: btnHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F5),
                      borderRadius: BorderRadius.circular(btnRadius),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: iconLeft,
                          top: iconTop,
                          child: Icon(
                            _actions[i].icon,
                            size: iconSize,
                            color: Colors.blue,
                          ),
                        ),
                        Positioned(
                          left: textPadLeft,
                          right: 0,
                          top: textTop,
                          child: Align(
                            alignment: Alignment.lerp(
                              Alignment.centerLeft,
                              Alignment.center,
                              t,
                            )!,
                            child: Text(
                              _actions[i].label,
                              style: TextStyle(
                                fontSize: textFontSize,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Pastdagi ro'yxat — Sliver versiya
// ─────────────────────────────────────────────
class _MorphListSliver extends StatelessWidget {
  final double t;
  const _MorphListSliver({required this.t});

  static const _items = [
    _ListItemData(
        icon: Icons.notifications_active, label: 'Ovozli bildirishnoma'),
    _ListItemData(icon: Icons.history, label: 'Harakat tarixi'),
    _ListItemData(icon: Icons.emoji_emotions, label: 'Emoji yuborish'),
    _ListItemData(icon: Icons.share_location, label: 'Joylashuvni ulashish'),
    _ListItemData(icon: Icons.settings, label: 'Sozlamalar'),
    _ListItemData(icon: Icons.block, label: 'Bloklash', isDestructive: true),
  ];

  @override
  Widget build(BuildContext context) {
    final listT = ((t - 0.45) / 0.55).clamp(0.0, 1.0);

    return SliverToBoxAdapter(
      child: Opacity(
        opacity: listT,
        child: Transform.translate(
          offset: Offset(0, lerpDouble(14, 0, listT)!),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Divider(height: 1, color: Colors.grey.shade200),
              for (final item in _items) ...[
                ListTile(
                  leading: Icon(
                    item.icon,
                    color:
                        item.isDestructive ? Colors.red : Colors.grey.shade700,
                    size: 22,
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 15,
                      color: item.isDestructive ? Colors.red : Colors.black87,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onTap: () {},
                ),
                Divider(
                  height: 1,
                  indent: 56,
                  color: Colors.grey.shade200,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Ma'lumot modellari
// ─────────────────────────────────────────────
class _ActionData {
  final IconData icon;
  final String label;
  const _ActionData({required this.icon, required this.label});
}

class _ListItemData {
  final IconData icon;
  final String label;
  final bool isDestructive;
  const _ListItemData({
    required this.icon,
    required this.label,
    this.isDestructive = false,
  });
}

// ─────────────────────────────────────────────
// Xarita foni (sodda grid)
// ─────────────────────────────────────────────
class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB9DDB5)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    final roadPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.3, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.35),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.65, size.height * 0.6),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
