import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:test/test.dart';

void main() {
  final samples = [
    Colors.black,
    Colors.white,
    Colors.transparent,
    Color.fromRGB(200, 100, 0),
    Color.fromARGB(128, 10, 200, 90),
    Color.fromARGB(40, 255, 0, 255),
  ];

  test('normal is alphaBlend', () {
    for (final source in samples) {
      for (final destination in samples) {
        expect(Color.composite(source, destination, BlendMode.normal),
            Color.alphaBlend(source, destination));
      }
    }
  });

  test('opaque channel blending', () {
    final source = Color.fromRGB(200, 100, 0);
    final destination = Color.fromRGB(100, 100, 255);
    final expected = {
      BlendMode.add: Color.fromRGB(255, 200, 255),
      BlendMode.screen: Color.fromRGB(222, 161, 255),
      BlendMode.multiply: Color.fromRGB(78, 39, 0),
      BlendMode.max: Color.fromRGB(200, 100, 255),
      BlendMode.min: Color.fromRGB(100, 100, 0),
    };
    for (final MapEntry(key: mode, value: color) in expected.entries) {
      expect(Color.composite(source, destination, mode), color,
          reason: mode.name);
    }
  });

  test('source alpha weights the result', () {
    final halfWhite = Colors.white.withAlpha(128);
    expect(Color.composite(halfWhite, Colors.black, BlendMode.add),
        Color.fromRGB(128, 128, 128));
    for (final mode in BlendMode.values) {
      expect(
          Color.composite(
              Colors.red.withAlpha(0), Color.fromRGB(1, 2, 3), mode),
          Color.fromRGB(1, 2, 3),
          reason: mode.name);
    }
  });

  test('transparent destination gets the source over it', () {
    for (final mode in BlendMode.values) {
      for (final source in samples) {
        expect(Color.composite(source, Colors.transparent, mode),
            Color.alphaBlend(source, Colors.transparent),
            reason: '${mode.name} $source');
      }
    }
  });
}
