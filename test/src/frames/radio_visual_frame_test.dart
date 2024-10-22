import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:test/test.dart';

void main() {
  group('RadioVisualFrame -', () {
    const colors = [Colors.red, Colors.green, Colors.blue];
    test('RadioVisualFrame - Encode and decode', () async {
      const panelIndex = 2;
      const duration = Duration(seconds: 6);
      final frame = RadioVisualFrame(duration, panelIndex, colors);

      final encoded = frame.toBytes();
      final encodedFrame = RadioVisualFrame.fromBytes(encoded, colors.length);

      expect(frame.duration, encodedFrame.duration);
      expect(frame.type, encodedFrame.type);
      expect(frame.panelIndex, encodedFrame.panelIndex);
      expect(frame.colors, equals(colors));
      expect(frame.size, encodedFrame.size);
      expect(frame.size, equals(13));
      expect(
        encoded,
        orderedEquals([
          101, 112, 23, 2,
          // red
          255, 0, 0,
          // green
          0, 255, 0,
          // blue
          0, 0, 255
        ]),
      );
    });

    test('Equality check', () async {
      const panelIndex = 2;
      const duration = Duration(seconds: 6);
      final frame1 = RadioVisualFrame(duration, panelIndex, colors);
      final frame2 = RadioVisualFrame(duration, panelIndex, colors);

      expect(frame1, equals(frame2));
      expect(frame2, equals(frame1));
      expect(frame1, equals(frame1.copy()));
      expect(
        frame1,
        isNot(equals(frame1.copyWith(duration: Duration(seconds: 1)))),
      );
      expect(
        frame1,
        isNot(equals(frame1.copyWith(panelIndex: 1))),
      );
      expect(
        frame1,
        isNot(equals(frame1.copyWith(colors: colors.reversed.toList()))),
      );
    });
  });
}
