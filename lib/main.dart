import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'art.dart';
import 'data.dart';

void main() => runApp(HomeFinderApp(store: EstateStore()));

class HomeFinderApp extends StatelessWidget {
  const HomeFinderApp({super.key, required this.store});
  final EstateStore store;
  @override
  Widget build(BuildContext context) {
    ThemeData theme(Brightness b) =>
        ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00695C), brightness: b), useMaterial3: true);
    return ChangeNotifierProvider.value(
      value: store,
      child: MaterialApp(
        title: 'HomeFinder NG',
        debugShowCheckedModeBanner: false,
        theme: theme(Brightness.light),
        darkTheme: theme(Brightness.dark),
        home: const Shell(),
      ),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstateStore>();
    return Scaffold(
      body: SafeArea(child: [const SearchTab(), const MapTab(), const FavouritesTab()][tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.search), label: 'Explore'),
          const NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
          NavigationDestination(
              icon: Badge(isLabelVisible: s.favourites.isNotEmpty, label: Text('${s.favourites.length}'), child: const Icon(Icons.favorite_border)),
              label: 'Saved'),
        ],
      ),
    );
  }
}

void openListing(BuildContext context, Listing l) =>
    Navigator.push(context, MaterialPageRoute(builder: (_) => ListingDetail(listing: l)));

class SearchTab extends StatelessWidget {
  const SearchTab({super.key});
  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstateStore>();
    final f = s.filters;
    final r = s.results;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Find your next home', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Area, city or type', border: OutlineInputBorder()),
            onChanged: (v) => s.update((f) => f.query = v),
          ),
        ),
        const SizedBox(width: 8),
        Badge(
          isLabelVisible: f.activeCount > 0,
          label: Text('${f.activeCount}'),
          child: IconButton.filledTonal(
            tooltip: 'Filters',
            icon: const Icon(Icons.tune),
            onPressed: () => showModalBottomSheet(context: context, builder: (_) => const FilterSheet()),
          ),
        ),
      ]),
      const SizedBox(height: 8),
      Wrap(spacing: 8, children: [
        ChoiceChip(label: const Text('All'), selected: f.purpose == null, onSelected: (_) => s.update((f) => f.purpose = null)),
        ChoiceChip(label: const Text('For rent'), selected: f.purpose == Purpose.rent, onSelected: (_) => s.update((f) => f.purpose = Purpose.rent)),
        ChoiceChip(label: const Text('For sale'), selected: f.purpose == Purpose.sale, onSelected: (_) => s.update((f) => f.purpose = Purpose.sale)),
      ]),
      Row(children: [
        Expanded(child: Text('${r.length} properties')),
        DropdownButton<String>(
          value: s.sort,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: 'newest', child: Text('Newest')),
            DropdownMenuItem(value: 'price_asc', child: Text('Price: low to high')),
            DropdownMenuItem(value: 'price_desc', child: Text('Price: high to low')),
          ],
          onChanged: (v) => s.setSort(v!),
        ),
      ]),
      for (final l in r) ListingCard(listing: l),
      if (r.isEmpty) Center(child: TextButton(onPressed: s.clearFilters, child: const Text('No matches. Clear filters'))),
    ]);
  }
}

class ListingCard extends StatelessWidget {
  const ListingCard({super.key, required this.listing});
  final Listing listing;
  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstateStore>();
    final l = listing;
    final t = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () => openListing(context, l),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(children: [
            PropertyArt(seed: l.palette, height: 150, land: l.type == 'Land'),
            Positioned(left: 10, top: 10, child: Chip(label: Text(l.purpose == Purpose.rent ? 'For rent' : 'For sale'))),
            Positioned(
              right: 6,
              top: 6,
              child: IconButton.filled(
                tooltip: s.isFav(l) ? 'Remove ${l.id} from saved' : 'Save ${l.id}',
                onPressed: () => s.toggleFav(l),
                icon: Icon(s.isFav(l) ? Icons.favorite : Icons.favorite_border),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l.priceLabel, style: t.titleLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              Text(l.title, style: t.titleMedium),
              Text('${l.area}, ${l.city}'),
              const SizedBox(height: 6),
              Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                if (l.beds > 0) ...[const Icon(Icons.bed, size: 18), Text(' ${l.beds}   ')],
                if (l.baths > 0) ...[const Icon(Icons.bathtub_outlined, size: 18), Text(' ${l.baths}   ')],
                const Icon(Icons.square_foot, size: 18),
                Text(' ${l.sqm} sqm'),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class FilterSheet extends StatelessWidget {
  const FilterSheet({super.key});
  static const prices = <int?>[null, 5000000, 20000000, 100000000];
  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstateStore>();
    final f = s.filters;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Filters', style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          TextButton(onPressed: s.clearFilters, child: const Text('Reset')),
        ]),
        const Text('City'),
        Wrap(spacing: 8, children: [
          ChoiceChip(label: const Text('Any'), selected: f.city == null, onSelected: (_) => s.update((f) => f.city = null)),
          for (final c in s.cities) ChoiceChip(label: Text(c), selected: f.city == c, onSelected: (_) => s.update((f) => f.city = c)),
        ]),
        const SizedBox(height: 8),
        const Text('Bedrooms'),
        Wrap(spacing: 8, children: [
          for (final b in [0, 1, 2, 3, 4])
            ChoiceChip(label: Text(b == 0 ? 'Any' : '$b+'), selected: f.minBeds == b, onSelected: (_) => s.update((f) => f.minBeds = b)),
        ]),
        const SizedBox(height: 8),
        const Text('Max price'),
        Wrap(spacing: 8, children: [
          for (final p in prices)
            ChoiceChip(label: Text(p == null ? 'Any' : naira(p)), selected: f.maxPrice == p, onSelected: (_) => s.update((f) => f.maxPrice = p)),
        ]),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(context), child: Text('Show ${s.results.length} results'))),
      ]),
    );
  }
}

