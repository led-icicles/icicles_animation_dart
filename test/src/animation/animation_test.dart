import 'dart:io';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';
import 'package:test/test.dart';

void main() {
  test('Animation - decode darkening file generated by js library', () async {
    final animationFilePath = 'test/data/darkening.anim';
    final animation = await Animation.fromFile(animationFilePath);

    expect(animation.frameCount, 2184);
    expect(animation.frames.length, animation.frameCount);
    expect(animation.optimize, isFalse);
    expect(animation.useRgb565, isFalse);
    expect(animation.size, 1900769);
    expect(animation.duration.inMilliseconds, 68040);
    expect(animation.header.name, 'Darkening');
    expect(animation.header.loopsCount, 2);
    expect(animation.header.pixelsCount, 600);
    expect(animation.header.radioPanelsCount, 2);
    expect(animation.header.size, 17);
    expect(animation.header.versionNumber, 1);
    expect(animation.header.xCount, 20);
    expect(animation.header.yCount, 30);

    final readBytes = await File(animationFilePath).readAsBytes();
    final encodedBytes = animation.toBytes();

    expect(readBytes, orderedEquals(encodedBytes));
  });
}
