import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:test_app/main.dart';

void main() {
  testWidgets('home screen renders the discovery experience', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const LuqmaApp());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('ماذا تشتهي اليوم؟'), findsOneWidget);
    expect(find.text('مطاعم مميزة'), findsOneWidget);
  });
}
