import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scroll_to_perfection/blocked_animation.dart';
import 'package:scroll_to_perfection/cuberto.dart';
import 'package:scroll_to_perfection/egipt/egypt.dart';
import 'package:scroll_to_perfection/examples.dart';
import 'package:scroll_to_perfection/scroll_reveal_example.dart';
import 'package:scroll_to_perfection/timer_animation.dart';
import 'package:scroll_to_perfection/vgv.dart';
import 'package:scroll_to_perfection/whatsapp_parallax.dart';
import 'package:scroll_to_perfection/zoom_in.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (_) => HomePage(),
        '/whatsapp': (_) => WhatsappImages(),
        '/egypt': (_) => EgyptPage(),
        '/verygood': (_) => VeryGood(),
        '/blockedAnimation': (_) => BlockedAnimation(),
        '/zoom_in': (_) => ZoomIn(),
        '/cuberto': (_) => Cuberto(),
        '/scroll_reveal': (_) => ScrollRevealExample(),
        '/timer': (_) => TimerAnimation(),
        '/scroll': (_) => MyScroll()
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter: Scroll to perfection'),
        actions: [
          IconButton(
            icon: FaIcon(FontAwesomeIcons.github),
            onPressed: () => launchUrl(
              Uri.parse('https://github.com/MarcinusX/scroll_to_perfection'),
            ),
          )
        ],
      ),
      body: ListView(
        children: [
          DemoOptionButton(
            name: 'What\'sApp paralax images',
            path: '/whatsapp',
          ),
          DemoOptionButton(
            name: 'Egypt',
            path: '/egypt',
          ),
          DemoOptionButton(
            name: 'VeryGood',
            path: '/verygood',
          ),
          DemoOptionButton(
            name: 'Blocked animation',
            path: '/blockedAnimation',
          ),
          DemoOptionButton(
            name: 'Zoom in',
            path: '/zoom_in',
          ),
          DemoOptionButton(
            name: 'Cuberto',
            path: '/cuberto',
          ),
          DemoOptionButton(
            name: 'Scroll Reveal (mashq)',
            path: '/scroll_reveal',
          ),
          DemoOptionButton(
            name: 'Timer Animation',
            path: '/timer',
          ),
          DemoOptionButton(
            name: 'My Scroll (mashq)',
            path: '/scroll',
          ),
        ],
      ),
    );
  }
}

class DemoOptionButton extends StatelessWidget {
  final String name;
  final String path;

  const DemoOptionButton({Key? key, required this.name, required this.path})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      onTap: () => Navigator.of(context).pushNamed(path),
    );
  }
}
