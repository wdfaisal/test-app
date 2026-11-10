import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_app/main.dart';

Future<void> _loadFonts() async {
  final plex = FontLoader('IBM Plex Sans Arabic');
  for (final file in [
    'IBMPlexSansArabic-Regular.ttf',
    'IBMPlexSansArabic-Medium.ttf',
    'IBMPlexSansArabic-SemiBold.ttf',
    'IBMPlexSansArabic-Bold.ttf',
  ]) {
    plex.addFont(rootBundle.load('assets/fonts/$file'));
  }
  await plex.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadFonts);

  testWidgets('home screen renders the discovery experience', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const YallaApp());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('التصنيفات الغذائية'), findsOneWidget);
    expect(find.text('أفضل العلامات التجارية'), findsOneWidget);
    expect(find.text('الكل'), findsOneWidget);
    expect(find.text('عرض على الخريطة'), findsOneWidget);
  });
}
