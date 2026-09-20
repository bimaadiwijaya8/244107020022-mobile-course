import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:a/main.dart';

void main() {
  testWidgets('Dashboard satu kolom di layar sempit', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());

    final cards = find.byType(DashboardCard);

    expect(cards, findsNWidgets(4));

    final firstCard = tester.getRect(cards.at(0));
    final secondCard = tester.getRect(cards.at(1));

    expect(firstCard.width, lessThan(400));
    expect(secondCard.top, greaterThan(firstCard.bottom));
  });

  testWidgets('Dashboard dua kolom di layar lebar', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DashboardApp());

    final cards = find.byType(DashboardCard);

    expect(cards, findsNWidgets(4));

    final firstCard = tester.getRect(cards.at(0));
    final secondCard = tester.getRect(cards.at(1));

    expect(firstCard.width, greaterThan(500));
    expect(secondCard.left, greaterThan(firstCard.right));
  });
}