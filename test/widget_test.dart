import 'package:flutter_test/flutter_test.dart';

import 'package:kelincikosmos/main.dart';

void main() {
  testWidgets('CosmosApp builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const CosmosApp());
    expect(find.byType(CosmosApp), findsOneWidget);
  });
}
