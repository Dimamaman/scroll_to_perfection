import 'package:flutter/material.dart';

/// Har bir bo'lim: rang + sarlavha + matn.
class ScrollRevealExample extends StatefulWidget {
  @override
  State<ScrollRevealExample> createState() => _ScrollRevealExampleState();
}

class _ScrollRevealExampleState extends State<ScrollRevealExample> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scroll Reveal misoli')),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _sections.length,
        itemBuilder: (context, index) {
          final section = _sections[index];
          return Container(
            height: MediaQuery.of(context).size.height,
            color: section.color,
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(32),
            child: RevealOnScroll(
              scrollController: _scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    section.text,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
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

/// Bola scroll bilan ekranga kirganda, silliq ravishda pastdan yuqoriga suzib chiqadigan
/// va shaffoflikdan ko'rinadigan bo'ladigan qayta ishlatsa bo'ladigan wrapper.
///
/// Bu — lib/egipt/page1.dart dagi g'oyaning soddalashtirilgan versiyasi:
/// scrollController orqali "qachon tekshirish kerak"ni bilish + RenderBox orqali
/// "ekranga kirdimi"ni aniqlash + AnimationController orqali silliq harakat yasash.
class RevealOnScroll extends StatefulWidget {
  final ScrollController scrollController;
  final Widget child;

  /// Ekranning necha foiziga yetganda animatsiya boshlanadi (0.85 = balandlikning 85%).
  final double visibleAt;

  const RevealOnScroll({
    Key? key,
    required this.scrollController,
    required this.child,
    this.visibleAt = 0.85,
  }) : super(key: key);

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // scrollController scroll bo'lganda shu builder qayta chaqiriladi ->
    // aynan shu yerda "ekranga kirdimi" tekshiriladi.
    return AnimatedBuilder(
      animation: widget.scrollController,
      builder: (context, _) {
        if (!_hasStarted) {
          final renderObject = context.findRenderObject() as RenderBox?;
          final offsetY = renderObject?.localToGlobal(Offset.zero).dy ?? 0;
          final screenHeight = MediaQuery.of(context).size.height;
          if (renderObject != null &&
              offsetY < screenHeight * widget.visibleAt) {
            _hasStarted = true;
            _controller.forward();
          }
        }

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) => Opacity(
            opacity: _animation.value,
            child: Transform.translate(
              // Boshida 40px pastda turadi, animatsiya oxirida 0 -> o'z joyida.
              offset: Offset(0, (1 - _animation.value) * 40),
              child: child,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
