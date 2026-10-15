import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homefinder/data.dart';
import 'package:homefinder/main.dart';

void main() {
  testWidgets('save a listing, open details and chat', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    final s = EstateStore();
    await tester.pumpWidget(HomeFinderApp(store: s));
    expect(find.text('4 Bedroom Detached Duplex'), findsOneWidget);
    await tester.tap(find.byTooltip('Save L1'));
    await tester.pump();
    expect(s.favourites, {'L1'});
    await tester.tap(find.text('4 Bedroom Detached Duplex'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Chat with agent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chat with agent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Can I inspect it?'));
    await tester.pump();
    expect(find.textContaining('Saturday at 11am'), findsOneWidget);
  });

  testWidgets('rent filter and map tab', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(HomeFinderApp(store: EstateStore()));
    await tester.tap(find.text('For rent'));
    await tester.pump();
    expect(find.text('3 properties'), findsOneWidget);
    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();
    expect(find.text('₦15M/yr'), findsOneWidget);
  });
}
