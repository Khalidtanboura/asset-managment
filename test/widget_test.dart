import 'package:asset_management/src/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home page shows add asset button', (tester) async {
    await tester.pumpWidget(const AssetManagementApp());
    await tester.pumpAndSettle();

    expect(find.text('إدارة الأصول'), findsWidgets);
    expect(find.text('إضافة أصل'), findsOneWidget);
  });
}
