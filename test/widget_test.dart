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

    await tester.drag(find.byType(Scrollable), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('Zoom in'), findsOneWidget);
    expect(find.text('Cuberto'), findsOneWidget);
  });
}
