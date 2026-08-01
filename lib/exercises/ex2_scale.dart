import 'package:flutter/material.dart';

class Ex2Scale extends StatefulWidget {
  @override
  State<Ex2Scale> createState() => _Ex2ScaleState();
}

class _Ex2ScaleState extends State<Ex2Scale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // 1. Controller: 0 → 1, 600ms
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 2. CurvedAnimation: controller qiymatiga "egri chiziq" qo'shadi
    //    easeOutBack = oxirida biroz oshib ketib qaytadi (prujina effekti)
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
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
    if (_isVisible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mashq 2: Scale')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 3. ScaleTransition: animation qiymatini scale ga aylantiradi
            //    0.0 = ko'rinmaydi, 1.0 = to'liq o'lcham
            ScaleTransition(
              scale: _animation,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.star,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _toggle,
              child: Text(_isVisible ? 'Kichiklashtir' : 'Kattalashtir'),
            ),
          ],
        ),
      ),
    );
  }
}
