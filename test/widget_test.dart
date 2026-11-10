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

    // Pure-white home design — sections in export order.
    expect(find.text('التوصيل إلى: الرياض، حي النرجس'), findsOneWidget);
    expect(find.text('خدماتنا'), findsOneWidget);
    expect(find.text('المطاعم'), findsOneWidget);
    expect(find.text('طلبات مارت'), findsOneWidget);
    expect(find.text('خصم 30% على أول طلبين!'), findsOneWidget);
    expect(find.text('ينتهي خلال ساعتين'), findsOneWidget);
    expect(find.text('عروض حصرية اليوم'), findsOneWidget);
    expect(find.text('كنتاكي (KFC)'), findsOneWidget);
    expect(find.text('مطاعم بالقرب منك'), findsOneWidget);
    expect(find.text('عرض الكل (42)'), findsOneWidget);
    expect(find.text('الأكثر طلباً هذا الأسبوع'), findsOneWidget);
    expect(find.text('صاروخ شاورما كلاسيك'), findsOneWidget);
    expect(find.text('استكشف'), findsOneWidget);
    expect(find.text('المفضلة'), findsOneWidget);
  });
}
