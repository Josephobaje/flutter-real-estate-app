import 'package:flutter/foundation.dart';

String naira(int n) {
  if (n >= 1000000) {
    final m = n / 1000000;
    return '₦${m == m.roundToDouble() ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}M';
  }
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return '₦$b';
}

enum Purpose { rent, sale }

class Agent {
  const Agent(this.name, this.agency, this.phone);
  final String name;
  final String agency;
  final String phone;
}

class Listing {
  const Listing({
    required this.id,
    required this.title,
    required this.area,
    required this.city,
    required this.price,
    required this.purpose,
    required this.beds,
    required this.baths,
    required this.sqm,
    required this.type,
    required this.x,
    required this.y,
    required this.palette,
    required this.agent,
    this.features = const [],
  });
  final String id;
  final String title;
  final String area;
  final String city;

  /// Yearly rent or sale price in Naira.
  final int price;
  final Purpose purpose;
  final int beds;
  final int baths;
  final int sqm;
  final String type;

  /// Position on the mock map, 0..1.
  final double x;
  final double y;

  /// Seed for the generated placeholder illustration.
  final int palette;
  final Agent agent;
  final List<String> features;
  String get priceLabel => purpose == Purpose.rent ? '${naira(price)}/yr' : naira(price);
}

const _a1 = Agent('Tunde Bakare', 'Prime Homes Realty', '0803 000 1111');
const _a2 = Agent('Amina Yusuf', 'Capital Estates', '0805 000 2222');

const demoListings = [
  Listing(id: 'L1', title: '4 Bedroom Detached Duplex', area: 'Lekki Phase 1', city: 'Lagos', price: 185000000, purpose: Purpose.sale, beds: 4, baths: 5, sqm: 420, type: 'Duplex', x: .72, y: .62, palette: 0, agent: _a1, features: ['BQ', 'Swimming pool', '24h power', 'Gated estate']),
  Listing(id: 'L2', title: '2 Bedroom Serviced Flat', area: 'Wuse II', city: 'Abuja', price: 6500000, purpose: Purpose.rent, beds: 2, baths: 2, sqm: 110, type: 'Flat', x: .35, y: .30, palette: 1, agent: _a2, features: ['Serviced', 'Gym', 'Parking']),
  Listing(id: 'L3', title: '3 Bedroom Terrace', area: 'Gwarinpa', city: 'Abuja', price: 75000000, purpose: Purpose.sale, beds: 3, baths: 4, sqm: 260, type: 'Terrace', x: .22, y: .18, palette: 2, agent: _a2, features: ['C of O', 'Fitted kitchen']),
  Listing(id: 'L4', title: 'Mini Flat (Self Contain)', area: 'Yaba', city: 'Lagos', price: 1800000, purpose: Purpose.rent, beds: 1, baths: 1, sqm: 45, type: 'Flat', x: .55, y: .48, palette: 3, agent: _a1, features: ['Prepaid meter', 'Water']),
  Listing(id: 'L5', title: '5 Bedroom Mansion', area: 'Maitama', city: 'Abuja', price: 650000000, purpose: Purpose.sale, beds: 5, baths: 6, sqm: 900, type: 'Detached', x: .45, y: .12, palette: 4, agent: _a2, features: ['Cinema', 'Pool', 'Smart home', 'BQ']),
  Listing(id: 'L6', title: '3 Bedroom Apartment', area: 'Ikoyi', city: 'Lagos', price: 15000000, purpose: Purpose.rent, beds: 3, baths: 3, sqm: 180, type: 'Flat', x: .82, y: .40, palette: 5, agent: _a1, features: ['Sea view', 'Elevator', 'Security']),
  Listing(id: 'L7', title: 'Plot of Land (600sqm)', area: 'Ibeju Lekki', city: 'Lagos', price: 12000000, purpose: Purpose.sale, beds: 0, baths: 0, sqm: 600, type: 'Land', x: .90, y: .85, palette: 6, agent: _a1, features: ['Registered survey', 'Dry land']),
];

class Filters {
  Filters({this.query = '', this.purpose, this.city, this.minBeds = 0, this.maxPrice});
  String query;
  Purpose? purpose;
  String? city;
  int minBeds;
  int? maxPrice;

  bool matches(Listing l) {
    final q = query.trim().toLowerCase();
    return (q.isEmpty || '${l.title} ${l.area} ${l.city} ${l.type}'.toLowerCase().contains(q)) &&
        (purpose == null || l.purpose == purpose) &&
        (city == null || l.city == city) &&
        l.beds >= minBeds &&
        (maxPrice == null || l.price <= maxPrice!);
  }

  int get activeCount => [purpose != null, city != null, minBeds > 0, maxPrice != null].where((x) => x).length;
}

class ChatMessage {
  ChatMessage(this.text, {required this.mine});
  final String text;
  final bool mine;
}

class EstateStore extends ChangeNotifier {
  EstateStore({List<Listing> listings = demoListings}) : _all = listings;
  final List<Listing> _all;
  final Filters filters = Filters();
  final Set<String> favourites = {};
  final Map<String, List<ChatMessage>> chats = {};
  String sort = 'newest';

  List<Listing> get results {
    final r = _all.where(filters.matches).toList();
    if (sort == 'price_asc') r.sort((a, b) => a.price.compareTo(b.price));
    if (sort == 'price_desc') r.sort((a, b) => b.price.compareTo(a.price));
    return r;
  }

  List<String> get cities => {for (final l in _all) l.city}.toList()..sort();
  List<Listing> get favouriteListings => _all.where((l) => favourites.contains(l.id)).toList();
  Listing byId(String id) => _all.firstWhere((l) => l.id == id);

  void update(void Function(Filters f) fn) {
    fn(filters);
    notifyListeners();
  }

  void setSort(String s) {
    sort = s;
    notifyListeners();
  }

  void clearFilters() {
    filters
      ..query = ''
      ..purpose = null
      ..city = null
      ..minBeds = 0
      ..maxPrice = null;
    notifyListeners();
  }

  bool isFav(Listing l) => favourites.contains(l.id);
  void toggleFav(Listing l) {
    favourites.contains(l.id) ? favourites.remove(l.id) : favourites.add(l.id);
    notifyListeners();
  }

  /// Sends a message and a canned auto-reply from the agent (demo, no backend).
  void send(Listing l, String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    final c = chats.putIfAbsent(l.id, () => []);
    c.add(ChatMessage(t, mine: true));
    final lower = t.toLowerCase();
    final reply = lower.contains('inspect') || lower.contains('visit')
        ? 'Sure! I can show you ${l.title} on Saturday at 11am. Does that work?'
        : lower.contains('price') || lower.contains('negotiable')
            ? 'The asking price is ${l.priceLabel}. There is a little room to negotiate for serious buyers.'
            : 'Thanks for your interest in ${l.title}, ${l.area}. I will get back to you shortly. ${l.agent.name}';
    c.add(ChatMessage(reply, mine: false));
    notifyListeners();
  }
}
