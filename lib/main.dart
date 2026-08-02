import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scroll_to_perfection/blocked_animation.dart';
import 'package:scroll_to_perfection/cuberto.dart';
import 'package:scroll_to_perfection/egipt/egypt.dart';
import 'package:scroll_to_perfection/emoji_burst_animation.dart';
import 'package:scroll_to_perfection/examples.dart';
import 'package:scroll_to_perfection/exercises/ex1_fade.dart';
import 'package:scroll_to_perfection/exercises/ex2_scale.dart';
import 'package:scroll_to_perfection/exercises/ex3_slide.dart';
import 'package:scroll_to_perfection/exercises/ex4_rotation.dart';
import 'package:scroll_to_perfection/exercises/ex5_animated_container.dart';
import 'package:scroll_to_perfection/exercises/ex6_opacity_align.dart';
import 'package:scroll_to_perfection/exercises/ex7_animated_switcher.dart';
import 'package:scroll_to_perfection/exercises/ex8_staggered.dart';
import 'package:scroll_to_perfection/exercises/ex9_tween_sequence.dart';
import 'package:scroll_to_perfection/exercises/ex15_wave.dart';
import 'package:scroll_to_perfection/exercises/ex17_spring.dart';
import 'package:scroll_to_perfection/exercises/ex18_draggable.dart';
import 'package:scroll_to_perfection/exercises/ex19_particles.dart';
import 'package:scroll_to_perfection/exercises/ex20_final.dart';
import 'package:scroll_to_perfection/widgets/friend_sheet.dart';
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
        '/scroll': (_) => MyScroll(),
        '/emoji_burst': (_) => EmojiBurstAnimation(),
        '/ex1_fade': (_) => FadeAnimationExample(),
        '/ex2_scale': (_) => Ex2Scale(),
        '/ex3_slide': (_) => Ex3Slide(),
        '/ex4_rotation': (_) => Ex4Rotation(),
        '/ex5_animated_container': (_) => Ex5AnimatedContainer(),
        '/ex6_opacity_align': (_) => Ex6OpacityAlign(),
        '/ex7_switcher': (_) => Ex7AnimatedSwitcher(),
        '/ex8_staggered': (_) => Ex8Staggered(),
        '/ex9_tween_sequence': (_) => Ex9TweenSequence(),
        '/ex15_wave': (_) => Ex15Wave(),
        '/ex17_spring': (_) => Ex17Spring(),
        '/ex18_draggable': (_) => Ex18Draggable(),
        '/ex19_particles': (_) => Ex19Particles(),
        '/ex20_final': (_) => Ex20Final(),
        '/friend_sheet': (_) => FriendSheetDemo()
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
          DemoOptionButton(
            name: 'Emoji Burst (2GIS uslubida)',
            path: '/emoji_burst',
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Mashqlar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          DemoOptionButton(
            name: 'Mashq 1: Fade In/Out',
            path: '/ex1_fade',
          ),
          DemoOptionButton(
            name: 'Mashq 2: Scale',
            path: '/ex2_scale',
          ),
          DemoOptionButton(
            name: 'Mashq 3: Slide',
            path: '/ex3_slide',
          ),
          DemoOptionButton(
            name: 'Mashq 4: Rotation',
            path: '/ex4_rotation',
          ),
          DemoOptionButton(
            name: 'Mashq 5: AnimatedContainer',
            path: '/ex5_animated_container',
          ),
          DemoOptionButton(
            name: 'Mashq 6: Opacity + Align',
            path: '/ex6_opacity_align',
          ),
          DemoOptionButton(
            name: 'Mashq 7: AnimatedSwitcher',
            path: '/ex7_switcher',
          ),
          DemoOptionButton(
            name: 'Mashq 8: Staggered',
            path: '/ex8_staggered',
          ),
          DemoOptionButton(
            name: 'Mashq 9: TweenSequence',
            path: '/ex9_tween_sequence',
          ),
          DemoOptionButton(
            name: 'Mashq 15: Wave',
            path: '/ex15_wave',
          ),
          DemoOptionButton(
            name: 'Mashq 17: Spring',
            path: '/ex17_spring',
          ),
          DemoOptionButton(
            name: 'Mashq 18: Drag + Snap',
            path: '/ex18_draggable',
          ),
          DemoOptionButton(
            name: 'Mashq 19: Particles',
            path: '/ex19_particles',
          ),
          DemoOptionButton(
            name: 'Mashq 20: Final (barcha bilimlar)',
            path: '/ex20_final',
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '2GIS Morph',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          DemoOptionButton(
            name: 'Friend Sheet (Bottom Sheet Morph)',
            path: '/friend_sheet',
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
