import 'package:flutter/material.dart';

class Ex11PageTransition extends StatelessWidget {
  const Ex11PageTransition({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mashq 11: Page Transition')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Navigator.push ichida PageRouteBuilder ishlatsak, sahifa qanday kirishini o\'zimiz boshqaramiz.',
              style: TextStyle(fontSize: 17, height: 1.35),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _open(context, const _SlideFadePage()),
              child: const Text('Slide + Fade ochish'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _open(context, const _ScaleRotatePage()),
              child: const Text('Scale + Rotate ochish'),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        reverseTransitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          if (page is _ScaleRotatePage) {
            return RotationTransition(
              turns: Tween<double>(begin: -0.04, end: 0).animate(curved),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.86, end: 1).animate(curved),
                child: FadeTransition(opacity: curved, child: child),
              ),
            );
          }

          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.12),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(opacity: curved, child: child),
          );
        },
      ),
    );
  }
}

class _SlideFadePage extends StatelessWidget {
  const _SlideFadePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _TransitionResultPage(
      color: Color(0xFF00897B),
      icon: Icons.keyboard_arrow_up,
      title: 'Slide + Fade',
      body:
          'Bu usul modal, bottom sheet yoki yangi ekranni yumshoq kirgizishda juda ko\'p ishlatiladi.',
    );
  }
}

class _ScaleRotatePage extends StatelessWidget {
  const _ScaleRotatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _TransitionResultPage(
      color: Color(0xFF8E24AA),
      icon: Icons.explore,
      title: 'Scale + Rotate',
      body:
          'Kichik burilish va scale effekti ko\'proq playful UI, card detail yoki galereyada yaxshi ko\'rinadi.',
    );
  }
}

class _TransitionResultPage extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String body;

  const _TransitionResultPage({
    Key? key,
    required this.color,
    required this.icon,
    required this.title,
    required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 100, color: Colors.white),
              const SizedBox(height: 24),
              Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
