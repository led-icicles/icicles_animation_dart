import 'package:icicles_animation_dart/src/frames/radio_color_frame.dart';
import 'package:icicles_animation_dart/src/core/color.dart';
import 'package:test/test.dart';

void main() {
  group('RadioColorFrame -', () {
    test('RadioColorFrame - Encode and decode', () async {
      const panelIndex = 2;
      const color = Colors.green;
      const duration = Duration(seconds: 6);
      final frame = RadioColorFrame(duration, panelIndex, color);

      final encoded = frame.toBytes();
      final encodedFrame = RadioColorFrame.fromBytes(encoded);

      expect(frame.duration, encodedFrame.duration);
      expect(frame.type, encodedFrame.type);
      expect(frame.panelIndex, encodedFrame.panelIndex);
      expect(frame.color, color);
      expect(frame.size, encodedFrame.size);
      expect(frame.size, equals(7));
      expect(encoded, orderedEquals([100, 112, 23, 2, 0, 255, 0]));
    });

    test('Equality check', () async {
      const panelIndex = 2;
      const color = Colors.green;
      const duration = Duration(seconds: 6);
      final frame1 = RadioColorFrame(duration, panelIndex, color);
      final frame2 = RadioColorFrame(duration, panelIndex, color);

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
        isNot(equals(frame1.copyWith(color: Colors.blue))),
      );
    });
  });
}
