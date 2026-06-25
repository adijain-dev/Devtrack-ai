import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:devtrack_frontend/main.dart';

void main() {
  testWidgets('App boot test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: DevTrackApp(),
      ),
    );

    // Verify that the title is in the widget tree (or login page)
    expect(find.byType(DevTrackApp), findsOneWidget);
  });
}
