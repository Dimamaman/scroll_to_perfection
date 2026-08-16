import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scroll_to_perfection/main.dart';

void main() {
  testWidgets('shows scroll animation demos', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('Flutter: Scroll to perfection'), findsOneWidget);
    expect(find.text('What\'sApp paralax images'), findsOneWidget);
    expect(find.text('Egypt'), findsOneWidget);
    expect(find.text('VeryGood'), findsOneWidget);
    expect(find.text('Blocked animation'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Zoom in'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Zoom in'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Mashq 10: Hero Morph'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Mashq 10: Hero Morph'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Mashq 12: Repeat + Shimmer'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Mashq 12: Repeat + Shimmer'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Mashq 13: Ticket Tear'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Mashq 13: Ticket Tear'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Unlock Pattern Animation'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Unlock Pattern Animation'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Draggable Bottom Dock'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Draggable Bottom Dock'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Animated Compass Target'),
      100,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Animated Compass Target'), findsOneWidget);
  });
}
