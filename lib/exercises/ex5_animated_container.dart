import 'package:flutter/material.dart';

class Ex5AnimatedContainer extends StatefulWidget {
  @override
  State<Ex5AnimatedContainer> createState() => _Ex5AnimatedContainerState();
}

class _Ex5AnimatedContainerState extends State<Ex5AnimatedContainer> {
  bool _isExpanded = false;

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mashq 5: AnimatedContainer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              // setState da _isExpanded o'zgaradi →
              // hamma qiymatlar SILLIQ animatsiya bilan o'tadi
              width: _isExpanded ? 250 : 100,
              height: _isExpanded ? 250 : 100,
              decoration: BoxDecoration(
                color: _isExpanded ? Colors.deepOrange : Colors.indigo,
                borderRadius: BorderRadius.circular(_isExpanded ? 30 : 50),
              ),
              alignment: Alignment.center,
              child: Icon(
                _isExpanded ? Icons.close : Icons.add,
                color: Colors.white,
                size: _isExpanded ? 60 : 40,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _toggle,
              child: Text(_isExpanded ? 'Kichiklashtir' : 'Kattalashtir'),
            ),
          ],
        ),
      ),
    );
  }
}
