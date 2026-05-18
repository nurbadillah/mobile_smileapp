import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_smile/app/app.dart';

void main() {
  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MobileSmileApp());

    expect(find.text('SMILE'), findsOneWidget);
  });
}