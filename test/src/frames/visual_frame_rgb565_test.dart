import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:test/test.dart';

void main() {
  test('VisualFrame - Encode and decode', () async {
    final pixels = [
      Colors.red,
      Colors.green,
      Colors.blue,
    ];
    final frame = VisualFrameRgb565(const Duration(seconds: 6), pixels);

    final encoded = frame.toBytes();
    final encodedFrame = VisualFrameRgb565.fromBytes(encoded, pixels.length);

    expect(frame.duration, encodedFrame.duration);
    expect(frame.pixels, encodedFrame.pixels);
    expect(frame.pixels, orderedEquals(pixels));
    expect(encodedFrame.pixels, orderedEquals(pixels));
    expect(frame.size, equals(9));
    expect(
      encoded,
      orderedEquals([12, 112, 23, 0, 248, 224, 7, 31, 0]),
    );
  });
}
