import 'package:icicles_animation_dart/src/frames/delay_frame.dart';
import 'package:test/test.dart';

void main() {
  group('DelayFrame -', () {
    test('Encode and decode', () async {
      final frame = DelayFrame(const Duration(seconds: 6));

      final encoded = frame.toBytes();
      final encodedFrame = DelayFrame.fromBytes(encoded);

      expect(frame.duration, encodedFrame.duration);
      expect(frame.size, equals(3));
      expect(encoded, orderedEquals([1, 112, 23]));
    });

    test('Equality check', () async {
      const duration = Duration(seconds: 6);
      final frame1 = DelayFrame(duration);
      final frame2 = DelayFrame(duration);

      expect(frame1, equals(frame2));
      expect(frame2, equals(frame1));
      expect(
        frame1,
        isNot(equals(frame1.copyWith(duration: Duration(seconds: 1)))),
      );
    });
  });
}
