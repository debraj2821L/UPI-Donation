import 'package:flutter_test/flutter_test.dart';
import 'package:debraj_app/main.dart';

void main() {
  testWidgets('shows donation form with the UPI ID', (tester) async {
    await tester.pumpWidget(const DonationApp());

    expect(find.text('Donate to Debraj'), findsOneWidget);
    expect(find.textContaining('debrajpratihar@jio'), findsOneWidget);
    expect(find.text('Generate QR Code'), findsOneWidget);
  });
}
