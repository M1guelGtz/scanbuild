import 'package:flutter_test/flutter_test.dart';

import 'package:scanbuild/vision_price.dart';

void main() {
  testWidgets('Login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const VisionPriceApp());
    await tester.pumpAndSettle();

    expect(find.text('VisionPrice'), findsOneWidget);
    expect(find.text('Inicia sesión'), findsOneWidget);
    expect(find.text('Continuar'), findsOneWidget);
  });
}
