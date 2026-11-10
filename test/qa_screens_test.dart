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

const _outDir = r'C:\Users\Almo\AppData\Local\Temp\opencode\yalla_shots';

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
  // Rasterizing through the engine is REAL async — it must run inside
  // runAsync, otherwise it poisons the fake-async event loop and every
  // subsequent guarded call (pump / pumpWidget) hangs forever.
  await tester.runAsync(() async {
    final image = await layer.toImage(view.paintBounds, pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$_outDir/$name.png');
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

Future<void> _precachePhotos(WidgetTester tester, BuildContext context) async {
  await tester.runAsync(() async {
    for (final name in [
      // Shared food photography.
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
      'salad.jpg',
      'smoothie.jpg',
      'user.jpg',
      'wings.jpg',
      // YallaTalabat design photography.
      'yalla/y_cat_burger.jpg',
      'yalla/y_cat_pizza.jpg',
      'yalla/y_cat_shawarma.jpg',
      'yalla/y_cat_kabsa.jpg',
      'yalla/y_cat_kunafa.jpg',
      'yalla/y_cat_coffee.jpg',
      'yalla/y_cat_salad.jpg',
      'yalla/y_res_burger.jpg',
      'yalla/y_res_shawarmer.jpg',
      'yalla/y_res_maestro.jpg',
      'yalla/y_res_sultan.jpg',
      'yalla/y_res_chicken.jpg',
      'yalla/y_res_najdiah.jpg',
      'yalla/y_item_smoke.jpg',
      'yalla/y_item_truffle.jpg',
      'yalla/y_item_crispy.jpg',
      'yalla/y_item_fries.jpg',
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

    // 1. Home — orange header, categories, brands, restaurant cards.
    await tester.pumpWidget(_app(const HomeScreen(), state));
    await tester.pump(const Duration(milliseconds: 1300));
    await _precachePhotos(tester, tester.element(find.byType(HomeScreen)));
    await tester.pump(const Duration(milliseconds: 500));
    await _capture(tester, '01_home');

    // 2. Restaurant menu — hero, meta card, chips, item rows.
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

    // 3. Product customization sheet.
    await tester.drag(
      find.byType(CustomScrollView).first,
      const Offset(0, 260),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('كلاسيك سموك برجر').first);
    // The first pump only registers the route ticker's start time — a
    // second pump is required to actually advance the entrance animation.
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 700));
    await _capture(tester, '04_product_sheet');
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 600));

    // 4. Checkout with an item.
    state.addToCart(
      restaurant: restaurants.first,
      item: restaurants.first.menu.first,
      selections: _defaultSelections(restaurants.first.menu.first),
      quantity: 1,
    );
    await tester.pumpWidget(_app(const CheckoutScreen(), state));
    await tester.pump(const Duration(milliseconds: 800));
    await _capture(tester, '05_checkout');

    // 5. Live tracking.
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

    await tester.pumpWidget(const YallaApp());
    await tester.pump(const Duration(milliseconds: 1200));
    await _capture(tester, '08_home_mobile');
  });
}
