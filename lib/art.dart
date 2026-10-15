import 'package:flutter/material.dart';

/// Generated placeholder "photo" of a property, so the app ships no copyrighted images.
class PropertyArt extends StatelessWidget {
  const PropertyArt({super.key, required this.seed, this.height = 180, this.land = false});
  final int seed;
  final double height;
  final bool land;
  static const _skies = [
    [Color(0xFF8EC5FC), Color(0xFFE0C3FC)],
    [Color(0xFFFFD194), Color(0xFFD1913C)],
    [Color(0xFFA1C4FD), Color(0xFFC2E9FB)],
    [Color(0xFFF6D365), Color(0xFFFDA085)],
    [Color(0xFF84FAB0), Color(0xFF8FD3F4)],
    [Color(0xFFFBC2EB), Color(0xFFA6C1EE)],
    [Color(0xFFD4FC79), Color(0xFF96E6A1)],
  ];
  static const _walls = [Color(0xFFF5F0E6), Color(0xFFE9E4F0), Color(0xFFFFF4E0), Color(0xFFE6F0EC)];

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(painter: _HousePainter(_skies[seed % _skies.length], _walls[seed % _walls.length], seed, land)),
      );
}

class _HousePainter extends CustomPainter {
  _HousePainter(this.sky, this.wall, this.seed, this.land);
  final List<Color> sky;
  final Color wall;
  final int seed;
  final bool land;

  @override
  void paint(Canvas canvas, Size s) {
    final r = Offset.zero & s;
    canvas.drawRect(r, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: sky).createShader(r));
    canvas.drawCircle(Offset(s.width * .85, s.height * .2), s.height * .1, Paint()..color = const Color(0xFFFFF59D));
    final ground = s.height * .78;
    canvas.drawRect(Rect.fromLTRB(0, ground, s.width, s.height), Paint()..color = const Color(0xFF7CB342));
    final tree = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawCircle(Offset(s.width * .1, ground - 30), 26, tree);
    canvas.drawCircle(Offset(s.width * .92, ground - 22), 20, tree);
    if (land) {
      final peg = Paint()..color = const Color(0xFF795548)..strokeWidth = 3;
      for (final x in [.2, .45, .7]) {
        canvas.drawLine(Offset(s.width * x, ground + 4), Offset(s.width * x, ground - 22), peg);
      }
      return;
    }
    final floors = 1 + seed % 3;
    final w = s.width * (.38 + (seed % 2) * .1);
    final left = (s.width - w) / 2;
    final fh = s.height * .18;
    final top = ground - fh * floors;
    canvas.drawRect(Rect.fromLTWH(left, top, w, fh * floors), Paint()..color = wall);
    final roof = Path()
      ..moveTo(left - 14, top)
      ..lineTo(left + w / 2, top - fh * .9)
      ..lineTo(left + w + 14, top)
      ..close();
    canvas.drawPath(roof, Paint()..color = [const Color(0xFF8D3B2F), const Color(0xFF37474F), const Color(0xFF5D4037)][seed % 3]);
    final win = Paint()..color = const Color(0xFF90CAF9);
    for (var f = 0; f < floors; f++) {
      for (var i = 0; i < 3; i++) {
        canvas.drawRect(Rect.fromLTWH(left + w * (.12 + i * .3), top + fh * f + fh * .25, w * .16, fh * .45), win);
      }
    }
    canvas.drawRect(Rect.fromLTWH(left + w * .44, ground - fh * .7, w * .12, fh * .7), Paint()..color = const Color(0xFF6D4C41));
  }

  @override
  bool shouldRepaint(_HousePainter o) => o.seed != seed;
}

/// Mock map with pins. No Google Maps key needed; swap for google_maps_flutter or flutter_map later.
class MockMap extends StatelessWidget {
  const MockMap({super.key, required this.pins, this.onTap, this.selected});
  final List<(String id, double x, double y, String label)> pins;
  final void Function(String id)? onTap;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return LayoutBuilder(builder: (context, box) {
      return Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _MapBg(c))),
        for (final p in pins)
          Positioned(
            left: p.$2 * (box.maxWidth - 90),
            top: p.$3 * (box.maxHeight - 40),
            child: GestureDetector(
              onTap: () => onTap?.call(p.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: p.$1 == selected ? c.tertiary : c.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
                ),
                child: Text(p.$4, style: TextStyle(color: c.onPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ),
      ]);
    });
  }
}

class _MapBg extends CustomPainter {
  _MapBg(this.c);
  final ColorScheme c;
  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = c.surfaceContainerHigh);
    final water = Path()
      ..moveTo(0, s.height * .9)
      ..quadraticBezierTo(s.width * .5, s.height * .75, s.width, s.height * .95)
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    canvas.drawPath(water, Paint()..color = const Color(0xFF81D4FA));
    final park = Paint()..color = const Color(0xFFA5D6A7);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(s.width * .6, s.height * .15, 80, 60), const Radius.circular(10)), park);
    final road = Paint()..color = c.surface..strokeWidth = 8;
    for (var i = 1; i < 6; i++) {
      canvas.drawLine(Offset(s.width * i / 6, 0), Offset(s.width * i / 6 + 30, s.height), road);
      canvas.drawLine(Offset(0, s.height * i / 6), Offset(s.width, s.height * i / 6 - 20), road);
    }
    final major = Paint()..color = const Color(0xFFFFE082)..strokeWidth = 12;
    canvas.drawLine(Offset(0, s.height * .55), Offset(s.width, s.height * .35), major);
  }

  @override
  bool shouldRepaint(_MapBg o) => false;
}
