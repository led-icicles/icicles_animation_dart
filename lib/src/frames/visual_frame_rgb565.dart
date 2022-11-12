import 'dart:typed_data';

import 'package:icicles_animation_dart/icicles_animation_dart.dart';

class VisualFrameRgb565 extends VisualFrame {
  @override
  FrameType get type => FrameType.VisualFrameRgb565;

  /// [(1)type][(2)duration][(ledsCount*2)pixels]
  @override
  int get size {
    const typeSize = 1;
    const durationSize = 2;
    final colorsSize = pixels.length * 2;
    return typeSize + durationSize + colorsSize;
  }

  @override
  Uint8List toBytes([Endian endian = Endian.little]) {
    final writter = Writer(size, endian)
      ..writeFrameType(type)
      ..writeDuration(duration);

    /// frame pixels
    for (var i = 0; i < pixels.length; i++) {
      writter.writeColor565(pixels[i]);
    }

    return writter.bytes;
  }

  VisualFrameRgb565(super.duration, super.pixels);

  factory VisualFrameRgb565.fromVisualFrame(VisualFrame frame) {
    return VisualFrameRgb565(frame.duration, frame.pixels);
  }
}
