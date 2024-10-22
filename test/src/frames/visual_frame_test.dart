import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:test/test.dart';

void main() {
  group('VisualFrame -', () {
    test('Encode and decode', () async {
      final pixels = [
        Colors.red,
        Colors.green,
        Colors.blue,
      ];
      final frame = VisualFrame(
        duration: const Duration(seconds: 6),
        pixels: pixels,
      );

      final encoded = frame.toBytes();
      final encodedFrame = VisualFrame.fromBytes(encoded, pixels.length);

      expect(frame.duration, encodedFrame.duration);
      expect(frame.pixels, encodedFrame.pixels);
      expect(frame.pixels, orderedEquals(pixels));
      expect(encodedFrame.pixels, orderedEquals(pixels));
      expect(frame.size, equals(12));
      expect(
        encoded,
        orderedEquals([2, 112, 23, 255, 0, 0, 0, 255, 0, 0, 0, 255]),
      );
    });

    test('Equality check works correctly', () async {
      final pixels = [
        Colors.red,
        Colors.green,
        Colors.blue,
      ];
      const duration = Duration(seconds: 6);
      final visualFrame = VisualFrame(
        duration: duration,
        pixels: pixels,
      );
      final visualFrame565 = VisualFrameRgb565(
        duration: duration,
        pixels: pixels,
      );

      expect(visualFrame, isNot(equals(visualFrame565)));
      expect(visualFrame, equals(visualFrame.copy()));
      expect(
        visualFrame,
        isNot(equals(visualFrame.copyWith(duration: Duration(seconds: 1)))),
      );
      expect(
        visualFrame,
        isNot(equals(
          visualFrame.copyWith(pixels: pixels.reversed.toList()),
        )),
      );
    });
  });
}
