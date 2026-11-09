import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:test/test.dart';

import '../compat/compat_helpers.dart';

void main() {
  test('fps45 timeline', () {
    expect([for (var i = 0; i < 3; i++) Framerate.fps45.frameDuration(i)],
        [ms(22), ms(22), ms(23)]);
    expect(Framerate.fps45.frameStart(45), const Duration(seconds: 1));
  });

  test('frame durations are minFrameDuration or 1 ms longer', () {
    for (final framerate in Framerate.values) {
      final allowed = {
        framerate.minFrameDuration,
        framerate.minFrameDuration + ms(1),
      };
      for (var i = 0; i < 10000; i++) {
        expect(allowed, contains(framerate.frameDuration(i)),
            reason: '${framerate.name} frame $i');
      }
    }
  });

  for (final framerate in [Framerate.fps45, Framerate.fps30]) {
    test('${framerate.name}: 3 minutes survive encoding', () {
      const length = Duration(minutes: 3);
      final frames = framerate.framesPerSecond * length.inSeconds;
      final animation =
          Animation('x', xCount: 1, yCount: 1, framerate: framerate);
      for (var i = 0; i < frames; i++) {
        animation.addFrame(VisualFrame(
          duration: framerate.frameDuration(i),
          pixels: [i.isEven ? Colors.red : Colors.blue],
        ));
      }

      expect(framerate.frameStart(frames), length);
      expect(Animation.fromBytes(animation.toBytes()).duration, length);
    });
  }

  test('negative index throws RangeError', () {
    expect(() => Framerate.fps45.frameStart(-1), throwsRangeError);
  });
}
