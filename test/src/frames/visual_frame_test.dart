import 'package:icicles_animation_dart/src/frames/visual_frame.dart';
import 'package:icicles_animation_dart/src/core/color.dart';
import 'package:test/test.dart';

void main() {
  test('VisualFrame - Encode and decode', () async {
    final pixels = [
      Colors.red,
      Colors.green,
      Colors.blue,
    ];
    final frame = VisualFrame(const Duration(seconds: 6), pixels);

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
}
