import 'package:flutter_test/flutter_test.dart';
import 'package:homefinder/data.dart';

void main() {
  test('naira formatting', () {
    expect(naira(1800000), '₦1.8M');
    expect(naira(185000000), '₦185M');
    expect(naira(950000), '₦950,000');
  });

  test('price labels', () {
    expect(demoListings[1].priceLabel, '₦6.5M/yr');
    expect(demoListings[0].priceLabel, '₦185M');
  });

  test('filters combine', () {
    final s = EstateStore();
    expect(s.results.length, 7);
    s.update((f) => f.purpose = Purpose.rent);
    expect(s.results.map((l) => l.id), ['L2', 'L4', 'L6']);
    s.update((f) => f.city = 'Lagos');
    expect(s.results.map((l) => l.id), ['L4', 'L6']);
    s.update((f) => f.minBeds = 2);
    expect(s.results.map((l) => l.id), ['L6']);
    expect(s.filters.activeCount, 3);
    s.clearFilters();
    s.update((f) => f.query = 'abuja');
    expect(s.results.length, 3);
    s.update((f) => f.maxPrice = 20000000);
    expect(s.results.map((l) => l.id), ['L2']);
  });

  test('sorting', () {
    final s = EstateStore()..setSort('price_asc');
    expect(s.results.first.id, 'L4');
    s.setSort('price_desc');
    expect(s.results.first.id, 'L5');
  });

  test('favourites toggle', () {
    final s = EstateStore();
    final l = s.byId('L3');
    s.toggleFav(l);
    expect(s.favouriteListings, [l]);
    s.toggleFav(l);
    expect(s.favouriteListings, isEmpty);
  });

  test('agent chat auto replies by intent', () {
    final s = EstateStore();
    final l = s.byId('L2');
    s.send(l, '  ');
    expect(s.chats[l.id], isNull);
    s.send(l, 'Can I inspect it?');
    expect(s.chats[l.id]!.last.text, contains('Saturday'));
    s.send(l, 'Is the price negotiable?');
    expect(s.chats[l.id]!.last.text, contains('₦6.5M/yr'));
    expect(s.chats[l.id]!.where((m) => m.mine).length, 2);
  });
}
