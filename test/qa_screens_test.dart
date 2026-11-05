import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_app/data/mock_data.dart';
import 'package:test_app/main.dart';
import 'package:test_app/models/models.dart';
import 'package:test_app/screens/checkout_screen.dart';
import 'package:test_app/screens/home_screen.dart';
import 'package:test_app/screens/restaurant_screen.dart';
import 'package:test_app/screens/tracking_screen.dart';
import 'package:test_app/state/app_state.dart';
import 'package:test_app/theme/app_theme.dart';

const _outDir = r'C:\Users\Almo\AppData\Local\Temp\opencode\luqma_shots';

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

  final kufi = FontLoader('Noto Kufi Arabic');
  kufi.addFont(rootBundle.load('assets/fonts/NotoKufiArabic-Regular.ttf'));
  await kufi.load();
}

Widget _app(Widget home, AppState state) {
  return AppScope(
    state: state,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    ),
  );
}

Future<void> _capture(WidgetTester tester, String name) async {
  final view = tester.binding.renderViews.first;
  final layer = view.debugLayer! as OffsetLayer;
  final image = await layer.toImage(view.paintBounds, pixelRatio: 2);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File('$_outDir/$name.png');
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes!.buffer.asUint8List());
}

Future<void> _precachePhotos(WidgetTester tester, BuildContext context) async {
  await tester.runAsync(() async {
    for (final name in [
      'avocado.jpg',
      'burger.jpg',
      'burger2.jpg',
      'chef.jpg',
      'chicken.jpg',
      'coffee.jpg',
      'dessert.jpg',
      'driver.jpg',
      'fries.jpg',
      'pancake.jpg',
      'pasta.jpg',
      'pizza.jpg',
      'pizza2.jpg',
      'ramen.jpg',
      'restaurant.jpg',
      'salad.jpg',
      'smoothie.jpg',
      'sushi.jpg',
      'user.jpg',
      'wings.jpg',
    ]) {
      await precacheImage(AssetImage('assets/images/$name'), context);
    }
  });
  await tester.pump(const Duration(milliseconds: 300));
}

Map<String, List<MenuOption>> _defaultSelections(MenuItem item) {
  final result = <String, List<MenuOption>>{};
  for (final group in item.optionGroups) {
    final defaults = group.options.where((o) => o.isDefault).toList();
    if (defaults.isNotEmpty) {
      result[group.id] = defaults;
    } else if (group.required && group.options.isNotEmpty) {
      result[group.id] = [group.options.first];
    }
  }
  return result;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadFonts);

  testWidgets('capture app flow screens', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final state = AppState();
    addTearDown(state.dispose);

    // 1. Home
    await tester.pumpWidget(_app(const HomeScreen(), state));
    await tester.pump(const Duration(milliseconds: 1300));
    await _precachePhotos(tester, tester.element(find.byType(HomeScreen)));
    await tester.pump(const Duration(milliseconds: 500));
    await _capture(tester, '01_home');

    // 2. Restaurant menu
    await tester.pumpWidget(
      _app(RestaurantScreen(restaurant: restaurants.first), state),
    );
    await tester.pump(const Duration(milliseconds: 900));
    await _capture(tester, '02_restaurant');

    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, -260),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await _capture(tester, '03_restaurant_scrolled');

    // 3. Product customization sheet
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, 260),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('دوبل سماش برجر').first);
    await tester.pump(const Duration(milliseconds: 700));
    await _capture(tester, '04_product_sheet');
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pump(const Duration(milliseconds: 600));

    // 4. Checkout with an item
    state.addToCart(
      restaurant: restaurants.first,
      item: restaurants.first.menu.first,
      selections: _defaultSelections(restaurants.first.menu.first),
      quantity: 1,
    );
    await tester.pumpWidget(_app(const CheckoutScreen(), state));
    await tester.pump(const Duration(milliseconds: 800));
    await _capture(tester, '05_checkout');

    // 5. Live tracking
    state.placeOrder();
    await tester.pumpWidget(_app(const TrackingScreen(), state));
    await tester.pump(const Duration(milliseconds: 1200));
    await _capture(tester, '06_tracking');

    await tester.pump(const Duration(seconds: 13));
    await tester.pump(const Duration(milliseconds: 1800));
    await _capture(tester, '07_tracking_later');
  });

  testWidgets('capture full-screen mobile home', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const LuqmaApp());
    await tester.pump(const Duration(milliseconds: 1200));
    await _capture(tester, '08_home_mobile');
  });
}
