import 'package:dayflow/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders calendar and changes view', (tester) async {
    await tester.pumpWidget(const DayflowApp());
    expect(find.text('November 2026'), findsWidgets);
    expect(find.text('New event'), findsOneWidget);

    await tester.tap(find.text('Agenda'));
    await tester.pumpAndSettle();
    expect(find.text('Open day'), findsWidgets);
  });
}
