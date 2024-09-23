import 'package:icicles_animation_dart/src/frames/additive_frame.dart';
import 'package:icicles_animation_dart/src/core/color.dart';
import 'package:icicles_animation_dart/src/frames/additive_frame_rgb565.dart';
import 'package:test/test.dart';

void main() {
  group('AdditiveFrame - ', () {
    test('Encode and decode', () async {
      final changedPixels = List<IndexedColor>.unmodifiable([
        IndexedColor(0, Colors.red),
        IndexedColor(3, Colors.green),
        IndexedColor(10, Colors.blue),
      ]);
      final duration = const Duration(seconds: 6);

      final frame = AdditiveFrame(duration, changedPixels);

      final encoded = frame.toBytes();

      final encodedFrame = AdditiveFrame.fromBytes(encoded);

      expect(frame.duration, encodedFrame.duration);
      expect(frame.changedPixels, encodedFrame.changedPixels);
      expect(frame.size, equals(20));
      expect(
        encoded,
        orderedEquals(
          [
            3,
            112,
            23,
            3,
            0,
            0,
            0,
            255,
            0,
            0,
            3,
            0,
            0,
            255,
            0,
            10,
            0,
            0,
            0,
            255
          ],
        ),
      );
    });

    test('Equality check works correctly', () async {
      final changedPixels = List<IndexedColor>.unmodifiable([
        IndexedColor(0, Colors.red),
        IndexedColor(3, Colors.green),
        IndexedColor(10, Colors.blue),
      ]);
      final duration = const Duration(seconds: 6);

      final additiveFrame = AdditiveFrame(duration, changedPixels);
      final additiveFrame565 = AdditiveFrameRgb565(duration, changedPixels);
      expect(additiveFrame, isNot(equals(additiveFrame565)));
      expect(additiveFrame, equals(additiveFrame.copy()));
      expect(additiveFrame565, equals(additiveFrame565.copy()));
      expect(
        additiveFrame,
        isNot(equals(additiveFrame.copyWith(duration: Duration(seconds: 1)))),
      );
      expect(
        additiveFrame,
        equals(additiveFrame.copyWith(
            changedPixels: changedPixels.reversed.toList())),
      );
      expect(
        additiveFrame565,
        isNot(
            equals(additiveFrame565.copyWith(duration: Duration(seconds: 1)))),
      );
    });
  });
}
