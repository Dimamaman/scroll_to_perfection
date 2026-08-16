import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class MyScroll extends StatefulWidget {
  @override
  State<MyScroll> createState() => _MyScrollState();
}

class _MyScrollState extends State<MyScroll> {
  late final ScrollController scrollController;

  static const _sections = [
    _Section(
      color: Colors.indigo,
      title: 'Birinchi bo\'lim',
      text: 'Pastga qarab scroll qiling — matn asta-sekin, silliq ko\'rinadi.',
    ),
    _Section(
      color: Colors.teal,
      title: 'Ikkinchi bo\'lim',
      text:
          'Har bir matn faqat ekranga kirganda, faqat bir marta animatsiya qiladi.',
    ),
    _Section(
      color: Colors.deepOrange,
      title: 'Uchinchi bo\'lim',
      text:
          'Animatsiya: shaffoflik (opacity) + pastdan yuqoriga siljish (translate).',
    ),
    _Section(
      color: Colors.purple,
      title: 'To\'rtinchi bo\'lim',
      text: 'Tabriklaymiz, oxirigacha yetdingiz!',
    ),
  ];

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Scroll"),
      ),
      body: ListView.builder(
          itemCount: _sections.length,
          controller: scrollController,
          itemBuilder: (context, index) {
            final section = _sections[index];
            return SectionBox(
              section: section,
              scrollController: scrollController,
            );
          }),
    );
  }
}

class SectionBox extends StatefulWidget {
  final _Section section;
  final ScrollController scrollController;
  const SectionBox(
      {Key? key, required this.section, required this.scrollController})
      : super(key: key);

  @override
  State<SectionBox> createState() => _SectionBoxState();
}

class _SectionBoxState extends State<SectionBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      color: widget.section.color,
      padding: const EdgeInsets.all(32),
      alignment: Alignment.bottomLeft,
      child: AnimatedBuilder(
        animation: widget.scrollController,
        builder: (BuildContext context, Widget? child) {
          if (!_hasStarted) {
            final renderObject = context.findRenderObject() as RenderBox?;
            final offsetY = renderObject?.localToGlobal(Offset.zero).dy ?? 0;
            final screenHeight = MediaQuery.of(context).size.height;
            if (renderObject != null && offsetY < screenHeight * 0.85) {
              _hasStarted = true;
              _controller.forward();
            }
          }

          return AnimatedBuilder(
            animation: _controller,
            builder: (BuildContext context, Widget? child) {
              // sin(pi * value): 0 → 1 → 0
              // Boshida 0 (joyida), o'rtada 1 (tepada), oxirida 0 (joyiga qaytdi)
              final progress = sin(pi * _controller.value);
              final screenHeight = MediaQuery.of(context).size.height;
              print("JJJJJJJJ ${-progress * screenHeight * 0.7}");
              return Transform.translate(
                offset: Offset(0, -progress * screenHeight * 0.7),
                child: child,
              );
            },
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.section.title,
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
            Text(
              widget.section.text,
              style: TextStyle(color: Colors.white, fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}

class _Section {
  final Color color;
  final String title;
  final String text;

  const _Section(
      {required this.color, required this.title, required this.text});
}

class GestureDetectorExample extends StatefulWidget {
  const GestureDetectorExample({Key? key}) : super(key: key);

  @override
  State<GestureDetectorExample> createState() => _GestureDetectorExampleState();
}

class _GestureDetectorExampleState extends State<GestureDetectorExample>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  double _dx = 0;
  double _dy = 0;

  double _startDx = 0;
  double _startDy = 0;

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    animationController.addListener(() {
      setState(() {
        // print("FFFF 22222 $_dx ~~ $_dy");
        final t = animationController.value;
        _dx = lerpDouble(_startDx, 0, t)!;
        _dy = lerpDouble(_startDy, 0, t)!;
        print("FFFF $_startDx || $_dx ~~ $_dy *** $t");

        // _dx = lerpDouble(_startDx, 0, t)!;        // 1
        // _dx = _startDx + (0 - _startDx) * t;      // 2 — formulaning o'zi
        // _dx = _startDx * (1 - t);                 // 3 — soddalashtirilgan
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // print("FFFF 44444 $_dx ~~ $_dy");
          return Center(
            child: Transform.translate(
              offset: Offset(_dx, _dy),
              child: GestureDetector(
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    _dx += details.delta.dx;
                    _dy += details.delta.dy;
                  });
                },
                onPanEnd: (details) {
                  print("MMMMMM $_dx");
                  _startDx = _dx;
                  _startDy = _dy;
                  // print("FFFF 1111 $_dx ~~ $_dy");
                  animationController.forward(from: 0);
                },
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.red,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FabExample extends StatefulWidget {
  const FabExample({Key? key}) : super(key: key);

  @override
  State<FabExample> createState() => _FabExampleState();
}

class _FabExampleState extends State<FabExample>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  bool get _isClosed => animationController.isDismissed;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void toggle() {
    if (_isClosed) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  static const _icons = [
    Icons.sports_martial_arts,
    Icons.museum,
    Icons.attach_file_sharp,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget? child) {
          return Stack(
            children: [
              for (int i = 0; i < _icons.length; i++) _buildMiniFabIcon(i),
              Positioned(
                right: 16,
                bottom: 36,
                child: GestureDetector(
                  onTap: toggle,
                  child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Transform.rotate(
                      angle: animationController.value * (pi / 4),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMiniFabIcon(int i) {
    final t = animationController.value;
    final isReversing = animationController.status == AnimationStatus.reverse;

    // Yopilayotganda indeksni teskarisiga o'giramiz
    final index = isReversing ? (_icons.length - 1 - i) : i;

    final start = index * 0.2;
    final end = start + 0.6;
    final localT = Interval(
      start,
      end,
      curve: isReversing ? Curves.easeInCubic : Curves.easeOutCubic,
    ).transform(t);

    final closedBottom = 36.0;
    final openBottom = 36.0 + 70.0 * (i + 1);

    return Positioned(
      right: 16,
      bottom: lerpDouble(closedBottom, openBottom, localT)!,
      child: Container(
        width: 65,
        height: 65,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: Icon(
          _icons[i],
          color: Colors.white,
          size: 35,
        ),
      ),
    );
  }
}
