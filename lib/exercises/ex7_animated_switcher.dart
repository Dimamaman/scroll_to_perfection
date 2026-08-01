import 'package:flutter/material.dart';

class Ex7AnimatedSwitcher extends StatefulWidget {
  @override
  State<Ex7AnimatedSwitcher> createState() => _Ex7AnimatedSwitcherState();
}

class _Ex7AnimatedSwitcherState extends State<Ex7AnimatedSwitcher> {
  int _count = 0;

  void _increment() {
    setState(() {
      _count++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mashq 7: AnimatedSwitcher')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              // transitionBuilder: qanday animatsiya bo'lsin
              // default = FadeTransition (eski yo'qoladi, yangi paydo bo'ladi)
              // buni o'zgartirish mumkin:
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              // key o'zgarsa → "boshqa widget" → animatsiya ishlaydi
              child: Text(
                '$_count',
                key: ValueKey<int>(_count),
                style: const TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _increment,
              icon: const Icon(Icons.add),
              label: const Text('Qo\'shish'),
            ),
          ],
        ),
      ),
    );
  }
}
