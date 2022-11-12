import 'dart:io';

import 'package:icicles_animation_dart/src/animation/animation_header.dart';
import 'package:icicles_animation_dart/src/frames/delay_frame.dart';
import 'package:test/test.dart';

void main() {
  test('DelayFrame - Encode and decode', () async {
    final frame = DelayFrame(const Duration(seconds: 6));

    final encoded = frame.toBytes();
    final encodedFrame = DelayFrame.fromBytes(encoded);

    expect(frame.duration, encodedFrame.duration);
  });
}
