import 'package:flutter_test/flutter_test.dart';

import 'package:my_project/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartNestApp());
    expect(find.text('SmartNest'), findsNothing);
  });
}