class MapTab extends StatefulWidget {
  const MapTab({super.key});
  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  String? selected;
  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstateStore>();
    final r = s.results;
    final sel = r.where((l) => l.id == selected).firstOrNull ?? (r.isEmpty ? null : r.first);
    return Stack(children: [
      Positioned.fill(
        child: MockMap(
          pins: [for (final l in r) (l.id, l.x, l.y, l.priceLabel)],
          selected: sel?.id,
          onTap: (id) => setState(() => selected = id),
        ),
      ),
      if (sel != null)
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: SizedBox(width: 64, child: PropertyArt(seed: sel.palette, height: 56, land: sel.type == 'Land')),
              title: Text(sel.title),
              subtitle: Text('${sel.priceLabel} · ${sel.area}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => openListing(context, sel),
            ),
          ),
        ),
    ]);
  }
}

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({super.key});
  @override
  Widget build(BuildContext context) {
    final favs = context.watch<EstateStore>().favouriteListings;
    if (favs.isEmpty) return const Center(child: Text('Tap the heart on a listing to save it'));
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Saved homes', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12),
      for (final l in favs) ListingCard(listing: l),
    ]);
  }
}

class ListingDetail extends StatelessWidget {
  const ListingDetail({super.key, required this.listing});
  final Listing listing;
  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstateStore>();
    final l = listing;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.area), actions: [
        IconButton(tooltip: 'Save', onPressed: () => s.toggleFav(l), icon: Icon(s.isFav(l) ? Icons.favorite : Icons.favorite_border)),
      ]),
      body: ListView(children: [
        SizedBox(
          height: 230,
          child: PageView(children: [for (var i = 0; i < 3; i++) PropertyArt(seed: l.palette + i, height: 230, land: l.type == 'Land')]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.priceLabel, style: t.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text(l.title, style: t.titleLarge),
            Text('${l.area}, ${l.city} · ${l.type} · ${l.sqm} sqm'),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [for (final x in l.features) Chip(label: Text(x))]),
            const SizedBox(height: 12),
            SizedBox(height: 160, child: ClipRRect(borderRadius: BorderRadius.circular(12), child: MockMap(pins: [(l.id, .45, .4, l.area)]))),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(child: Text(l.agent.name[0])),
              title: Text(l.agent.name),
              subtitle: Text('${l.agent.agency} · ${l.agent.phone}'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AgentChat(listing: l))),
              icon: const Icon(Icons.chat),
              label: const Text('Chat with agent'),
            ),
          ]),
        ),
      ]),
    );
  }
}

class AgentChat extends StatefulWidget {
  const AgentChat({super.key, required this.listing});
  final Listing listing;
  @override
  State<AgentChat> createState() => _AgentChatState();
}

class _AgentChatState extends State<AgentChat> {
  final ctrl = TextEditingController();
  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  void _send(EstateStore s, String text) {
    s.send(widget.listing, text);
    ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<EstateStore>();
    final msgs = s.chats[widget.listing.id] ?? const [];
    final c = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.listing.agent.name)),
      body: Column(children: [
        Expanded(
          child: ListView(padding: const EdgeInsets.all(12), children: [
            Center(child: Text('About: ${widget.listing.title}')),
            for (final m in msgs)
              Align(
                alignment: m.mine ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: m.mine ? c.primary : c.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
                  child: Text(m.text, style: TextStyle(color: m.mine ? c.onPrimary : c.onSurface)),
                ),
              ),
          ]),
        ),
        Wrap(spacing: 8, children: [
          for (final q in ['Can I inspect it?', 'Is the price negotiable?'])
            ActionChip(label: Text(q), onPressed: () => _send(s, q)),
        ]),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Expanded(child: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Message', border: OutlineInputBorder()))),
              IconButton(tooltip: 'Send', onPressed: () => _send(s, ctrl.text), icon: const Icon(Icons.send)),
            ]),
          ),
        ),
      ]),
    );
  }
}
