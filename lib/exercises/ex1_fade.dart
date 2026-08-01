import 'package:flutter/material.dart';

class Ex1Fade extends StatefulWidget {
  @override
  State<Ex1Fade> createState() => _Ex1FadeState();
}

class _Ex1FadeState extends State<Ex1Fade> with SingleTickerProviderStateMixin {
  // 1. AnimationController — 500ms da 0 dan 1 gacha sanaydigan stopwatch
  late final AnimationController _controller;

  // Widget hozir ko'rinyaptimi yoki yo'qmi — tugma bosilganda almashadi
  bool _isVisible = false;

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

  void _toggle() {
    setState(() {
      _isVisible = !_isVisible;
    });
    // true bo'lsa: 0 → 1 (paydo bo'ladi), false bo'lsa: 1 → 0 (yo'qoladi)
    if (_isVisible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mashq 1: Fade In/Out')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 2. FadeTransition — controller qiymatini opacity ga aylantiradi
            //    controller.value = 0 bo'lsa → opacity: 0 (ko'rinmaydi)
            //    controller.value = 1 bo'lsa → opacity: 1 (to'liq ko'rinadi)
            FadeTransition(
              opacity: _controller,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Salom!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _toggle,
              child: Text(_isVisible ? 'Yashir' : 'Ko\'rsat'),
            ),
          ],
        ),
      ),
    );
  }
}
