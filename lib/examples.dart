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
  late final Animation<double> _animation;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
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
            animation: _animation,
            builder: (BuildContext context, Widget? child) => Opacity(
              opacity: _animation.value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, (1 - _animation.value) * 50),
                child: child,
              ),
            ),
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
          );
        },
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
