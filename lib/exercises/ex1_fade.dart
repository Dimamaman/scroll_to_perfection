import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FadeAnimationExample extends StatefulWidget {
  @override
  State<FadeAnimationExample> createState() => _FadeAnimationExampleState();
}

class _FadeAnimationExampleState extends State<FadeAnimationExample>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;
  bool isVisible = true;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
      value: 1,
    );

    animationController.addListener(() {
      log("FRAME: ${animationController.value}");
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() {
      isVisible = !isVisible;
    });

    if (isVisible) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fade In/Out"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: animationController,
              child: Container(
                height: 200,
                width: 200,
                color: Colors.blueAccent,
                alignment: Alignment.center,
                child: Text(
                  "Hello",
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            CupertinoButton(child: Text("Press"), onPressed: toggle)
          ],
        ),
      ),
    );
  }
}
