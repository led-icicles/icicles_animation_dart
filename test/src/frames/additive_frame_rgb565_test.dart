import 'package:icicles_animation_dart/src/frames/additive_frame_rgb565.dart';
import 'package:icicles_animation_dart/src/core/color.dart';
import 'package:test/test.dart';

void main() {
  test('AdditiveFrameRgb565 - Encode and decode', () async {
    final changedPixels = List<IndexedColor>.unmodifiable([
      IndexedColor(0, Colors.red),
      IndexedColor(3, Colors.green),
      IndexedColor(10, Colors.blue),
    ]);
    final duration = const Duration(seconds: 6);

    final frame = AdditiveFrameRgb565(duration, changedPixels);
    final encoded = frame.toBytes();
    final encodedFrame = AdditiveFrameRgb565.fromBytes(encoded);

    expect(frame.duration, encodedFrame.duration);
    expect(frame.changedPixels, encodedFrame.changedPixels);
    expect(frame.size, equals(17));
    expect(
      encoded,
      orderedEquals(
        [13, 112, 23, 3, 0, 0, 0, 0, 248, 3, 0, 224, 7, 10, 0, 31, 0],
      ),
    );
  });
}
