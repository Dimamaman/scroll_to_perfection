import 'package:flutter/material.dart';

class Ex10HeroMorph extends StatelessWidget {
  const Ex10HeroMorph({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mashq 10: Hero Morph')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _LessonText(
            title: 'Hero nima qiladi?',
            body:
                'Bir sahifadagi widgetni ikkinchi sahifadagi widgetga uchirib olib boradi. '
                'Ikkala joyda ham bir xil tag bo\'lsa, Flutter oradagi animatsiyani o\'zi yasaydi.',
          ),
          SizedBox(height: 20),
          _HeroCard(
            tag: 'coffee-card',
            title: 'Morning Coffee',
            subtitle: 'Hero + Material + borderRadius',
            color: Color(0xFF6D4C41),
            icon: Icons.coffee,
          ),
          SizedBox(height: 16),
          _HeroCard(
            tag: 'music-card',
            title: 'Focus Playlist',
            subtitle: 'Hero orqali detail page ochish',
            color: Color(0xFF1565C0),
            icon: Icons.headphones,
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String tag;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _HeroCard({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _HeroDetailPage(
              tag: tag,
              title: title,
              subtitle: subtitle,
              color: color,
              icon: icon,
            ),
          ),
        );
      },
      child: Hero(
        tag: tag,
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            height: 150,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 52),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroDetailPage extends StatelessWidget {
  final String tag;
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _HeroDetailPage({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: color,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(title),
              background: Hero(
                tag: tag,
                child: Material(
                  color: color,
                  child: Center(
                    child: Icon(icon, color: Colors.white, size: 130),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _LessonText(
                    title: 'Muhim qoidalar',
                    body:
                        'Hero ishlashi uchun boshlang\'ich va oxirgi widgetda tag bir xil bo\'lishi kerak. '
                        'Material qo\'shsak, matn va ranglar uchish vaqtida chiroyli render bo\'ladi.',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 400),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonText extends StatelessWidget {
  final String title;
  final String body;

  const _LessonText({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(body, style: const TextStyle(fontSize: 16, height: 1.35)),
      ],
    );
  }
}
