import 'package:icicles_animation_dart/src/core/core.dart';
import 'package:test/test.dart';

void main() {
  final transparent = Color.fromARGB(0, 0, 0, 0);

  group('pixels -', () {
    test('Creates empty pixels correctly.', () {
      final data = Pixels.empty(Size(2, 2));
      expect(data, [transparent, transparent, transparent, transparent]);
    });
    test('Creates filled pixels correctly.', () {
      final data = Pixels.filled(Size(2, 2), Colors.red);
      expect(data, [Colors.red, Colors.red, Colors.red, Colors.red]);
    });
    test('Creates filled pixels correctly.', () {
      final data = Pixels.filled(Size(2, 2), Colors.red);
      final dataOf = Pixels.of(data);
      expect(dataOf, equals(data));
    });

    test('setPixel works correctly', () {
      final data = Pixels.empty(Size(2, 2))..setPixel(0, Colors.red);
      expect(data, [Colors.red, transparent, transparent, transparent]);
      data
        ..setPixel(1, Colors.blue)
        ..setPixel(2, Colors.green)
        ..setPixel(3, Colors.orange);
      expect(data, [Colors.red, Colors.blue, Colors.green, Colors.orange]);
    });
    test('getPixel works correctly', () {
      final colors = [Colors.red, Colors.green, Colors.blue, Colors.white];
      final data = Pixels(Size(2, 2), colors);
      expect(data.toList(), equals(colors));
      for (int i = 0; i < data.length; i++) {
        expect(data.getPixel(i), equals(colors[i]));
      }
    });
  });

  group('PixelsView -', () {
    group('masking', () {
      test('withMask -', () {
        final data = Pixels.empty(Size(2, 2));
        final mask = Pixels(
          Size(2, 2),
          [transparent, Colors.white, transparent, Colors.white],
        );
        final view = PixelsView.of(data);
        final maskedView = view.withMask(mask);
        expect(maskedView.toList(), equals(data));

        maskedView.setAllPixelsColor(Colors.red);

        final expected = [
          Colors.transparent,
          Colors.red,
          Colors.transparent,
          Colors.red,
        ];
        expect(maskedView.toList(), equals(expected));
        expect(view.toList(), equals(expected));
        expect(data.toList(), equals(expected));
      });
    });
  });
}
